function [ scaled_fm, save ] = getFM_umpire( TEs, compl, weight, sigma )
%GETFM_U Gets expected phase evolution to first echo
%   Detailed explanation goes here
    
    fm1 = calculateHip(compl, [1 2]);
    fm2 = calculateHip(compl, [2 3]);
    dt1 = TEs(2) - TEs(1);
    dt2 = TEs(3) - TEs(2);
    
    [fm, time, save] = umpire2(angle(fm2), dt2, angle(fm1), dt1, weight, sigma);
    
    scaled_fm = fm * (TEs(1)/time);
    
end

