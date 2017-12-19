function combined = weightedCombinationAspire(image, sensitivity)
    if size(image, 5) == 1
        combined = image;
        return;
    end

    image = single(image);
    sensitivity = single(sensitivity);

    dimension = size(image);
    combined = zeros(dimension(1:(end-1)), 'single');

    for iChannel = 1:dimension(5)
        combined = combined + image(:,:,:,:,iChannel) .* sensitivity(:,:,:,:,iChannel);
    end
    combined = combined ./ sqrt(abs(combined));

end