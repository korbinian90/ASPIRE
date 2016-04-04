%   Combining phase images from multi-channel coils.  
%   Based on http://www.ncbi.nlm.nih.gov/pubmed/21254207 but with some simplifications, which make it faster and more robust
%   Korbinian Eckstein (korbinian90@gmail.com) and Simon Robinson (simon.robinson@meduniwien.ac.at). 16.2.2016
%   version_number = 1.0 : 16.2.2016
%   version_number = 1.1 : 17.2.2016 : S.R. removed 'like' formulation in calls to 'zeroes' and 'ones' to give compabitility back to MATLAB7 (for these functions, at least)
%   version_number = 1.2 : 04.4.2016 : K.E. fixed problem with scaling, a lot of refactoring
%
%   current_version_number = 1.2

    
clear all; clc

%% DATA
% KS_20160215
data.read_dir = '/net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/nifti_and_ima/KS_20160215';
data.filename_mag = fullfile(data.read_dir, 'mag/Image.nii');
data.filename_magTextHeader = fullfile(data.read_dir, 'mag/text_header.txt');
data.filename_phase = fullfile(data.read_dir, 'phase/Image.nii');
data.filename_phaseTextHeader = fullfile(data.read_dir, 'phase/text_header.txt');
write_dir = '/sacher/melange/users/keckstein/data/ASPIRE/ks_magScale_test/';

%% OPTIONS
data.processing_option = 'slice_by_slice'; % choices: 'slice_by_slice', 'all_at_once'
unwrapping_method_after_combination = 'none'; % choices: 'umpire', 'cusack', 'mod', 'est', 'none'
unwrapping_method_for_combination = 'none'; % choices: 'cusack', 'none' % not used for aspire combination
data.combination_mode = 'aspire'; % choices: 'aspire', 'cusp3', 'composer', 'MCPCC', 'MCPC3D', 'MCPC3Di', 'add'
data.save_steps = 1; % write processing steps
data.write_channels = [1 2]; % processing steps for channels to be written

% data.prelude_mask_threshold = 200;
% data.rpo_weigthedSmoothing = 1;
%data.parallel = 4; % specify number of workers for parallel computation (only in slice_by_slice mode) 
% data.slices = 5:6; % limit the range to these slices (only in slice_by_slice mode)
% data.channels = [6 7]; % channels used for combination
% data.mcpc3di_echoes = [2 3]; % echoes used for MCPC3Di combination

data.write_dir = fullfile(write_dir, data.combination_mode);
data.unwrapping_method = unwrapping_method_after_combination;
data.mcpc3di_unwrapping_method = unwrapping_method_for_combination;

% run ASPIRE
tic;
aspire(data);
disp(['Whole calculation takes: ' secs2hms(toc)]);
disp(['Files written to: ' write_dir]);
