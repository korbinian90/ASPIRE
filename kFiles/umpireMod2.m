function [ unwrapped_phase, save ] = umpireMod2( phase, TEs, weight, varargin )
%UNTITLED like UMPIRE, but uses instead of dpd e1+e2-e3 for wrap-free phase
%   This method works only with combined phase images without RPO

    %TODO: better real size sigma
    sigma = 2;
    lower_bound = -pi;

    % calculate the wrapped version of e1+e2-e3 in range [lower_bound; lower_bound + 2*pi]
    first_omega = 3 * phase(:,:,:,1) - phase(:,:,:,3);
    first_omega = mod(first_omega - lower_bound, 2*pi) + lower_bound;
    
    % toggle smoothing
    if nargin > 3 && varargin{1} == 0
        fm = first_omega;
    else
        fm = weightedGaussianSmooth(first_omega, sigma, weight);    
    end
%     time = TEs(1) + TEs(2) - TEs(3);
    time = 3 * TEs(1) - TEs(3);
    
    unwrapped_phase = zeros(size(phase));
    for echo = 1:3
       [unwrapped_phase(:,:,:,echo), save] = umpireUnwrap(phase(:,:,:,echo), TEs(echo), fm, time);
    end
    
    save = toSave(save, fm, 'fm');
    save = toSave(save, first_omega, 'first_omega');
    save = toSave(save, unwrap, 'unwrap');
    
end

