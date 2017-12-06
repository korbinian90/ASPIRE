%% dafault configuration for combination program

data.rpo_weigthedSmoothing = 0;
data.aspire_echoes = [1 2];
data.mcpc3d_echoes = [1 2];
data.mcpc3d_unwrapping_method = 'cusack';
data.mcpc3ds_unwrapping_method = 'cusack';
data.slices = 1:user_data.dim(3);
data.combination_mode = 'aspire';
data.processing_option = 'slice_by_slice';
data.save_steps = 1;
data.verbose = 0;
data.unwrapping_method = 'none';
data.parallel = 0;
data.wrap_estimator_range = [-2 3];
data.write_channels = 1:4;
data.channels = []; % all channels are used
data.smoothingSigmaSizeInMM = 5;
data.weighted_smoothing = 0;
data.weightedCombination = 1;
data.smooth3d = 0;
data.smoother = GaussianBoxSmoother;
data.noHeader = 1;
