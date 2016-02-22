function [ smoothed_image, smoothed_weight ] = weightedGaussianSmooth( input_image, sigma, varargin )
%WEIGHTEDGAUSSIANSMOOTH Smoothes each slice with gaussian blur
%   Approximation of gaussian smoothing with 3 times box filtering
%   The execution time is independent on kernel size

    % number of box filterings
    n_box = 3;

    k_size = sigma;
    dimension = size(input_image);
    if isempty(varargin) || isempty(varargin{1})
        weighting_image = ones(dimension);
    else
        weighting_image = double(abs(varargin{1}));
        % to avoid singularities
        weighting_image(weighting_image <= 0) = min(weighting_image(weighting_image > 0));
    end
    if size(weighting_image) ~= dimension
       error('weight and image must have same dimensions!');
    end
    smoothed_image = input_image;
    smoothed_weight = weighting_image;
    
    % do for each higher dimension
    slice_loop = dimension(3:end);
    if isempty(slice_loop)
        slice_loop = 1;
    end
    
    for slice = 1:slice_loop
        % box filter with 6 times transposing image -> 3 times horizontal and 3
        % times vertical filtered
        s_image = double(smoothed_image(:,:,slice));
        s_weight = double(smoothed_weight(:,:,slice));
        for i = 1:2*n_box
            [s_image, s_weight] = weightedBoxFilterLine(s_image', k_size, s_weight');
        end
        smoothed_image(:,:,slice) = single(s_image);
        smoothed_weight(:,:,slice) = single(s_weight);
    end
    
end

