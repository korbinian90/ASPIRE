function [ unwrapped ] = echoJumpCorrection( unwrapped, unwrappedHip, TEs)

    %% produce mask
    % take the middle part of the image as mask
    mask = zeros(size(unwrappedHip));
    [x,y,z,~] = size(mask);
    mask_x = round(x * 0.3):round(x * 0.7);
    mask_y = round(y * 0.3):round(y * 0.7);
    mask_z = round(z * 0.4):round(z * 0.6);
    mask(mask_x,mask_y,mask_z) = 1;
    
    %% first echo
    hipEchoTime = TEs(2) - TEs(1);
    diff1 = (unwrapped(:,:,:,1) - (unwrappedHip * (TEs(1) / hipEchoTime))) / (2*pi);
        
    n2pi1 = round(median(diff1(mask == 1)));
    
    unwrapped(:,:,:,1) = unwrapped(:,:,:,1) - (n2pi1 * 2 * pi);
    
    
    %% second echo
    % formula 7 of MCPC3D paper
    diff2 = (unwrapped(:,:,:,2) - (unwrapped(:,:,:,1) + unwrappedHip)) / (2*pi);

    n2pi2 = round(median(diff2(mask == 1)));
    
    unwrapped(:,:,:,2) = unwrapped(:,:,:,2) - (n2pi2 * 2 * pi);
    
end
