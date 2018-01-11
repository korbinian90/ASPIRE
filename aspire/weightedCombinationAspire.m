function combined = weightedCombinationAspire(image, sensitivity)
    if size(image, 5) == 1
        combined = image;
        return;
    end

    image = single(image);
    sensitivity = single(sensitivity);

    dimension = size(image);
    combined = zeros(dimension(1:(end-1)), 'single');
    sensWeight = zeros(dimension(1:3), 'single');
    
    for iChannel = 1:dimension(5)
        sensWeight = sensWeight + sensitivity(:,:,:,iChannel) .^ 2;
        combined = combined + image(:,:,:,:,iChannel);
    end
    %combined = combined ./ sqrt(abs(combined));
    for iEco = 1:size(combined,4)
        combined(:,:,:,iEco) = combined(:,:,:,iEco) ./ sensWeight;
    end
    combined(~isfinite(combined)) = 0;
end