function [ phase, save ] = preludeUnwrap( write_dir, phase, weight )
%PRELUDEUNWRAP Unwraps the phase using PRELUDE
% NOT WORKING!!
%   TODO: for multi echo multi slice


    % make directory
    prelude_dir = fullfile(write_dir, 'prelude');
    s = mkdir(prelude_dir);
    if s == 0
        error('No permission to make directory %s/m', prelude_dir);
    end
    % temporary prelude filenames
    fn_weight = fullfile(prelude_dir, 'weight.nii');
    fn_phase = fullfile(prelude_dir, 'phase.nii');
    fn_phaseUnwrappedOnce = fullfile(prelude_dir, 'phaseUnwrappedOnce.nii');
    % temporary phun filenames
    fn_phun_weight = fullfile(prelude_dir, 'phun_weight.nii');
    fn_phun_phase = fullfile(prelude_dir, 'phun_phase.nii');
    fn_phun_unwrapped = fullfile(prelude_dir, 'phun_unwrapped.nii');
    prelude_threshold = 600;
    prelude_command = sprintf('prelude -a %s -p %s -o %s -t %i -s -v',  fn_weight, fn_phase, fn_phaseUnwrappedOnce, prelude_threshold);
     
    %% prelude unwrapping   
    disp('Prelude unwrapping step');
    weight = permute(weight, [1 3 2]);
    phase = permute(phase, [1 3 2]);
    
    save_nii(make_nii(single(weight)), fn_weight);
    save_nii(make_nii(single(phase)), fn_phase);

    unix(prelude_command);

    phase_nii = load_nii(fn_phaseUnwrappedOnce);
    phase = single(phase_nii.img);
    save = toSave([], phase, 'first_prelude_unwrap');
   
    
    %% phun unwrapping
    disp('Phun unwrapping step');
    weight = permute(weight, [1 3 2]);
    phase = permute(phase, [1 3 2]);
    
    save_nii(make_nii(single(weight)), fn_phun_weight);
    save_nii(make_nii(single(phase)), fn_phun_phase);

    phun_command = sprintf('phun --polar -2 %s %s -o %s', fn_phun_weight, fn_phun_phase, fn_phun_unwrapped);
    
    unix(phun_command);

    phase_nii = load_nii(fn_phun_unwrapped);
    phase = single(phase_nii.img);
    save = toSave(save, phase, 'second_phun_unwrap');
    
    
    
    %% remove temporal files
    %delete(fn_weight, fn_phase);
    %rmdir(prelude_dir);

end
