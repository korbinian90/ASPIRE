function [ unwrapped, save ] = umpireUnwrap(wrapped, w_time, est_fm, fm_time)
%UMPIRE_UNWRAP Uses the fieldmap (no wraps) as a template to unwrap the phase

    phase_guess = est_fm * (w_time / fm_time);
    n_wraps = round( (phase_guess - wrapped) / (2*pi) );
    unwrapped = wrapped + 2*pi*n_wraps;

    save = toSave([], n_wraps, 'n_wraps');
    
end

