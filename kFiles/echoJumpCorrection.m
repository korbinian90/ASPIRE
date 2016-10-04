function [ unwrapped ] = echoJumpCorrection( unwrapped, unwrappedHip )

    % formula 7 of MCPC3D paper
    diff = (unwrapped(:,:,:,2) - (unwrapped(:,:,:,1) + unwrappedHip)) / (2*pi);

    % take the middle part of the image as mask
    mask = zeros(size(unwrappedHip));
    [x,y,z,~] = size(mask);
    mask_x = round(x * 0.3):round(x * 0.7);
    mask_y = round(y * 0.3):round(y * 0.7);
    mask_z = round(z * 0.4):round(z * 0.6);
    mask(mask_x,mask_y,mask_z) = 1;
    
    n2pi = round(median(diff(mask == 1)));
    
    unwrapped = unwrapped - n2pi;
    
end

