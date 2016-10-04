function unwrapped = preludeUnwrap( data, phase, sensitivity, channel)
%PRELUDEUNWRAP Unwraps the phase using PRELUDE 2D
% dimension = [x, y, z, echo, channel]
    if ~isfield(data, 'fn_mask')
        error('data.fn_mask has to be specified for preludeUnwrapping with slice jump correction');
    end
    
    %% get data dimension and other setup stuff
    preludeStartTime = toc;
    
    nSlices = size(phase, 3);
    nEchoes = size(phase, 4);
    
    if isfield(data, 'prelude_mask_threshold')
        additionalArgument = sprintf('-t %i', data.prelude_mask_threshold);
    else
        additionalArgument = '';
    end
    
    % make directory
    prelude_dir = fullfile(data.write_dir, 'prelude');
    if ~exist(prelude_dir, 'dir')
        s = mkdir(prelude_dir);
        if s == 0
            error('No permission to make directory %s\n', prelude_dir);
        end
    end
    
    fn_unwrapped = getFilename(prelude_dir, 'unwrapped', channel);
    if ~exist(fn_unwrapped, 'file')
        % temporary prelude filenames
        fn_sensitivity = fullfile(prelude_dir, 'weightTemp.nii');
        fn_phase = fullfile(prelude_dir, 'phaseTemp.nii');

        % prelude 2D unwrapping
        prelude_command = sprintf('prelude -a %s -p %s -o %s %s -s',  fn_sensitivity, fn_phase, fn_unwrapped, additionalArgument);

        save_nii(make_nii(phase), fn_phase);
        save_nii(make_nii(sensitivity), fn_sensitivity);

        res = unix(prelude_command);
        if res ~= 0
            error(['prelude unwrapping failed: ' res]);
        end
    else
        disp('Unwrapped image found.');
    end

    fn_slice_jump_corrected = getFilename(prelude_dir, 'sliceJumpCorrected', channel);
    if ~exist(fn_slice_jump_corrected, 'file')
        %% slice jump correction
        mask_nii = load_nii(data.fn_mask);

        unwrapped = zeros(size(phase), 'single');
        fn_unwrapped = getFilename(prelude_dir, 'unwrapped', channel);
        unwrapped_nii = load_nii(fn_unwrapped);

        for iEcho = 1:nEchoes

            % slice jump correction
            middleSlice = ceil(nSlices/2);
            slice_check_order = [middleSlice:1:nSlices middleSlice:-1:1];

            for iSlice = slice_check_order
                this_slice = squeeze(unwrapped_nii.img(:,:,iSlice,iEcho));
                this_slice_mask = squeeze(mask_nii.img(:,:,iSlice));
                this_median = getMedian(this_slice, this_slice_mask);

                if iSlice ~= middleSlice % don't compare to the middleSlice (calculate the median only)
                    n_two_pi_jumps = round((last_median - this_median) / (2*pi));

                    if ~isnan(n_two_pi_jumps) && (n_two_pi_jumps ~= 0)
                        this_slice(this_slice ~= 0) = this_slice(this_slice ~= 0) + n_two_pi_jumps * (2*pi);
                        unwrapped_nii.img(:,:,iSlice,iEcho) = this_slice;
                        this_median = this_median + n_two_pi_jumps * (2*pi);
                    end
                end
                last_median = this_median;
            end
        end

        save_nii(unwrapped_nii, fn_slice_jump_corrected);
    else
        unwrapped_nii = load_nii(fn_slice_jump_corrected);
        disp('slice corrected image found.');
    end
    unwrapped(:,:,:,:) = unwrapped_nii.img;  
    fprintf('Prelude unwrapping took %s.\n', secs2hms(toc - preludeStartTime));
end

function filename = getFilename(prelude_dir, name, channel)
    filename = fullfile(prelude_dir, [name '_c' int2str(channel) '.nii']);
end

function median = getMedian(image, mask)
    median = nanmedian(image(mask == 1));
end
