function aspire(user_data)

    %% SETUP
    setupFolder(user_data); % stops with error, if no permission
    user_data = getHeaderInfo(user_data);
    data = getDefault(user_data);
    data = checkForWrongOptions(data);
    
    %% MAIN CALCULATION
    allPipelines(data);
    
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
    
    if isfield(data, 'swiCalculator')
        data.swiCalculator.setup(data);
    end
    
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
    storage.write(angle(compl), 'orig_phase'); % <- temp for paper
    
    % TIMING BEGIN COMBINATION
    if strcmpi(data.processing_option, 'all_at_once')
       time = toc;
       disp('Finished loading images, calculating...');
    end
    
    %% Main steps
    if size(compl, 5) > 1 || data.singleChannelCombination
        combined = combinationSteps(data, iSlice, compl);
    else
        combined = compl;
    end

    % TIMING END COMBINATION
    if strcmpi(data.processing_option, 'all_at_once')
       disp(['Time for combination: ' secs2hms(toc-time)]);
    end    
    
    %% unwrap combined phase
    combined_phase = angle(combined);
    [unwrapped, unwrappingSteps] = unwrappingSelector(data, combined_phase, abs(combined(:,:,:,1)));
    saveStruct(data, i, 'unwrappingSteps', unwrappingSteps);   
    
    %% SWI
    if isfield(data, 'swiCalculator')
        swiCalculator = data.swiCalculator;
        swiCalculator.setSlice(iSlice);
        swi = swiCalculator.calculate(combined);
        storage.setSubdir('results');
        storage.write(swi, 'swi');
    end
    
    %% save results to disk
    storage.setSubdir('results');
    storage.write(combined_phase, 'combined_phase');
    storage.write(abs(combined), 'combined_mag');
    if ~strcmp(data.unwrapping_method, 'none')
        storage.write(unwrapped, 'unwrapped');
    end
       
end

function combined = combinationSteps(data, iSlice, compl)
    storage = data.storage;
    
    poCalc = data.poCalculator;
    poCalc.setSlice(iSlice);
    poCalc.calculatePo(compl);
    poCalc.setSens(compl);
    
    storage.write(poCalc.po, 'poBeforeSmooth');
    storage.write(abs(poCalc.po), 'sensBeforeSmooth');
    storage.write(real(poCalc.po), 'realBeforeSmooth');
    storage.write(imag(poCalc.po), 'imagBeforeSmooth');
    poCalc.smoothPo(abs(compl(:,:,:,1,:)));
    if ~data.singleEcho
        poCalc.iterativeCorrection(compl(:,:,:,1:2,:));
    end
    storage.write(abs(poCalc.po), 'sens', data.write_channels_po);
    storage.write(real(poCalc.po), 'realSens', data.write_channels_po);
    storage.write(imag(poCalc.po), 'imagSens', data.write_channels_po);
    
%     poCalc.removeLowSens();
    storage.write(abs(poCalc.po), 'lowSens', data.write_channels_po);
    compl = poCalc.removePo(compl);
    combined = data.combination.combine(compl, poCalc.getSens());
    
    storage.write(poCalc.po, 'po', data.write_channels_po);
    storage.write(compl, 'no_rpo', data.write_channels);
    storage.write(abs(compl), 'mag', data.write_channels);
    
    %% ratio
    ratio = calcRatio(data.n_echoes, combined, compl, data.weightedCombination);
    storage.write(ratio, 'ratio');
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
    
    data.smoothingSigmaSizeInVoxel = mmToVoxel(data.smoothingSigmaSizeInMM, data.nii_pixdim);
    
    data.parallel = min(feature('numCores'), data.parallel);
    
    data.write_channels = data.write_channels(data.write_channels <= data.n_channels);

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
