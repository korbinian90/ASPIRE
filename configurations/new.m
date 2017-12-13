clear data
addpath('/bilbo/home/keckstein/matlab/korbinian/aspire/aspire');
addpath('/bilbo/home/keckstein/matlab/korbinian/aspire/dependencies');
addpath('/bilbo/home/keckstein/matlab/korbinian/aspire/kFiles');
addpath('/bilbo/home/keckstein/matlab/simon/modified');

 %% Config
net_app = '/net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/nifti_and_ima/';
% p_dir = fullfile(net_app, '/19701007SMRB_20171103/nifti/');
p_dir = fullfile(net_app, '/19860116CSPA_201710191700/nifti/');
% p_dir = '/net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/KE_sorting_spot/prismaUnc/17.11.22-142934-STD-1.3.12.2.1107.5.2.43.67088/nifti/';
output_dir = '/home/keckstein/data/';

study_dir = 'fdm/test/parameterEstimation/';
id_read_dir = p_dir;
id_readfile_dirs_aspire = {'31', '32'};

combinations = {'aspireBipolar'};

for co = combinations

    data.unwrapping_method = 'none';
    data.read_dir = id_read_dir;
    data.write_dir = fullfile(output_dir, study_dir, co{1});
    data.weightedCombination = 1;

    if strcmpi(co{1}, 'mcpc3d')
        readfile_dirs = id_readfile_dirs_mcpc3d;
        data.parallel = 0;
        data.processing_option = 'all_at_once';
        data.poCalculator = Mcpc3d1PoCalculator;
    elseif strcmpi(co{1}, 'mcpc3ds')
        readfile_dirs = id_readfile_dirs_mcpc3d;
        data.parallel = 0;
        data.processing_option = 'all_at_once';
        data.poCalculator = Mcpc3dsPoCalculator;
    elseif strcmpi(co{1}, 'vrc')
        readfile_dirs = id_readfile_dirs_aspire;
        data.parallel = 0;
        data.processing_option = 'all_at_once';
        data.poCalculator = VrcPoCalculator;
    elseif strcmpi(co{1}, 'aspire')
        readfile_dirs = id_readfile_dirs_aspire;
        data.parallel = 12;
        data.processing_option = 'slice_by_slice';
        data.poCalculator = AspirePoCalculator;
%         data.smoothingKernelSizeInMM = 10;
%         data.weighted_smoothing = 1;
%         data.aspire_echoes = [2 4];
    elseif strcmpi(co{1}, 'aspireBipolar')
        readfile_dirs = id_readfile_dirs_aspire;
        data.parallel = 0;
%         data.echoes = 2:2:8
        data.processing_option = 'slice_by_slice';
        data.poCalculator = AspireBipolarPoCalculator('non-linear correction');
        data.slices = 30:31;
%         data.weightedSmoothing = 1;
        data.smoother = GaussianBoxSmoother;
        data.iterativeSteps = 10;
%         data.smoothingSigmaSizeInMM = 500
    elseif strcmpi(co{1}, 'roemer')
        readfile_dirs = id_readfile_dirs_aspire;
        data.roemer_fn.vcMag = fullfile(data.read_dir, id_readfile_dirs_vc{1}, 'Image.nii');
        data.roemer_fn.vcPhase = fullfile(data.read_dir, id_readfile_dirs_vc{2}, 'Image.nii');
        data.roemer_fn.acMag = fullfile(data.read_dir, id_readfile_dirs_ac{1}, 'reform', 'Image.nii');
        data.roemer_fn.acPhase = fullfile(data.read_dir, id_readfile_dirs_ac{2}, 'reform', 'Image.nii');
        data.roemer_fn.ImageCombMag = fullfile(data.read_dir, num2str(str2double(readfile_dirs{1}) + 1), 'reform', 'Image.nii');
        data.parallel = 0;
        data.processing_option = 'all_at_once';
        data.smooth3d = 1;
        data.poCalculator = RoemerPoCalculator;
    else
        error(['Unknown method: ' co{1}]);
    end


    data.filename_mag = fullfile(data.read_dir, readfile_dirs{1}, 'reform', 'Image.nii');
    data.filename_phase = fullfile(data.read_dir, readfile_dirs{2}, 'reform', 'Image.nii');
    data.filename_textHeader = fullfile(data.read_dir, readfile_dirs{1}, 'text_header.txt');
    tic;
    aspire(data);
    disp(['Whole calculation takes: ' secs2hms(toc)]);
    disp(['Files written to: ' data.write_dir]);

end
