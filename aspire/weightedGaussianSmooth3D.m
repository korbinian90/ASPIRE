function [ smoothed_image, smoothed_weight ] = weightedGaussianSmooth3D( input_image, sigma, varargin )
%WEIGHTEDGAUSSIANSMOOTH Smoothes the volume with gaussian blur
%   Approximation of gaussian smoothing with 3 times box filtering
%   The execution time is independent on kernel size
%   NaN values are treated as missing values (0-weighted)

    % number of box filterings
    n_box = 3;
    
    if ~all(isfinite(input_image(:)))
        warning('There are Inf/NaN values in input data!');
    end
    
    dimension = size(input_image);
    if isempty(varargin)
        weighting_image = ones(dimension);
    else
        weighting_image = abs(varargin{1});
        weighting_image(isnan(weighting_image)) = 0;
        % to avoid singularities
        weighting_image(weighting_image <= 0) = min(weighting_image(weighting_image > 0));
        if ~all(isfinite(weighting_image(:)))
            warning('There are Inf values in weighting data!');
        end
        if size(weighting_image) ~= dimension
            error('weight and image must have same dimensions!');
        end
    end
    % set NaN/Inf values to 0 and the weighting for those values to 0
    weighting_image(~isfinite(input_image)) = 0;
    input_image(~isfinite(input_image)) = 0;

    smoothed_image = input_image;
    smoothed_weight = weighting_image;
    
    % do for each higher dimension
    vol_loop = dimension(4:end);
    if isempty(vol_loop)
        vol_loop = 1;
    end
    
    boxSizes = getBoxSizes(sigma, n_box);
    parfor vol = 1:vol_loop
        % box filter with 3*n_box runs
        s_image = double(smoothed_image(:,:,:,vol));
        s_weight = double(smoothed_weight(:,:,:,vol));
        dim = dimension(1:3); %#ok<PFBNS>
        for i = 1:3*n_box
            s_image = permute(s_image, [2 3 1]);
            s_weight = permute(s_weight, [2 3 1]);
            dim = [dim(2) dim(3) dim(1)];
            [s_image, s_weight] = weightedBoxFilterLine(s_image(:,:), boxSizes(floor((i + 1) / 2)), s_weight(:,:));
            s_image = reshape(s_image, dim);
            s_weight = reshape(s_weight, dim);
        end
        smoothed_image(:,:,:,vol) = single(s_image);
        smoothed_weight(:,:,:,vol) = single(s_weight);
    end
    
end

