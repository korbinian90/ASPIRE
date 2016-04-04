%% DATA
% KS_20160215
data.read_dir = '/net/mri.meduniwien.ac.at/projects/radiology/fmri/data/keckstein/kshmueli/20150604';
data.filename_mag = fullfile(data.read_dir, 'mag.nii');
data.filename_magTextHeader = fullfile(data.read_dir, 'mtext_header.txt');
data.filename_phase = fullfile(data.read_dir, 'pha.nii');
data.filename_phaseTextHeader = fullfile(data.read_dir, 'ptext_header.txt');
write_dir = '/sacher/melange/users/keckstein/data/ASPIRE/ks_problemZeroes/';

%% OPTIONS
data.processing_option = 'slice_by_slice'; % choices: 'slice_by_slice', 'all_at_once'
unwrapping_method_after_combination = 'none'; % choices: 'umpire', 'cusack', 'mod', 'est', 'none'
data.combination_mode = 'aspire'; % choices: 'aspire', 'cusp3', 'composer', 'MCPCC', 'MCPC3D', 'MCPC3Di', 'add'
data.save_steps = 1; % write processing steps
data.write_channels = [1 2]; % channels to be written for processing steps
data.parallel = 4; % specify number of workers for parallel computation (only in slice_by_slice mode) 

%unwrapping_method_for_combination = 'none'; % choices: 'cusack', 'none'
% data.prelude_mask_threshold = 200;
% data.rpo_weigthedSmoothing = 1;

% data.slices = 5:6; % limit the range to these slices (only in slice_by_slice mode)
% data.channels = [6 7]; % channels used for combination
% data.mcpc3di_echoes = [2 3]; % echoes used for MCPC3Di combination