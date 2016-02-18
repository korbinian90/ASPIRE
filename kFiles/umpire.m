function [ unwrapped_phase, save ] = umpire( phase, TEs, weight, varargin )
%UMPIRE returns the unwrapped phases
%   Needs uneven echo spacing. The optional fourth argument toggles
%   smoothing (default: 1 = ON)
%   when weight = [], no weigthing is applied

    % toggle smoothing
    if isempty(varargin)
        varargin{1} = 1;
    end

    dt2 = TEs(3) - TEs(2);
    dt1 = TEs(2) - TEs(1);
    phase_diff = umpire_pd(phase(:,:,:,2:3), phase(:,:,:,1:2));
    [fm, time, save] = umpire2(phase_diff(:,:,:,2), dt2, phase_diff(:,:,:,1), dt1, weight, varargin{1});
    
    unwrapped_phase = zeros(size(phase));
    for echo = 1:3
       [unwrapped_phase(:,:,:,echo), ~] = umpireUnwrap(phase(:,:,:,echo), TEs(echo), fm, time);
    end
    
    save = toSave(save, fm, 'umpire2_fieldmap');
    
end

