%   Combining phase images from multi-channel coils.  
%   Based on http://www.ncbi.nlm.nih.gov/pubmed/21254207 but with some simplifications, which make it faster and more robust
%   Korbinian Eckstein (korbinian90@gmail.com) and Simon Robinson (simon.robinson@meduniwien.ac.at). 1.11.2017
%
%   current_version_number = 1.6
clear data
aspire_startup

%% DATA
data.read_dir = 'testFileDir';
data.filename_mag = fullfile(data.read_dir, 'mag/Image.nii');
data.filename_phase = fullfile(data.read_dir, 'phase/Image.nii');
data.write_dir = 'testWriteDir';

%% OPTIONS
data.poCalculator = AspirePoCalculator; % AspireBipolarPoCalculator('non-linear correction') for bipolar acquisitions (at least 3 echoes)
data.parallel = 0; % number of workers for parallel processing; 0 = off
data.processing_option = 'slice_by_slice'; % all_at_once, slice_by_slice (slice_by_slice requires fslmerge)

% data.aspire_echoes = [2 4]; % if other echoes than [1 2] (= default) are used for ASPIRE calculation
% data.slices = 5:6; % limit the range to these slices (only in slice_by_slice mode)
% data.unwrapping_method = 'umpire'; % cusack, umpire, mod (umpire variant)

%% OUTPUT of calculation steps
data.save_steps = 0; % write processing steps for debugging
data.write_channels = [1 2]; % channels for which processing steps are written

%% run ASPIRE
tic;
aspire(data);
disp(['Whole calculation took: ' secs2hms(toc)]);
disp(['Files written to: ' data.write_dir]);
