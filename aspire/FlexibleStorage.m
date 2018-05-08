classdef FlexibleStorage < handle
    
    properties
        superDir
        path
        saveSteps
        slice
        slicewise
        pixdim
        channels
        filenames
        echoes
        singleEcho
        openFiles
        nSlices
        slices
        parallel
    end
    
    methods
        
        function obj = FlexibleStorage(write_dir, subdir, sample_fn)
            obj.superDir = write_dir;
            obj.saveSteps = 1;
            obj.slicewise = 0;
            obj.setSubdir(subdir);
            if nargin > 2
                raw_hdr = load_nii_hdr(sample_fn);
                obj.pixdim = raw_hdr.dime.pixdim(2:4);
                obj.channels = raw_hdr.dime.dim(6);
                nEchoes = raw_hdr.dime.dim(5);
                obj.nSlices = raw_hdr.dime.dim(4);
                if nEchoes == 1
                    obj.singleEcho = 1;
                end
            end
        end
        
        % destructor (is called at the end and closes the files)
        function delete(obj)
            if ~isempty(obj.openFiles)
                fields = fieldnames(obj.openFiles);
                for iFile = 1:numel(obj.openFiles)
                    fclose(obj.openFiles.(fields{iFile}));
                end
            end
        end
        
        function write(self, image, name, channels)
            if self.path
                
                if nargin <= 3
                    channels = 1:length(self.channels);
                end
                
                if ndims(image) == 5
                    image = image(:,:,:,:,channels);
                end
                
                % calc and save only phase if image is complex
                if ~isreal(image)
                    image = angle(image);
                end
                
                if ndims(image) == 5 && size(image, 4) ~= 1
                    for iCha = 1:size(image,5)
                        filePath = fullfile(self.path, [name '_c' num2str(channels(iCha)) '.nii']);
                        self.saveAndCenter(image(:,:,:,:,iCha), filePath);
                    end
                else
                    if ndims(image) == 5
                        sz = size(image);
                        image = reshape(image, [sz(1:3) sz(5)]);
                    end
                    filePath = fullfile(self.path, [name '.nii']);
                    self.saveAndCenter(image, filePath);
                end
            end
        end

        function setSubdir(self, subdir)
            if strcmp(subdir, 'results') || self.saveSteps
                self.path = fullfile(self.superDir, subdir);
                self.createFolderIfNotExisting(self.path);
            else
                self.path = '';
            end
        end
        
        function setSlice(self, slice)
            self.slice = slice;
        end
        
        function path = getPath(self)
            path = self.path;
        end
        
        function compl = importImages(self)
            compl = self.getComplex(self.filenames.mag, self.filenames.phase);
        end
        
        function compl = getComplex(self, fnMag, fnPhase)
            if ~isempty(fnPhase)
                compl = single(1i * self.getPhase(fnPhase));
                compl = exp(compl);
                if ~isempty(fnMag)
                    compl = self.getMag(fnMag) .* compl;
                else
                    warning('No Magnitude is used');
                end
            else
                warning('No Phase is used');
                compl = self.getMag(fnMag); 
            end
        end
        
        function mag = getMag(self, filename)
            mag = self.getImage(filename);
            % avoid 0 values in mag (and nagative)
            minMag = min(mag(mag > 0));
            mag(mag <= 0) = minMag;
        end
        
        function phase = getPhase(self, filename)
            phase = self.getImage(filename);
            phase = rescale(phase, -pi, pi);
        end
        
        function image = getImage(self, filename)
            if self.singleEcho
                if self.slicewise
                    nii = load_nii_slice(filename, self.slice, self.channels);
                else
                    nii = load_nii(filename, self.channels);
                end
                image = reshape(single(nii.img), size(nii.img, 1), size(nii.img, 2), size(nii.img, 3), 1, size(nii.img, 4));
            else
                if self.slicewise
                    nii = load_nii_slice(filename, self.slice, self.echoes, self.channels);
                else
                    nii = load_nii(filename, self.echoes, self.channels);
                end
                image = single(nii.img);
            end
            image(~isfinite(image)) = 0;
        end
        
        function image = getImageInPath(self, filename)
            image = self.getImage(fullfile(self.path, filename));
        end
    end

    methods (Access = private)
        function saveAndCenter(self, image, path)
            if self.slicewise && ~self.parallel
                self.saveSlicewise(image, path);
            else
                if self.slicewise && (size(image, 3) == 1)
                    [path, name, ext] = fileparts(path);
                    folderPath = fullfile(path, 'sep');
                    self.createFolderIfNotExisting(folderPath);
                    fileName = [name '_' num2str(self.slice) ext];
                    path = fullfile(folderPath, fileName);
                end
                image_nii = make_nii(single(image), self.pixdim);
                centre_and_save_nii(image_nii, path, image_nii.hdr.dime.pixdim);
            end
        end
        
        function saveSlicewise(self, image, path)
            writefile = self.getFile(image, path);
            [precision, bitpix] = self.getPrecision(image);
            for iEcho = 1:size(image, 4)
                fseek(writefile, self.getFilePosition(image, iEcho, bitpix), 'bof');
                fwrite(writefile, image(:,:,:,iEcho), precision);
%                 parfeval(@fseek, 0, writefile, image(:,:,:,iEcho), precision);
            end
%             fclose(writefile);
        end
        
        function position = getFilePosition(self, image, iEcho, bitpix)
            sliceNumber = find(self.slices - self.slice == 0);
            position = 352 + size(image, 1) * size(image, 2) * double(bitpix) / 8 * ((sliceNumber - 1) + self.nSlices * (iEcho - 1));
        end
        
        function fileHandle = getFile(self, image, path)
            writefile = self.getFieldNameFromPath(path);
            if ~isfield(self.openFiles, writefile)
                fileHandle = fopen(path, 'w');
                self.openFiles.(writefile) = fileHandle;
                
                header = self.getHeader(image);
                save_nii_hdr(header, fileHandle);
                skip_bytes = double(header.dime.vox_offset) - 348;
                if skip_bytes
                    fwrite(fileHandle, ones(1,skip_bytes), 'uint8');
                end
                dataSize = size(image, 1) * size(image, 2) * double(header.dime.bitpix) / 8 * self.nSlices * size(image, 4);
                fwrite(fileHandle, 0, 'uint8', dataSize - 1); % prefills file with zeroes
            else
                fileHandle = self.openFiles.(writefile);
%                 fileHandle = fopen(path, 'w');
            end
        end
        
        function fieldName = getFieldNameFromPath(~, path)
            fieldName = regexprep(path, '\W', '');
            maxLen = 60;
            if length(fieldName) > maxLen
                fieldName = fieldName((end - maxLen + 1):end);
            end
        end
        
        function [precision, bitpix] = getPrecision(~, image)
            if isa(image, 'logical')
                bitpix = int16(1 ); precision = 'ubit1';
            elseif   isa(image, 'uint8')
                bitpix = int16(8 ); precision = 'uint8';
            elseif isa(image, 'int16')
                bitpix = int16(16); precision = 'int16';
            elseif isa(image, 'int32')
                bitpix = int16(32); precision = 'int32';
            elseif isa(image, 'single')
                bitpix = int16(32); precision = 'float32';
            elseif isa(image, 'double')
                bitpix = int16(64); precision = 'float64';
            elseif isa(image, 'int8')
                bitpix = int16(8 ); precision = 'int8';
            elseif isa(image, 'int16')
                bitpix = int16(16); precision = 'uint16';
            elseif isa(image, 'uint32')
                bitpix = int16(32); precision = 'uint32';
            elseif isa(image, 'int64')
                bitpix = int16(64); precision = 'int64';
            elseif isa(image, 'uint64')
                bitpix = int16(64); precision = 'uint64';
            else
                error('This datatype is not supported');
            end
        end
        
        function header = getHeader(self, image)
            nii = make_nii(image);
            header = nii.hdr;
            
            [~, bitpix] = self.getPrecision(image);
            header.dime.bitpix = bitpix;
            header.dime.pixdim = [0 1 1 1 1 1 1 1];
            header.dime.pixdim(2:(length(self.pixdim) + 1)) = self.pixdim;
            header.dime.dim(4) = self.nSlices;
            header = centre_header(header);
            header.dime.vox_offset = 352;
            header.hist.magic = 'n+1';
% %         	header = set_nii_voxel_size(header, self.pixdim);
        end
    end
    
    methods (Static)
        function createFolderIfNotExisting(path)
            if ~exist(path, 'dir')
                if ~mkdir(path); disp(['Could not create folder: ' path]); end;
            end
        end
    end
end

