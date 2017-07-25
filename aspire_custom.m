%   Combining phase images from multi-channel coils.  
%   Based on http://www.ncbi.nlm.nih.gov/pubmed/21254207 but with some simplifications, which make it faster and more robust
%   Korbinian Eckstein (korbinian90@gmail.com) and Simon Robinson (simon.robinson@meduniwien.ac.at). 27.3.2017
%
%   current_version_number = 1.5

%% DATA
data.read_dir = 'testFileDir';
data.filename_mag = fullfile(data.read_dir, 'mag/Image.nii');
data.filename_magTextHeader = fullfile(data.read_dir, 'mag/text_header.txt');
data.filename_phase = fullfile(data.read_dir, 'phase/Image.nii');
data.filename_phaseTextHeader = fullfile(data.read_dir, 'phase/text_header.txt');
data.write_dir = 'testWriteDir';

%% OPTIONS
data.weightedCombination = 1; % magnitude weighted combination of complex images after phase correction

data.parallel = 4; % number of workers; 0 = off
data.poCalculator = AspirePoCalculator; % AspireBipolarPoCalculator for bipolar acquisitions (at least 3 echoes)
data.processing_option = 'slice_by_slice'; % all_at_once, slice_by_slice (slice_by_slice requires fslmerge)

% data.aspire_echoes = [2 4]; % if the echoes [1 2] (= default) are not used
% data.slices = 5:6; % limit the range to these slices (only in slice_by_slice mode)
% data.unwrapping_method = 'umpire'; % cusack, umpire, mod (umpire variant)

data.save_steps = 0; % write processing steps
data.write_channels = [1 2]; % channels for which processing steps are written

%% use ASPIRE without text_header files
% data.noHeader = 1;
% data.n_echoes = 8;
% data.n_channels = 16;
% data.dim = [128 128 5]; % [x y z]
% % data.nii_dim = [5 128 128 5 8 16 1 1]; % [nDims x y z echo cha 1 1]
% data.nii_dim = [5 data.dim data.n_echoes data.n_channels 1 1]
% data.nii_pixdim = [0 1.5625 1.5625 6 1 1 1 1]; % [0 xSize ySize zSize 1 1 1 1]
% data.TEs = [5 10];

%% run ASPIRE
tic;
aspire(data);
disp(['Whole calculation took: ' secs2hms(toc)]);
disp(['Files written to: ' write_dir]);
