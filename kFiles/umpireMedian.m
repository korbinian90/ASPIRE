function [ unwrapped ] = umpireMedian( combined_phase, TEs, weight, varargin )
%UMPIREMEDIAN Summary of this function goes here
%   Detailed explanation goes here
    % toggle smoothing
    if isempty(varargin)
        varargin{1} = 1;
    end

    all_unwrapped = zeros([size(combined_phase) 3]);
    all_unwrapped(:,:,:,:,1) = umpireMod(combined_phase, TEs, weight, varargin{1});
    all_unwrapped(:,:,:,:,2) = umpireMod2(combined_phase, TEs, weight, varargin{1});
    all_unwrapped(:,:,:,:,3) = umpire(combined_phase, TEs, weight, varargin{1});
    % ohne smoothing!
    unwrapped = median(all_unwrapped, 5);


end

