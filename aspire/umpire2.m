function [ fieldmap, time, save ] = umpire2(phase_diff2, dt2, phase_diff1, dt1, weight, sigma, varargin)
%UMPIRE2 Calculates the UMPIRE fieldmap from phase differences.
% weight can be [] for no weighting

dt_diff = dt2 - dt1;
%% Getting first omega
first_omega = umpire_pd_range(phase_diff2, phase_diff1, -pi);

% toggle smoothing
if ~isempty(varargin) && (varargin{1} == 0)
    smoothed_omega = first_omega;  
else
    smoothed_omega = weightedGaussianSmooth(first_omega, sigma, weight);
end

%% Unwrapping phase differences
fieldmap2 = umpireUnwrap(phase_diff2, dt2, smoothed_omega, dt_diff);
fieldmap1 = umpireUnwrap(phase_diff1, dt1, smoothed_omega, dt_diff);
% TODO: better weighting for the fieldmap addition (mag weighted?)
fieldmap = fieldmap1 + fieldmap2;
time = dt1 + dt2;

save = toSave([], first_omega, 'first_omega');
save = toSave(save, fieldmap1, 'fieldmap1');
save = toSave(save, fieldmap2, 'fieldmap2');

end
