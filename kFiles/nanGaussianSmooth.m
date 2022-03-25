function smoothed_image = nanGaussianSmooth(input_image, sigma, mask)
%NANGAUSSIANSMOOTH Smoothes each slice with gaussian blur
%   Approximation of gaussian smoothing with 3 times box filtering
%   The execution time is independent on kernel size

    % number of box filterings
    n_box = 4;
    
    dimension = size(input_image);
    
    % set NaN/Inf values to NaN
    input_image(~isfinite(input_image)) = NaN;
    
    smoothed_image = input_image;
    
    % do for each higher dimension
    slice_loop = dimension(3:end);
    if isempty(slice_loop)
        slice_loop = 1;
    end
    boxSizes = getBoxSizesIncreasing(sigma, n_box, 10);
    for iSlice = 1:slice_loop
            repMask = repmat(mask(:,:,iSlice), [1 1 size(input_image, 5)]);
            slice_image = squeeze(smoothed_image(:,:,iSlice,:));
            slice_image(~repMask) = NaN;
        for i = 1:2*n_box
            
            slice_image = permute(flipdim(slice_image, 1), [2 1 3]); % rot90
            
            for iLine = 1:size(slice_image, 2)
                % box filter with 6 times transposing image -> 3 times horizontal and 3
                % times vertical filtered
                s_image = double(squeeze(slice_image(:,iLine,:)));
                s_image = nanBoxFilterLine2(s_image, boxSizes(floor((i + 1) / 2)));
                slice_image(:,iLine,:) = single(s_image);
            end
        end
%         
%         slice_image(~isfinite(slice_image)) = 1000;
%         for i = 5:2*n_box
%             slice_image = permute(slice_image, [2 1 3]);
%             for iCha = 1:size(slice_image, 3)
%                 slice_image(:,:,iCha) = single(weightedBoxFilterLine(double(slice_image(:,:,iCha)), boxSizes(floor((i + 1) / 2))));
%             end
%         end
        
        smoothed_image(:,:,iSlice,:) = slice_image;
    end
    
end
