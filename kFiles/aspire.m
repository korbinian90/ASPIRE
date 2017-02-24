function aspire(user_data)

    %% SETUP
    setupFolder(user_data); % stops with error, if no permission
    user_data = getHeaderInfo(user_data);
    data = getDefault(user_data);
    data = checkForWrongOptions(data);
    
    %% MAIN CALCULATION
    if strcmpi(data.combination_mode, 'mcpc3ds') && strcmpi(data.processing_option, 'slice_by_slice')
        mcpc3dsSliceBySlice(data);
    else
        allPipelines(data);
    end
    
    %% POSTPROCESSING
    if strcmpi(data.processing_option, 'slice_by_slice')
        concatImagesInSubdirs(data);
    end
    
end


function allPipelines(data)

    % get loop size to loop over all slices or do all at once if chosen
    if strcmpi(data.processing_option, 'all_at_once')
        slice_loop = 1;
    else
        slice_loop = length(data.slices);
    end
    
    data.storage = Storage(data);
    poCalc = data.poCalculator;
    poCalc.setup(data);
    poCalc.preprocess();
    
    % CALCULATION
    if data.parallel && strcmpi(data.processing_option, 'slice_by_slice')
        % do parallelized (only works when slice_by_slice)
        matlabpool('open', data.parallel);      
        parfor i = 1:slice_loop
            allSteps(data, i);
        end        
        matlabpool('close');        
    else
        % standard loop over slices
        for i = 1:slice_loop
            allSteps(data, i);  
        end
    end
    
end


function allSteps(data, i)

    % slice is the anatomical slice (i is the loop counter)
    iSlice = data.slices(i);
    storage = data.storage;
    storage.setSlice(iSlice);
    
    if strcmpi(data.processing_option, 'all_at_once')
        disp('calculating all at once, it could take a while...');
    else
        disp(['calculating slice: ' num2str(iSlice)]);
    end
    
    %% read in the data and get complex + weight (sum of mag)
    compl = storage.importImages();

    storage.setSubdir('steps');
    storage.write(angle(compl), 'orig_phase', data.write_channels); % <- temp for paper
    
    % TIMING BEGIN COMBINATION
    if strcmpi(data.processing_option, 'all_at_once')
       time = toc;
       disp('Finished loading images, calculating...');
    end
    
    %% Main steps
    poCalc = data.poCalculator;
    poCalc.setSlice(iSlice);
    poCalc.calculatePo(compl);
    poCalc.smoothPo();
    poCalc.normalizePo();
    
    % TIMING END GETRPO
    if strcmpi(data.processing_option, 'all_at_once')
       disp(['Time for getRpo: ' secs2hms(toc-time)]);
    end    
    
    compl = poCalc.removePo(compl);
    combined = combineImages(compl, data.weightedCombination);

    % TIMING END COMBINATION
    if strcmpi(data.processing_option, 'all_at_once')
       disp(['Time for combination: ' secs2hms(toc-time)]);
    end    
    
    %% unwrap combined phase
    combined_phase = angle(combined);
    [unwrapped, unwrappingSteps] = unwrappingSelector(data, combined_phase, abs(combined));
    
    %% ratio
    ratio = calcRatio(data.n_echoes, combined, compl, data.weightedCombination);
    
    %% save to disk
    storage.setSubdir('results');
    storage.write(combined_phase, 'combined_phase');
    storage.write(abs(combined), 'combined_mag');
    if isempty(strcmp(data.unwrapping_method, 'none'))
        storage.write(unwrapped, 'unwrapped');
    end
    if data.save_steps
        storage.setSubdir('steps');
        storage.write(poCalc.po, 'po', data.write_channels);
        storage.write(compl, 'no_rpo', data.write_channels);
        storage.write(abs(compl), 'mag', data.write_channels);
        storage.write(ratio, 'ratio');
        saveStruct(data, i, 'unwrappingSteps', unwrappingSteps);   
    end
       
end


function combined = combineImages(compl, doWeighted)
    
    if doWeighted
        combined = weightedCombination(compl, abs(compl));
    else
        combined = sum(compl, 5);
    end
end


function [ data ] = getDefault(user_data)
%GETDEFAULT Sets default values, if they are missing
        
    % load default values
    aspire_defaults;

    % apply defaults for missing values
    for user_selections = fieldnames(user_data)'
        data.(user_selections{1}) = user_data.(user_selections{1});
    end
        
    % if custom channles are specified
    if ~isempty(data.channels)
        % replace n_channels by custom value
        data.n_channels = length(data.channels);
        % adjust indices of write_channels if subset of channels and set write_channels to all channels otherwise
        [subset, data.write_channels] = ismember(data.write_channels, data.channels);
        if ~all(subset)
            data.write_channels = 1:data.n_channels;
        end
    end
    
    % calculate smoothingKernelSize in pixel
    data.smoothingKernelSizeInVoxel = data.smoothingKernelSizeInMM / data.nii_pixdim(2);
    
    data.parallel = min(feature('numCores'), data.parallel);

end


function setupFolder(data)
%SETUPFOLDERS Setup the folders

    %   Make directory for results
    s = mkdir(data.write_dir);
    if s == 0
        error('No permission to make directory %s\n', data.write_dir);
    end
    
end


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



function [ ratio ] = calcRatio(nEchoes, combined, compl, doWeighted)
    ratio = zeros(size(combined));
    
    if doWeighted
        ratio = calculateRatioWeighted(abs(combined), abs(compl), abs(compl));
    else
        for eco = 1:nEchoes;
            magSum = sum(abs(compl(:,:,:,eco,:)), 5);
            ratio(:,:,:,eco) = abs(combined(:,:,:,eco)) ./ magSum(:,:,:);
        end
    end
end


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
            if concatImages(folder, data.slices, name)
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
