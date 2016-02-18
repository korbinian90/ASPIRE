function [ unwrapped_phase, debug ] = umpireModQuick( phase, TEs, weight, varargin )
%UNTITLED like UMPIRE, but uses instead of dpd e1+e2-e3 for wrap-free phase
%   This method works only with combined phase images without RPO

    %TODO: better real size sigma
    sigma = 3;
    lower_bound = -pi;

    % calculate the wrapped version of e1+e2-e3 in range [lower_bound; lower_bound + 2*pi]
    time = TEs(1) + TEs(2) - TEs(3);
    first_omega = phase(:,:,:,1) + phase(:,:,:,2) - phase(:,:,:,3);
    first_omega = mod(first_omega - lower_bound, 2*pi) + lower_bound;
    
    % toggle smoothing
    if nargin ~= 3 && varargin{1} == 0
        fm = first_omega;
    else
        fm = weightedGaussianSmooth(first_omega, sigma, weight);    
    end
    
    unwrapped_phase = zeros(size(phase));
    for echo = 1:3
       [unwrapped_phase(:,:,:,echo), debug_unwrap{echo}] = umpire_unwrap(phase(:,:,:,echo), TEs(echo), fm, time);
    end
    
    debug.fm = fm;
    debug.first_omega = first_omega;
    debug.smoothed_omega = fm;
    debug.unwrap = debug_unwrap;

end

