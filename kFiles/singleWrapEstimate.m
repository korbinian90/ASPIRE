function [ unwrapped, db0, var_guess ] = singleWrapEstimate( phase, nWraps, dTEs )

    [ unwrapped1, unwrapped2, unwrapped3, db0, var_guess ] = si_wr_est( phase(1), phase(2), phase(3), nWraps, dTEs );
    unwrapped = [unwrapped1, unwrapped2, unwrapped3];

end


function [ unwrapped1, unwrapped2, unwrapped3, db0, var_guess ] = si_wr_est( phase1, phase2, phase3, nWraps, dTEs )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    
    unwrapped1 = phase1 + (nWraps*2*pi);
    
    % initial db0 estimate
    db0 = unwrapped1/dTEs(1);
    
    % unwrap second point
    guess2 = db0 * dTEs(2);
    guess_diff2 = (guess2 - phase2) / (2*pi) ;
    wraps2 = round( guess_diff2 );
    unwrapped2 = phase2 + wraps2*2*pi;
    
    % better db0 is mean of first and second point estimate
    db0_new = (db0 + (unwrapped2/dTEs(2)) ) / 2;
    
    % use third point for estimating how well it fits
    guess3 = db0_new * dTEs(3);
    guess_diff3 = (guess3 - phase3) / (2*pi) ;
    wraps3 = round( guess_diff3 );
    unwrapped3 = phase3 + wraps3*2*pi;
    
    var_guess = abs(guess3 - unwrapped3);
    

end
