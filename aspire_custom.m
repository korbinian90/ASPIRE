%   Combining phase images from multi-channel coils.  
%   Published as ASPIRE https://doi.org/10.1002/mrm.26963
%   Korbinian Eckstein (korbinian90@gmail.com) and Simon Robinson (simon.robinson@meduniwien.ac.at). 25.03.2022
%
%   current_version_number = 2.0
clear data
aspire_startup

%% DATA
data.read_dir = 'testFileDir';
data.filename_mag = fullfile(data.read_dir, 'mag/Image.nii'); % 5D NIfTI input (x,y,z,eco,cha)
data.filename_phase = fullfile(data.read_dir, 'phase/Image.nii');
data.write_dir = 'testWriteDir';

%% OPTIONS
data.poCalculator = AspirePoCalculator; % AspireBipolarPoCalculator('non-linear correction') for bipolar acquisitions (at least 3 echoes)
data.smoother = NanGaussianSmoother; % NanGaussianSmoother, GaussianBoxSmoother (=default)

data.processing_option = 'all_at_once'; % all_at_once, slice_by_slice (slice_by_slice requires fslmerge)
% data.aspire_echoes = [2 4]; % if other echoes than [1 2] (= default) are used for ASPIRE calculation

%% OUTPUT of calculation steps
data.save_steps = 1; % write processing steps for debugging
data.write_channels = [1 2]; % channels for which processing steps are written

%% run ASPIRE
tic;
run(Aspire(data));
disp(['Whole calculation took: ' secs2hms(toc)]);
disp(['Files written to: ' data.write_dir]);
