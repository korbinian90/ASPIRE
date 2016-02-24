function phase = preludeUnwrap( data, phase, weight)
%PRELUDEUNWRAP Unwraps the phase using PRELUDE
% NOT WORKING!!
%   TODO: for multi echo multi slice

%     if ~isfield(data, 'prelude_mask_threshold')
%         error('data.prelude_mask_threshold is not defined, but required for prelude. Set it according to the used magnitude.');
%     end
    
    disp('Prelude unwrapping...');
    preludeStartTime = toc;
    
    if isfield(data, 'prelude_mask_threshold')
        additionalArgument = sprintf('-t %i', data.prelude_mask_threshold);
    else
        additionalArgument = '';
    end
    
    % make directory
    prelude_dir = fullfile(data.write_dir, 'prelude');
    s = mkdir(prelude_dir);
    if s == 0
        error('No permission to make directory %s/m', prelude_dir);
    end
    % temporary prelude filenames
    fn_weight = fullfile(prelude_dir, 'weight.nii');
    fn_phase = fullfile(prelude_dir, 'phase.nii');
    fn_phaseUnwrapped = fullfile(prelude_dir, 'phaseUnwrapped.nii');
    prelude_command = sprintf('prelude -a %s -p %s -o %s %s',  fn_weight, fn_phase, fn_phaseUnwrapped, additionalArgument);
    %prelude_command = sprintf('prelude -a %s -p %s -o %s -t %i -s -v %s',  fn_weight, fn_phase, fn_phaseUnwrapped, data.prelude_mask_threshold, additionalArgument);
    
    nEchoes = size(phase,4);
    dim = size(phase);
    % save phase
    save_nii(make_nii(single(phase)), fn_phase); clear phase;
    
    % save weight with same dimension
    save_weight = zeros(dim, 'single');
    for iEcho = 1:nEchoes
        save_weight(:,:,:,iEcho) = weight;
    end
    save_nii(make_nii(single(save_weight)), fn_weight);

    unix(prelude_command);

    phase_nii = load_nii(fn_phaseUnwrapped);
    phase = single(phase_nii.img);
    
    fprintf('Prelude unwrapping took %s.\n', secs2hms(toc - preludeStartTime));
    
end
