function aspire(user_data)

    %% SETUP
    % stops with error, if no permission
    setupFolder(user_data);
    % get basic header info
    user_data = getHeaderInfo(user_data);
    % check for impossible options
    user_data = checkForWrongOptions(user_data);
    % get default values for missing configuration
    data = getDefault(user_data);
    
    %% MAIN CALCULATION
    if strcmpi(data.combination_mode, 'mcpc3di') && strcmpi(data.processing_option, 'slice_by_slice')
        mcpc3diSliceBySlice(data);
    else
        allPipelines(data);
    end
    
    %% POSTPROCESSING
    if strcmpi(data.processing_option, 'slice_by_slice')
        disp('concatenating slices with fslmerge');
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
% this function does all of the work (calling other functions)        

    % slice is the anatomical slice (i is the loop counter)
    slice = data.slices(i);
    if strcmpi(data.processing_option, 'all_at_once')
        disp('calculating all at once, it could take a while...');
    else
        disp(['calculating slice: ' num2str(slice)]);
    end
    
    %% read in the data and get complex + weight (sum of mag)
    [compl, weight] = importImages(data, slice);

    % TIMING BEGIN COMBINATION
    if strcmpi(data.processing_option, 'all_at_once')
       time = toc;
       disp('Finished loading images, calculating...');
    end
    
    %% get RPO
    rpo_smooth = getRPOSelector(data, compl, weight, i);

    %% remove RPO
    compl = removeRPO(data.n_echoes, compl, rpo_smooth);
    
    %% combine
    combined = sum(compl, 5);

    % TIMING END COMBINATION
    if strcmpi(data.processing_option, 'all_at_once')
       disp(['Time for combination: ' secs2hms(toc-time)]);
    end    
    
    %% unwrap combined phase
    combined_phase = angle(combined);
    [unwrapped, unwrappingSteps] = unwrappingSelector(data, combined_phase, weight);
    
    %% ratio
    ratio = calcRatio(data.n_echoes, combined, compl);
    
    %% save to disk
    saveNii(data, i, 'results', combined_phase, 'combined_phase');
    saveNii(data, i, 'results', unwrapped, 'unwrapped');
    if data.save_steps
        saveNii(data, i, 'steps', rpo_smooth, 'rpo_smooth', data.write_channels);
        saveNii(data, i, 'steps', compl, 'no_rpo', data.write_channels);
        saveNii(data, i, 'steps', ratio, 'ratio');
        saveNii(data, i, 'steps', weight, 'weight');
        saveStruct(data, i, 'unwrappingSteps', unwrappingSteps);   
    end
       
end


function user_data = checkForWrongOptions(user_data)

 % check for enough echoes for UMPIRE
    if (user_data.n_echoes < 3)
        if (strcmpi(user_data.combination_mode, 'umpire') || strcmpi(user_data.combination_mode, 'cusp3'))
            disp(['UMPIRE based combination not possible with ' int2str(user_data.n_echoes) ' echoes']);
            if (user_data.n_echoes == 2)
                disp('aspire is used instead');
                user_data.combination_mode = 'aspire';
            else
                exit;
            end
        end
        if (strcmpi(user_data.unwrapping_method, 'umpire') || strcmpi(user_data.unwrapping_method, 'mod'))
            disp(['UMPIRE based unwrapping not possible with ' int2str(user_data.n_echoes) ' echoes. No unwrapping performed.']);
            user_data.unwrapping_method = 'none';
        end
    end

    % MCPC3D only with all_at_once
    if (strcmpi(user_data.combination_mode, 'mcpc3d'))
        if ~isfield(user_data, 'processing_option') || strcmpi(user_data.processing_option, 'slice_by_slice')
            disp([user_data.combination_mode ' only works with processing_option all_at_once']);
            user_data.processing_option = 'all_at_once';
        end
    end
    
    % cusack unwrapping needs all_at_once
    if (strcmpi(user_data.processing_option, 'slice_by_slice') && (~strcmpi(user_data.combination_mode, 'mcpc3di')) && strcmpi(user_data.unwrapping_method, 'cusack'))
        disp('cusack unwrapping needs all_at_once');
        user_data.processing_option = 'all_at_once';
    end
    
    % umpire ddTE ~= 0
    if (strcmpi(user_data.combination_mode, 'umpire') || strcmpi(user_data.combination_mode, 'cusp3'))
        TEs = user_data.TEs;
        if (TEs(2) - TEs(1) == TEs(3) - TEs(2))
            error('umpire based combination is not possible with these echo times');
        end
    end
    
    % warning for aspire if TE2 ~= 2*TE1
    if (strcmpi(user_data.combination_mode, 'aspire'))
        TEs = user_data.TEs;
        echoes = user_data.aspire_echoes;
        if (TEs(echoes(2)) ~= 2 * TEs(echoes(1)))
            disp('Warning: TE2 = 2 * TE1 is not fulfilled. There may be combination problems.');
        end
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
    
    if ~isempty(data.channels)
        data.n_channels = length(data.channels);
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
        error('No permission to make directory %s/m', data.write_dir);
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

    %% precomputation steps
    mag = single(mag_nii.img);
    mag(mag <= 0) = 0;
    mag = single(rescale(mag, 0.01, 4095));
    phase = single(rescale(phase_nii.img, -pi, pi));
    compl = mag .* exp(single(1i * phase));
    
    % use the sum of magnitudes as weight (all channels and all echoes
    % summed up)
    weight = sum(mag(:,:,:,:), 4);
    
end


function saveNii(data, i, subdir, image, name, channels)
%SAVENII Saves the image file to the specified folder
% can save slice or whole image, when data.processing_option=='all_at_once'

    % always save results, save rest only if data.save_steps
    if data.save_steps || strcmp(subdir, 'results')

        % Only save the specified channels
        if nargin > 5
            if ndims(image) == 5
                image = image(:,:,:,:,channels);
            else
                image = image(:,:,:,channels);
            end
        end
        
        %config
        all_at_once = strcmpi(data.processing_option, 'all_at_once');
        dir = fullfile(data.write_dir, subdir);
        sep_dir = fullfile(dir, 'sep');
        pixdim = data.nii_pixdim(2:4);
        
        % Make directories
        if ~exist(dir, 'dir')
            if ~mkdir(dir); disp(['Could not create folder: ' dir]); end;
        end
        if ~all_at_once && ~exist(sep_dir, 'dir')
            if ~mkdir(sep_dir); disp(['Could not create folder: ' sep_dir]); end;
        end

        % calc and save only phase if image is complex
        if isreal(image)
            save_image = image;
        else
            save_image = angle(image);
        end
        
        % if image is 5D, save each channel in seperate 4D image
        if ndims(image) == 5
            for cha = 1:size(image,5)
                if all_at_once
                    filename = fullfile(dir, [name '_c' num2str(channels(cha)) '.nii']);
                else
                    % name for single slice
                    filename = fullfile(sep_dir, getNameForSlice(name, data.slices(i), channels(cha)));
                end

                image_nii = make_nii(single(save_image(:,:,:,:,cha)), pixdim);
                centre_and_save_nii(image_nii, filename, image_nii.hdr.dime.pixdim); 
            end
        else
            if all_at_once
                filename = fullfile(dir, [name '.nii']);
            else
                % name for single slice
                filename = fullfile(sep_dir, getNameForSlice(name, data.slices(i)));
            end

            image_nii = make_nii(single(save_image), pixdim);
            centre_and_save_nii(image_nii, filename, image_nii.hdr.dime.pixdim);
        end
    end
    
end


function [ filename ] = getNameForSlice(name, slice, cha)
%GETNAMEFORSLICE get a standard name for a slice
    if nargin == 3
        filename = [name '_c' num2str(cha) '_' num2str(slice) '.nii'];
    else
        filename = [name '_' num2str(slice) '.nii'];
    end

end


function saveStruct(data, slice, subdir, save)
%SAVESTRUCT saves all images from save to disk
    if ~isempty(save)
        for i = 1:length(save.filenames)
            saveNii(data, slice, subdir, save.images{i}, save.filenames{i});
        end
    end
end


function [ rpo ] = getRPOSelector(data, compl, weight, i)
%GETRPOSELECTOR calls the selected method for obtaining the RPO and smooths
%it
    
    %% get RPO
    if strcmpi(data.combination_mode, 'composer')
        rpo = getRPO_composer(data, i);
    elseif strcmpi(data.combination_mode, 'MCPC3D')
        rpo = getRPO_MCPC3D(data, compl);
    elseif strcmpi(data.combination_mode, 'MCPC3Di')
        [rpo, save] = getRPO_MCPC3D_improved(data, compl);
        saveStruct(data, i, 'MCPC3Di_getRPO', save); clear save;
    elseif strcmpi(data.combination_mode, 'MCPCC')
        rpo = getRPO_MCPCC(compl);
    elseif strcmpi(data.combination_mode, 'add')
        rpo = complex(ones(data.dim(1:4),'single'));
    elseif strcmpi(data.combination_mode, 'umpire') || strcmpi(data.combination_mode, 'cusp3')
        [rpo, save] = getRPO_aspireUmpire(data, compl, weight);
        saveStruct(data, i, 'cusp3_getRPO', save); clear save;
    elseif strcmp(data.combination_mode, 'cusp2') || strcmpi(data.combination_mode, 'aspire')
        [rpo, save] = getRPO_aspire(data, compl);
        saveStruct(data, i, 'aspire_getRPO', save); clear save;
    end

    %% smooth RPO
    % composer and constant RPOs are already smooth
    if ~strcmpi(data.combination_mode, 'composer') && ...
       ~strcmpi(data.combination_mode, 'add') && ...
       ~strcmpi(data.combination_mode, 'MCPCC')
   
        saveNii(data, i, 'steps', rpo, 'rpo_not_smooth', data.write_channels);
        rpo = smoothRPO(data, rpo, weight);
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
    for cha = 1:data.n_channels
        smoothed_rpo(:,:,:,cha) = weightedGaussianSmooth(rpo(:,:,:,cha), sigma_size, weight);
    end

end


function [ ratio ] = calcRatio(nEchoes, combined, compl)
    ratio = zeros(size(combined));
    
    for eco = 1:nEchoes;
        magSum = sum(abs(compl(:,:,:,eco,:)), 5);
        ratio(:,:,:,eco) = abs(combined(:,:,:,eco)) ./ magSum(:,:,:);
    end
end


function concatImagesInSubdirs(data)
%searches for sep dirs in subdirs and concatenates images

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

            concatImages(folder, data.slices, name);
        end
    end

end


function concatImages(folder, data_slices, image_name)

        sep_dir = fullfile(folder, 'sep');
        filename = fullfile(folder, [image_name '.nii']);

        filename_list = cell(1,length(data_slices));
        for sl = 1:length(data_slices)
            filename_list{sl} = fullfile(sep_dir, getNameForSlice(image_name, data_slices(sl)));
        end

        unix_command = ['fslmerge -z ' filename ' ' strjoin(filename_list)];
        [res, ~] = unix(unix_command);

        if res
           disp(['Error concatenating ' image_name '. (' unix_command ')']);
        else
            unix(['rm ' strjoin(filename_list)]);
            % only removes directory if it is already empty
            [~,~,~] = rmdir(sep_dir);
        end
        
        % make headers right
        centre_hdr_nii(filename);
        
end


%% MCPC3Di slice by slice option
function mcpc3diSliceBySlice(data)

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
        
        hip(:,:,i) = calculateHip(data.mcpc3di_echoes, compl);
    end
    clear compl;
    
    unwrappingData = data;
    unwrappingData.unwrapping_method = data.mcpc3di_unwrapping_method;
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
        rpo = getRPO_MCPC3D_improved_sliceBySlice(data, compl, unwrappedHip(:,:,i));
        
        %% smooth RPO
        rpo_smooth = smoothRPO(data, rpo);

        %% remove RPO
        compl = removeRPO(data.n_echoes, compl, rpo_smooth);

        %% combine
        combined = sum(compl, 5);
        
        %% unwrap combined phase
        combined_phase(:,:,i,:) = angle(combined);

        %% save to disk
        saveNii(data, i, 'results', combined_phase(:,:,i,:), 'combined_phase');
        if data.save_steps
            % ratio
            ratio = calcRatio(data.n_echoes, combined, compl);
            saveNii(data, i, 'steps', rpo_smooth, 'rpo_smooth', data.write_channels);
            saveNii(data, i, 'steps', compl, 'no_rpo', data.write_channels);
            saveNii(data, i, 'steps', ratio, 'ratio');
            saveNii(data, i, 'steps', weight, 'weight');
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
