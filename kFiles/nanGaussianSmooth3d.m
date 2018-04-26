function smoothed_image = nanGaussianSmooth3d(input_image, sigma, mask)
%NANGAUSSIANSMOOTH Smoothes each slice with gaussian blur
%   Approximation of gaussian smoothing with 3 times box filtering
%   The execution time is independent on kernel size

    % number of box filterings
    nBox = 8; % should be even for symmetrical edge propagation

    if ~all(isfinite(input_image(:)))
        warning('There are Inf/NaN values in input data!');
    end
    
    % set NaN/Inf values to NaN
    input_image(~isfinite(input_image)) = NaN;
    
    smoothed_image = input_image;
    
    sz = [size(smoothed_image, 1) size(smoothed_image, 2) size(smoothed_image, 3), size(smoothed_image, 4) size(smoothed_image, 5)];
    % nan-masking
    for iCha = 1:sz(5)
        masked = smoothed_image(:,:,:,:,iCha);
        masked(mask) = NaN;
        smoothed_image(:,:,:,:,iCha) = masked;
    end
    
    % TODO: dim-dependent box sizes
    boxSizes = getBoxSizes(sigma, nBox);
    for iBox = 1:nBox
        for dimension = 1:3
            switchDirection = mod(iBox, 2);
            [outerAccessVector, offset, num] = getAccessVector(sz, dimension, switchDirection);
            accessVector = outerAccessVector;
            % TODO: parfor
            for iOuter = 1:num(2)

                for iInner = 1:num(1)
                    boxSize = boxSizes(dimension, iBox);
                    smoothed_image(accessVector) = single(nanBoxFilterLine2(double(smoothed_image(accessVector)), boxSize));

                    accessVector = accessVector + offset(1);
                end
                outerAccessVector = outerAccessVector + offset(2);
                accessVector = outerAccessVector;
            end
        end
    end
    
end

%% get vectors to acces lines in different directions from the volume
function [vec, offset, num] = getAccessVector(sz, dimension, switchDirection)
    switch dimension
        case 1
            vec = 1:sz(1);
            offset = [sz(1) sz(2) * sz(1)];
            num = [sz(2) sz(3)];
        case 2
            vec = 1:sz(1):(sz(1) * sz(2));
            offset = [1 sz(1) * sz(2)];
            num = [sz(1) sz(3)];
        case 3
            vec = 1:(sz(1) * sz(2)):prod(sz(1:3));
            offset = [1 sz(1)];
            num = [sz(1) sz(2)];
    end
    if switchDirection
        vec = vec(end:-1:1);
    end
    vec = vec' * ones(1, sz(5)) + mtimes(ones(length(vec), 1), 0:prod(sz(1:3)):(prod(sz) - 1));
end
