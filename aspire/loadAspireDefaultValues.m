function data = loadAspireDefaultValues(user_data)

    %% dafault configuration for combination program

    data.filename_mag = '';
    data.rpo_weigthedSmoothing = 0;
    data.aspire_echoes = [1 2];
    data.mcpc3d_echoes = [1 2];
    data.mcpc3d_unwrapping_method = 'cusack';
    data.mcpc3ds_unwrapping_method = 'cusack';
    data.slices = 1:user_data.dim(3);
    data.combination_mode = 'aspire';
    data.processing_option = 'slice_by_slice';
    data.save_steps = 0;
    data.verbose = 0;
    data.unwrapping_method = 'none';
    data.parallel = 0;
    data.wrap_estimator_range = [-2 3];
    data.write_channels = 1:4;
    if isfield(user_data, 'write_channels')
        data.write_channels_po = user_data.write_channels;
    else
        data.write_channels_po = data.write_channels;
    end
    data.channels = []; % all channels are used
    % data.echoes = []; % all echoes are used
    data.smoothingSigmaSizeInMM = 5;
    data.weighted_smoothing = 0;
    data.weightedCombination = 1;
    data.smooth3d = 0;
    data.smoother = GaussianBoxSmoother;
    data.iterativeSteps = 0;
    data.swi = 0;
    data.swiSmoother = GaussianBoxSmoother;
    data.combination = MagWeightedCombination;
    data.singleEcho = 0;
    data.singleChannelCombination = 0;
    data.combination_smoother = NanGaussianSmoother;
    data.poCalculator = AspirePoCalculator;
    data.swiCalculator = [];

end
