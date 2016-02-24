function [ scaled_fm, save ] = getFM_umpire( TEs, compl, weight )
%GETFM_U Gets expected phase evolution to first echo
%   Detailed explanation goes here
    
    % hermitian inner product
    fm1 = sum(compl(:,:,:,2,:) .* conj(compl(:,:,:,1,:)), 5);
    fm2 = sum(compl(:,:,:,3,:) .* conj(compl(:,:,:,2,:)), 5);
    dt1 = TEs(2) - TEs(1);
    dt2 = TEs(3) - TEs(2);
    
    [fm, time, save] = umpire2(angle(fm2), dt2, angle(fm1), dt1, weight);
    
    scaled_fm = fm * (TEs(1)/time);
    
end

