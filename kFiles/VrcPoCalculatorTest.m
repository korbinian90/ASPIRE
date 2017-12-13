addpath('/bilbo/home/keckstein/matlab/simon/modified/');

%% INPUT IMAGE
net_app = '/net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/nifti_and_ima/';
cspa_dir = fullfile(net_app, '19860116CSPA_201506051000/nifti/');
mag_nii = load_nii(fullfile(cspa_dir, '2/reform/Image.nii'));
phase_nii = load_nii(fullfile(cspa_dir, '4/reform/Image.nii'));

mag = single(mag_nii.img); clear mag_nii
mag(mag == 0) = 0.01;
phase = rescale(single(phase_nii.img), -pi, pi); clear phase_nii
compl = mag .* exp(1i * phase); clear phase

%% Config
data.smoothingKernelSizeInVoxel = 5;

%% Calculation
poCalc = VrcPoCalculator();
poCalc.setup(data);

poCalc.calculatePo(compl);
poCalc.smoothPo();
poCalc.normalizePo();
compl = poCalc.removePo(compl);

combined = weightedCombinationAspire(compl, abs(compl));

ratio =  calculateRatioWeighted(abs(combined), mag, mag);

%% SAVING
write_dir = '~/data/test/';
combinedFilename = fullfile(write_dir, 'vrcPhase.nii');
ratioFilename = fullfile(write_dir, 'vrcRatio.nii');

save_nii(make_nii(angle(combined)), combinedFilename);
save_nii(make_nii(ratio), ratioFilename);
