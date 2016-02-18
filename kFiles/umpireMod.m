function [ unwrapped_phase, save ] = umpireMod( phase, TEs, weight, varargin )
%UNTITLED like UMPIRE, but uses instead of dpd e1+e2-e3 for wrap-free phase
%   This method works only with combined phase images without RPO

    %TODO: better real size sigma
    sigma = 3;
    lower_bound = -pi;

    % calculate the wrapped version of e1+e2-e3 in range [lower_bound; lower_bound + 2*pi]
    time = TEs(1) + TEs(2) - TEs(3);
    first_omega = phase(:,:,:,1) + phase(:,:,:,2) - phase(:,:,:,3);
    first_omega = mod(first_omega - lower_bound, 2*pi) + lower_bound;

    % toggle smoothing (4th argument 0 -> no smoothing)
    if nargin > 3 && varargin{1} == 0
        smoothed_omega = first_omega;
    else
        smoothed_omega = weightedGaussianSmooth(first_omega, sigma, weight);    
    end
    
    unwrapped_phase = zeros(size(phase));
    
    [unwrapped_phase(:,:,:,1)] = umpireUnwrap(phase(:,:,:,1), TEs(1), smoothed_omega, time);

    fm = weightedGaussianSmooth(unwrapped_phase(:,:,:,1), 1, weight);
    
    for echo = 2:length(TEs)
       [unwrapped_phase(:,:,:,echo)] = umpireUnwrap(phase(:,:,:,echo), TEs(echo), fm, TEs(1));
    end
    
    save = toSave([], fm, 'fm');
    save = toSave(save, first_omega, 'first_omega');
    save = toSave(save, smoothed_omega, 'smoothed_omega');

end

