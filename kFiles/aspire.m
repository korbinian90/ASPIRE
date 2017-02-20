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
    
    if strcmpi(data.combination_mode, 'composer')
        data = preCompute_composer(data);
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

    writer = Writer(data);
    writer.setSlice(data.slices(i));
    
    % slice is the anatomical slice (i is the loop counter)
    slice = data.slices(i);
    if strcmpi(data.processing_option, 'all_at_once')
        disp('calculating all at once, it could take a while...');
    else
        disp(['calculating slice: ' num2str(slice)]);
    end
    
    %% read in the data and get complex + weight (sum of mag)
    [compl, weight] = importImages(data, slice);

    writer.setSubdir('steps');
    writer.write(angle(compl), 'orig_phase', data.write_channels); % <- temp for paper
    
    % TIMING BEGIN COMBINATION
    if strcmpi(data.processing_option, 'all_at_once')
       time = toc;
       disp('Finished loading images, calculating...');
    end
    
    %% Main steps
    poCalc = data.poCalculator;
    poCalc.setup(data);
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
    [unwrapped, unwrappingSteps] = unwrappingSelector(data, combined_phase, weight);
    
    %% ratio
    ratio = calcRatio(data.n_echoes, combined, compl, data.weightedCombination);
    
    %% save to disk
    writer.setSubdir('results');
    writer.write(combined_phase, 'combined_phase');
    writer.write(abs(combined), 'combined_mag');
    if isempty(strcmp(data.unwrapping_method, 'none'))
        writer.write(unwrapped, 'unwrapped');
    end
    if data.save_steps
        writer.setSubdir('steps');
%         writer.write(rpo_smooth, 'rpo_smooth', data.write_channels);
        writer.write(poCalc.po, 'po', data.write_channels);
        if isa(poCalc, 'AspireBipolarPoCalculator')
            writer.write(poCalc.po2, 'po2', data.write_channels);
        end
        writer.write(compl, 'no_rpo', data.write_channels);
        writer.write(abs(compl), 'mag', data.write_channels);
        writer.write(ratio, 'ratio');
        writer.write(weight, 'weight');
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


function [ compl, weight ] = importImages(data, real_slice)

    if strcmpi(data.processing_option, 'all_at_once')
        % read in full image
        phase_nii = load_nii(data.filename_phase, [], data.channels);
        mag_nii = load_nii(data.filename_mag, [], data.channels);
    else
        % read in the slice
        phase_nii = load_nii_slice(data.filename_phase, real_slice, [], data.channels);
        mag_nii = load_nii_slice(data.filename_mag, real_slice, [], data.channels);
    end

    %% precomputation steps (save memory)
    mag = single(mag_nii.img); clear mag_nii
    max_val = max(mag(:));
    min_val = max_val / 10000;
    mag = single(rescale(mag, min_val, max_val));
    phase = single(rescale(phase_nii.img, -pi, pi)); clear phase_nii
    compl = single(1i * phase); clear phase
    compl = exp(compl);
    compl = mag .* compl;
    
    % use the sum of magnitudes as weight (all channels and all echoes
    % summed up)
    weight = sum(sum(mag, 5), 4);
    
end


function saveStruct(data, slice, subdir, save)
%SAVESTRUCT saves all images from save to disk
    if ~isempty(save)
        writer = Writer(data);
        writer.setSubdir(subdir);
        writer.setSlice(slice);
        for i = 1:length(save.filenames)
            writer.write(save.images{i}, save.filenames{i});
        end
    end
end


function [ compl ] = removeRPO(nEchoes, compl, rpo_smooth)
%REMOVERPO Removes the RPO from the complex data
% keeps the magnitude values

    for eco = 1:nEchoes
        compl(:,:,:,eco,:) = squeeze(compl(:,:,:,eco,:)) .* squeeze(conj(rpo_smooth)) ./ squeeze(abs(rpo_smooth));
    end

end


function [ smoothed_rpo ] = smoothRPO(data, rpo, weight)
%SMOOTHRPO Smoothes the RPO
    smoothed_rpo = complex(zeros(size(rpo),'single'));
    % assuming same size in x and y dimension
    sigma_size = data.smoothingKernelSizeInVoxel;
    % toggle smoothing
    if ~data.rpo_weigthedSmoothing
        weight = [];
    end
    parfor cha = 1:data.n_channels
        smoothed_rpo(:,:,:,cha) = weightedGaussianSmooth(rpo(:,:,:,cha), sigma_size, weight);
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


%% MCPC3Ds slice by slice option
function mcpc3dsSliceBySlice(data)

    slice_loop = length(data.slices);
    slices = data.slices;
    
    if data.parallel && strcmpi(data.processing_option, 'slice_by_slice')
        % do parallelized (only works when slice_by_slice)
        matlabpool('open', data.parallel);      
    end
    %% Calculate Hermitian inner product
    hip = complex(zeros(data.dim, 'single'));
    
    parfor i = 1:slice_loop
        % slice is the anatomical slice (i is the loop counter)
        slice = slices(i);
        disp(['First loop calculating slice: ' num2str(slice)]);
        
        % read in the data and get complex + weight (sum of mag)
        compl = importImages(data, slice);
        
        hip(:,:,i) = calculateHip(compl, data.mcpc3d_echoes);
    end
    clear compl;
    
    unwrappingData = data;
    unwrappingData.unwrapping_method = data.mcpc3ds_unwrapping_method;
    unwrappedHip = unwrappingSelector(unwrappingData, angle(hip), abs(hip)); clear hip;

    combined_phase = zeros([data.dim data.n_echoes], 'single');
    weightVolume = zeros(data.dim, 'single');
    parfor i = 1:slice_loop
        slice = slices(i);
        disp(['Second loop calculating slice: ' num2str(slice)]);
        
        %% read in the data and get complex + weight (sum of mag)
        [compl, weight] = importImages(data, slice);
        weightVolume(:,:,i) = weight;
        
        %% get RPO
        rpo = getRPO_MCPC3Ds_sliceBySlice(data, compl, unwrappedHip(:,:,i));
        
        %% smooth RPO
        rpo_smooth = smoothRPO(data, rpo);

        %% remove RPO
        compl = removeRPO(data.n_echoes, compl, rpo_smooth);

        %% combine
        combined = combineImages(compl, data.weightedCombination);
        
        %% unwrap combined phase
        combined_phase(:,:,i,:) = angle(combined);

        %% save to disk
        writer = Writer(data);
        writer.setSlice(data.slices(i));
        writer.write(combined_phase(:,:,i,:), 'combined_phase');
        if data.save_steps
            % ratio
            ratio = calcRatio(data.n_echoes, combined, compl, data.weightedCombination);
            writer.setSubdir('steps');
            writer.write(rpo_smooth, 'rpo_smooth', data.write_channels);
            writer.write(compl, 'no_rpo', data.write_channels);
            writer.write(ratio, 'ratio');
            writer.write(weight, 'weight');
        end
        
    end
    
    if data.parallel && strcmpi(data.processing_option, 'slice_by_slice')
        % do parallelized (only works when slice_by_slice)
        matlabpool('close');      
    end
    
    if ~strcmpi(data.unwrapping_method, 'none')
        unwrapped = unwrappingSelector(data, combined_phase, weightVolume);

        filenameUnwrapped = fullfile(data.write_dir, 'results', 'unwrapped.nii');
        image_nii = make_nii(unwrapped, data.nii_pixdim(2:4));
        centre_and_save_nii(image_nii, filenameUnwrapped, image_nii.hdr.dime.pixdim);
    end
    
end
