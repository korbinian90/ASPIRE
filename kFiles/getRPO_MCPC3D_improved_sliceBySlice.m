function [ rpo ] = getRPO_MCPC3D_improved_sliceBySlice( data, compl, weight, slice, unwrappedHip )
%GETRPO_MCPC3D_IMPROVED_SLICEBYSLICE Summary of this function goes here
%   Detailed explanation goes here

    TEs = data.TEs;
    if isfield(data,'mcpc3di_echoes')
        echo = data.mcpc3di_echoes;
    else
        echo = [1 2];
    end
    
%     % UNWRAPPED HIP
%     image_nii = load_nii_slice(filenameUnwrappedHip, slice);
%     unwrappedHip = image_nii.img; clear image_nii;
    
    % SCALE
    scale = TEs(1) / (TEs(echo(2)) - TEs(echo(1)));
    unwrappedHip = unwrappedHip * scale;
    
    % SUBTRACT FROM INDIV CHANNELS AT ECHO 1
    dim = size(compl);
    nChannels = size(compl,5);
    rpo = zeros([dim(1:3) nChannels]);
    for cha = 1:size(rpo,4)
        rpo(:,:,:,cha) = angle(compl(:,:,:,1,cha)) - unwrappedHip;
    end
    
    % get complex rpo with mag=1
    rpo = exp(1i * single(rpo));

end

