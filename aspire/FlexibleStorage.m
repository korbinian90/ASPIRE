classdef FlexibleStorage < handle
    
    properties (Access = protected)
        superDir
        path
        saveSteps
        slice
        slicewise
        pixdim
        channels
        filenames
        echoes
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
                obj.echoes = raw_hdr.dime.dim(5);
            end
        end
        
        
        function write(self, image, name, channels)
            if self.path
                % Only save the specified channels
                if nargin > 3
                    if ndims(image) == 5
                        image = image(:,:,:,:,channels);
                    else
                        image = image(:,:,:,channels);
                    end
                end
                
                % calc and save only phase if image is complex
                if ~isreal(image)
                    image = angle(image);
                end
                
                if ndims(image) == 5
                    for iCha = 1:size(image,5)
                        filePath = fullfile(self.path, [name '_c' num2str(channels(iCha)) '.nii']);
                        self.saveAndCenter(image(:,:,:,:,iCha), filePath);
                    end
                else
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
            compl = single(1i * self.getPhase(fnPhase));
            compl = exp(compl);
            compl = self.getMag(fnMag) .* compl;
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
            if self.slicewise
                nii = load_nii_slice(filename, self.slice, self.echoes, self.channels);
            else
                nii = load_nii(filename, self.echoes, self.channels);
            end
            image = single(nii.img);
            image(~isfinite(image)) = 0;
        end
        
        function image = getImageInPath(self, filename)
            image = self.getImage(fullfile(self.path, filename));
        end
    end

    methods (Access = private)
        function saveAndCenter(self, image, path)
            if self.slicewise && (size(image, 3) == 1)
                [path, name, ext] = fileparts(path);
                folderPath = fullfile(path, 'sep');
                self.createFolderIfNotExisting(folderPath);
                fileName = [name '_' num2str(self.slice) ext];
                path = fullfile(folderPath, fileName);
            end
            image_nii = make_nii(image, self.pixdim);
            centre_and_save_nii(image_nii, path, image_nii.hdr.dime.pixdim);
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

