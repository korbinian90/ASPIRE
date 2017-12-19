function [ output_line, output_weight ] = improvedBoxFilterLine(line, boxSize, varargin)
%WEIGHTEDBOXFILTERLINE Weighted Box Smoothing along second dimension
%   Detailed explanation goes here

    % there should be no division by zero error, if the weights are
    % strictly positive (ensured in calling function
    % weightedGaussianSmooth)

    radius = floor(boxSize / 2);
    dimension = size(line);
    if isempty(varargin)
        weights = ones(dimension);
    else
        weights = varargin{1};
    end
    if size(weights) ~= dimension
       error('weight and line must have same dimensions!');
    end
    % padding of line for easy calculation
    zz = zeros(dimension(1),radius);
    line = [zz line zz];
    weights = [zz weights zz];
    % initialize sums
    sum = zeros(dimension(1),1);
    smoothed_weight = zeros(dimension(1),1);
    weight_sum = zeros(dimension(1),1);
    output_line = zeros(dimension);
    output_weight = zeros(dimension);
    % prefill before starting and fill for first value
    for i = 1:radius+1
        sum = sum + (line(:,radius+i) .* weights(:,radius+i));
        weight_sum = weight_sum + weights(:,radius+i);
        % weight smoothing
        smoothed_weight = smoothed_weight + (weights(:,radius+i) .* weights(:,radius+i));
    end
    % first value
    output_line(:,1) = sum./weight_sum;
    output_weight(:,1) = smoothed_weight./weight_sum;
    % smoothing along
    r2 = 2*radius;
    for i = 2:dimension(2)
        sum = sum + (line(:,r2+i) .* weights(:,r2+i));
        weight_sum = weight_sum + weights(:,r2+i);
        sum = sum - (line(:,i-1) .* weights(:,i-1));
        weight_sum = weight_sum - weights(:,i-1);
        output_line(:,i) = sum./weight_sum;
        % weight smoothing
        smoothed_weight = smoothed_weight + (weights(:,r2+i) .* weights(:,r2+i));
        smoothed_weight = smoothed_weight - (weights(:,i-1) .* weights(:,i-1));
        output_weight(:,i) = smoothed_weight./weight_sum;
    end

end