classdef Aspire < handle
    %ASPIRE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data
        sliceLoop
        poCalculator
        swiCalculator
    end
    
    methods
        
        function obj = Aspire(user_data)
            obj.setupFolder(user_data); % stops with error, if no permission
            user_data = getHeaderInfo(user_data);
            obj.getDefault(user_data);
            obj.data = checkForWrongOptions(obj.data);

            if strcmpi(obj.data.processing_option, 'all_at_once')
                obj.sliceLoop = 1;
            else
                obj.sliceLoop = length(obj.data.slices);
            end
            
            obj.data.storage = Storage(obj.data);
            obj.poCalculator = obj.data.poCalculator;
            obj.poCalculator.setup(obj.data);
            obj.poCalculator.preprocess();
    
            obj.data.combination.setup(obj.data);
            
            if isfield(obj.data, 'swiCalculator')
                obj.swiCalculator.setup(obj.data);
            end
        end
        
        
        function run(self)
            tic;
            self.openMatlabpool();
            for i = 1:self.sliceLoop
                iSlice = self.data.slices(i);
                %% Main Steps
                combined = self.combine(iSlice);
                self.unwrap(combined);
                self.swi(combined);
            end
            self.closeMatlabpool();
            
            %% POSTPROCESSING
            if strcmpi(self.data.processing_option, 'slice_by_slice')
                self.concatImagesInSubdirs(self.data);
            end
            disp(['Results written to ' self.data.write_dir '/results'])
            disp(['Total time: ' secs2hms(toc)])
        end
        
        
        function combined = combine(self, iSlice)
            % slice is the anatomical slice (i is the loop counter)
            storage = self.data.storage;
            storage.setSlice(iSlice);

            if strcmpi(self.data.processing_option, 'all_at_once')
                disp('calculating all at once, it could take a while...');
            else
                disp(['calculating slice: ' num2str(iSlice)]);
            end

            %% read in the data and get complex + weight (sum of mag)
            self.log('Importing images...');
            compl = storage.importImages();
            
            storage.setSubdir('steps');

            %% Main steps
            if size(compl, 5) > 1 || self.data.singleChannelCombination
                combined = self.combinationSteps(iSlice, compl);
            else
                combined = compl;
            end
        end
        
        
        function combined = combinationSteps(self, iSlice, compl)
            storage = self.data.storage;
    
            self.log('Calculating phase offsets / sensitivities...');
            poCalc = self.poCalculator;
            poCalc.setSlice(iSlice);
            poCalc.calculatePo(compl);
            poCalc.setSens(compl);

            storage.write(poCalc.po, 'poBeforeSmooth');
            storage.write(abs(poCalc.po), 'sensBeforeSmooth');
            storage.write(real(poCalc.po), 'realBeforeSmooth');
            storage.write(imag(poCalc.po), 'imagBeforeSmooth');
            
            self.log('Smoothing phase offsets / sensitivities...');
            weight = abs(compl(:,:,:,min(end, 2),:));
            poCalc.smoothPo(weight);
            if ~self.data.singleEcho
                self.log('Performing iterative correction of phase offsets...');
                poCalc.iterativeCorrection(compl(:,:,:,1:2,:));
            end
            storage.write(abs(poCalc.po), 'sens', self.data.write_channels_po);
            storage.write(real(poCalc.po), 'realSens', self.data.write_channels_po);
            storage.write(imag(poCalc.po), 'imagSens', self.data.write_channels_po);

        %     poCalc.removeLowSens();
            self.log('Removing phase offsets...');
            compl = poCalc.removePo(compl);
            
            self.log('Performing combination...');
            self.data.combination.setSlice(iSlice);
            combined = self.data.combination.combine(compl, poCalc.getSens());

            storage.write(poCalc.po, 'po', self.data.write_channels_po);

            %% ratio
            ratio = calcRatio(self.data.n_echoes, combined, compl, self.data.weightedCombination);
            storage.write(ratio, 'ratio');
            
            %% write results
            storage.setSubdir('results');
            storage.write(angle(combined), 'combined_phase');
            storage.write(abs(combined), 'combined_mag');
        end
        
        
        function unwrap(self, combined, iSlice)
            if ~strcmp(self.data.unwrapping_method, 'none')
                %% unwrap combined phase
                self.log('Unwrapping...');
                combined_phase = angle(combined);
                [unwrapped, unwrappingSteps] = unwrappingSelector(self.data, combined_phase, abs(combined(:,:,:,1)));
                saveStruct(self.data, iSlice, 'unwrappingSteps', unwrappingSteps);
                storage.setSubdir('results');
                storage.write(unwrapped, 'unwrapped');
            end
        end
        
        
        function swi(self, combined, iSlice)
            %% SWI
            if isfield(self.data, 'swiCalculator')
                self.log('Calculating SWI...');
                self.swiCalculator.setSlice(iSlice);
                swi = self.swiCalculator.calculate(combined);
                storage.setSubdir('results');
                storage.write(swi, 'swi');
            end
        end
        
        
        function openMatlabpool(self)
            if self.data.parallel && matlabpool('size') == 0
                matlabpool('open', self.data.parallel);
            end
        end
        
        
        function closeMatlabpool(self)
            if self.data.parallel
                matlabpool('close');
            end
        end
        
        
        function log(self, message)
            if strcmp(self.data.processing_option, 'all_at_once')
                disp(message)
            end
        end
    
        
        function getDefault(self, user_data)
        %GETDEFAULT Sets default values from aspire_defaults.m
            % load default values
            newData = loadAspireDefaultValues();
            
            % apply defaults for missing values
            for user_selections = fieldnames(user_data)'
                data.(user_selections{1}) = user_data.(user_selections{1});
            end

            % if custom channels are specified
            if ~isempty(data.channels)
                % replace n_channels by custom value
                data.n_channels = length(data.channels);
                % adjust indices of write_channels if subset of channels and set write_channels to all channels otherwise
                [subset, data.write_channels] = ismember(data.write_channels, data.channels);
                if ~all(subset)
                    data.write_channels = 1:data.n_channels;
                end
            end

            data.smoothingSigmaSizeInVoxel = self.mmToVoxel(data.smoothingSigmaSizeInMM, data.nii_pixdim);

            data.parallel = min(feature('numCores'), data.parallel);

            data.write_channels = data.write_channels(data.write_channels <= data.n_channels);

            self.data = data;
        end
    end
    
    methods (Static)
      
        function sizeInVoxel = mmToVoxel(sizeInMM, nii_pixdim)
            sizeInVoxel = sizeInMM ./ nii_pixdim(2:4);
        end

        
        % still required?
        function setupFolder(data)
        %SETUPFOLDERS Setup the folders

            %   Make directory for results
            s = mkdir(data.write_dir);
            if s == 0
                error('No permission to make directory %s\n', data.write_dir);
            end

        end

        % deprecated
        function saveStruct(data, slice, subdir, save)
        %SAVESTRUCT saves all images from save to disk
            if ~isempty(save)
                storage = Storage(data);
                storage.setSubdir(subdir);
                storage.setSlice(slice);
                for i = 1:length(save.filenames)
                    storage.write(save.images{i}, save.filenames{i});
                end
            end
        end

        %% move to storage
        function concatImagesInSubdirs(data)
        %searches for sep dirs in subdirs and concatenates images
            disp('concatenating slices with fslmerge');
            subdirs = dir(data.write_dir);

            for i = 3:length(subdirs)

                folder = fullfile(data.write_dir, subdirs(i).name);

                while isdir(fullfile(folder, 'sep'))
                    files = dir(fullfile(folder, 'sep/*.nii'));
                    if isempty(files)
                        break;
                    end
                    filename = files(1).name;
                    ending = strfind(filename, '_');
                    name = filename(1:ending(end)-1);

                    % break if error
                    if Aspire.concatImages(folder, data.slices, name)
                        break;
                    end
                end
            end

        end


        function error = concatImages(folder, data_slices, image_name)

                sep_dir = fullfile(folder, 'sep');
                filename = fullfile(folder, [image_name '.nii']);

                filename_list = cell(1,length(data_slices));
                for sl = 1:length(data_slices)
                    filename_list{sl} = fullfile(sep_dir, getNameForSlice(image_name, data_slices(sl)));
                end

                unix_command = ['fslmerge -z ' filename ' ' strjoin(filename_list)];
                [error, ~] = unix(unix_command);

                if error
                    disp(['Error concatenating ' image_name '. (' unix_command ')']);
                    disp('Maybe there are files in sep folder from different run?');
                else
                    unix(['rm ' strjoin(filename_list)]);
                    % only removes directory if it is already empty
                    [~,~,~] = rmdir(sep_dir);
                end

                % make headers right
                centre_hdr_nii(filename);

        end
    end
end