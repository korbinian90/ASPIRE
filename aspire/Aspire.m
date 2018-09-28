classdef Aspire < handle
    %ASPIRE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data
        sliceLoop
        poCalculator
        swiCalculator
        storage
        postProcessing
    end
    
    methods
        
        function obj = Aspire(user_data)
            obj.setupFolder(user_data); % stops with error, if no permission
            user_data = getHeaderInfo(user_data);
            obj.data = obj.getDefault(user_data);
            obj.data = checkForWrongOptions(obj.data);
            obj.saveConfig(obj.data);
            
            obj.swiCalculator = obj.data.swiCalculator;

            if strcmpi(obj.data.processing_option, 'all_at_once')
                obj.sliceLoop = 1;
            else
                obj.sliceLoop = length(obj.data.slices);
            end
            
            obj.storage = Storage(obj.data);
            obj.poCalculator = obj.data.poCalculator;
            obj.poCalculator.setup(obj.data);
            obj.poCalculator.checkRestrictions(obj.data);
            obj.poCalculator.preprocess();
    
            obj.data.combination.setup(obj.data);
            
            if ~isempty(obj.swiCalculator)
                obj.swiCalculator.setup(obj.data);
            end
            
            if isfield(obj.data, 'bipolarCorrection')
                obj.postProcessing.bipolarCorrection = obj.data.bipolarCorrection;
                obj.postProcessing.bipolarCorrection.setup(obj.data);
            end
            
        end
         
        
        function run(self)
            tic;
            
            
            for i = 1:self.sliceLoop
                iSlice = self.data.slices(i);
                %% Main Steps
                [combined, weight] = self.combine(iSlice);
                if isfield(self.data, 'bipolarCorrection')
                    combined = self.postProcessing.bipolarCorrection.apply(combined);
                end
                
                %% write results
                self.storage.setSubdir('results');
                self.storage.write(angle(combined), 'combined_phase');
                self.storage.write(abs(combined), 'combined_mag');
                
                unwrapped = self.unwrap(combined);
                combined = self.magnitudeCorrection(combined);
                self.swi(combined, unwrapped, weight, iSlice);
                
            end
            
            %% POSTPROCESSING
            if strcmpi(self.data.processing_option, 'slice_by_slice')
                self.concatImagesInSubdirs(self.data);
            end
            disp(['Results written to ' self.data.write_dir '/results'])
            disp(['Total time: ' secs2hms(toc)])
        end
        
        function [combined, weight] = combine(self, iSlice)
            % slice is the anatomical slice (i is the loop counter)
            self.storage.setSlice(iSlice);

            if strcmpi(self.data.processing_option, 'all_at_once')
                disp('calculating all at once, it could take a while...');
            else
                disp(['calculating slice: ' num2str(iSlice)]);
            end

            %% read in the data and get complex + weight (sum of mag)
            self.log('Importing images...');
            compl = self.storage.importImages();
            
            self.storage.setSubdir('steps');

            weight = sum(abs(compl), 5);
            
            %% Main steps
            if size(compl, 5) > 1 || self.data.singleChannelCombination
                combined = self.combinationSteps(iSlice, compl);
            else
                combined = compl;
                disp('already combined!');
            end
        end
        
        
        function combined = combinationSteps(self, iSlice, compl)
            self.log('Calculating phase offsets / sensitivities...');
            poCalc = self.poCalculator;
            poCalc.setSlice(iSlice);
            poCalc.calculatePo(compl);
            poCalc.setSens(compl);

            self.storage.write(poCalc.po, 'poBeforeSmooth', self.data.write_channels_po);
            self.storage.write(abs(poCalc.po), 'sensBeforeSmooth', self.data.write_channels_po);
            self.storage.write(real(poCalc.po), 'realBeforeSmooth', self.data.write_channels_po);
            self.storage.write(imag(poCalc.po), 'imagBeforeSmooth', self.data.write_channels_po);
            
            self.log('Smoothing phase offsets / sensitivities...');
            weight = abs(compl(:,:,:,min(end, 2),:));
            poCalc.smoothPo(weight);
            if ~self.data.singleEcho && (~isfield(self.data, 'echoes') || length(self.data.echoes) ~= 1)
                self.log('Performing iterative correction of phase offsets...');
                poCalc.iterativeCorrection(compl(:,:,:,1:2,:));
            end
            self.storage.write(abs(poCalc.po), 'sens', self.data.write_channels_po);
            self.storage.write(real(poCalc.po), 'realSens', self.data.write_channels_po);
            self.storage.write(imag(poCalc.po), 'imagSens', self.data.write_channels_po);

%             poCalc.removeLowSens();
            self.log('Removing phase offsets...');
            compl = poCalc.removePo(compl);
            
            self.log('Performing combination...');
            self.data.combination.setSlice(iSlice);
            combined = self.data.combination.combine(compl, poCalc.getSens());

            self.storage.write(poCalc.po, 'po', self.data.write_channels_po);

            %% ratio
            magCombine = self.data.combination.combine(abs(compl), poCalc.getSens());
            ratio = abs(combined) ./ magCombine;
            self.storage.write(ratio, 'ratio');
        end
        
        
        function unwrapped = unwrap(self, combined, iSlice)
            if ~strcmp(self.data.unwrapping_method, 'none')
                %% unwrap combined phase
                self.log('Unwrapping...');
                combined_phase = angle(combined);
                [unwrapped, unwrappingSteps] = unwrappingSelector(self.data, combined_phase, abs(combined(:,:,:,1)));
                saveStruct(self.data, iSlice, 'unwrappingSteps', unwrappingSteps);
                self.storage.setSubdir('results');
                self.storage.write(unwrapped, 'unwrapped');
            else
                unwrapped = [];
            end
        end
        
        
        function combined = magnitudeCorrection(self, combined)
            if isfield(self.data, 'magnitudeCorrection')
                magCorrection = self.data.magnitudeCorrection;
                magCorrection.setup(self.data);
                combined = magCorrection.filter(combined);
            end
        end
        
        
        function swi(self, combined, unwrapped, weight, iSlice)
            %% SWI
            % TODO: check if unwrapped exists!
            if ~isempty(self.swiCalculator)
                self.log('Calculating SWI...');
                self.swiCalculator.setSlice(iSlice);
                swi = self.swiCalculator.calculate(combined, weight);
                self.storage.setSubdir('results');
                self.storage.write(swi, 'swi');
            end
        end
       
        
        function log(self, message)
            if strcmp(self.data.processing_option, 'all_at_once')
                disp(message)
            end
        end
    

    end
    
    methods (Static)
              
        function data = getDefault(user_data)
        %GETDEFAULT Sets default values from aspire_defaults.m
            % load default values
            newData = loadAspireDefaultValues(user_data);
            
            % apply defaults for missing values
            for user_selections = fieldnames(user_data)'
                newData.(user_selections{1}) = user_data.(user_selections{1});
            end

            % if custom channels are specified
            if ~isempty(newData.channels)
                % replace n_channels by custom value
                newData.n_channels = length(newData.channels);
                % adjust indices of write_channels if subset of channels and set write_channels to all channels otherwise
                [subset, newData.write_channels] = ismember(newData.write_channels, newData.channels);
                if ~all(subset)
                    newData.write_channels = 1:newData.n_channels;
                end
            end

            newData.smoothingSigmaSizeInVoxel = Aspire.mmToVoxel(newData.smoothingSigmaSizeInMM, newData.nii_pixdim);

            newData.parallel = min(feature('numCores'), newData.parallel);

            newData.write_channels = newData.write_channels(newData.write_channels <= newData.n_channels);

            data = newData;
        end
        
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
        function saveStruct(~, slice, subdir, save)
        %SAVESTRUCT saves all images from save to disk
            if ~isempty(save)
                self.storage.setSubdir(subdir);
                self.storage.setSlice(slice);
                for i = 1:length(save.filenames)
                    self.storage.write(save.images{i}, save.filenames{i});
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
        
        function saveConfig(data) 
            %save(fullfile(data.write_dir, 'config_data.m'), data);
        end
    end
end