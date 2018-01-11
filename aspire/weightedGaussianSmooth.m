function [ smoothed_image, smoothed_weight ] = weightedGaussianSmooth( input_image, sigma, varargin )
%WEIGHTEDGAUSSIANSMOOTH Smoothes each slice with gaussian blur
%   Approximation of gaussian smoothing with 3 times box filtering
%   The execution time is independent on kernel size

    % number of box filterings
    n_box = 3;

    if ~all(isfinite(input_image(:)))
        warning('There are Inf/NaN values in input data!');
    end
    
    dimension = size(input_image);
    if isempty(varargin) || isempty(varargin{1})
        weighting_image = ones(dimension);
    else
        weighting_image = double(abs(varargin{1}));
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
    slice_loop = dimension(3:end);
    if isempty(slice_loop)
        slice_loop = 1;
    end
    
    boxSizes = getBoxSizes(sigma, n_box);
    for slice = 1:slice_loop
        % box filter with 6 times transposing image -> 3 times horizontal and 3
        % times vertical filtered
        s_image = double(smoothed_image(:,:,slice));
        s_weight = double(smoothed_weight(:,:,slice));
        s_image = edgeFill(s_image, s_image, max(boxSizes));
        for i = 1:2*n_box
            [s_image, s_weight] = weightedBoxFilterLine(s_image', boxSizes(floor((i + 1) / 2)), s_weight');
        end
        smoothed_image(:,:,slice) = single(s_image);
        smoothed_weight(:,:,slice) = single(s_weight);
    end
    
end

