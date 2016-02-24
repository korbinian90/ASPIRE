%% dafault configuration for combination program

data.rpo_weigthedSmoothing = 0;
data.aspire_echoes = [1 2];
data.mcpc3di_echoes = [1 2];
data.slices = 1:user_data.dim(3);
data.combination_mode = 'aspire';
data.processing_option = 'slice_by_slice';
data.save_steps = 1;
data.verbose = 0;
data.unwrapping_method = 'none';
data.parallel = 0;
data.wrap_estimator_range = [-2 3];
data.write_channels = 1:4;
data.weighted_smoothing = 1;
data.channels = []; % all channels are used
data.smoothingKernelSize = 5;