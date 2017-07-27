function combined = weightedCombination(image, sensitivity)
    
    image = single(image);
    sensitivity = single(sensitivity);

    dimension = size(image);
    combined = zeros(dimension(1:(end-1)), 'single');
    
    if length(dimension) == 4

        for iChannel = 1:dimension(4)
            combined = combined + image(:,:,:,iChannel) .* sensitivity(:,:,:,iChannel);
        end
    elseif length(dimension) == 5
        
        for iChannel = 1:dimension(5)
            combined = combined + image(:,:,:,:,iChannel) .* sensitivity(:,:,:,:,iChannel);
        end
        
    else
        error([int2str(length(dimension)) ' dimensions not implemented for function weightedCombination'])
        
    end
    combined = combined ./ sqrt(abs(combined));

end