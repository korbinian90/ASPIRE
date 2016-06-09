function [ unwrapped_phase, debug ] = umpireQuick( phase, TEs, weight, varargin )
%UMPIRE Summary of this function goes here
%   Detailed explanation goes here
    if isempty(varargin)
        varargin{1} = 1;
    end

    lower_bound = 3*pi/4;
    time = TEs(1) - 2*TEs(2) + TEs(3);
    first_omega = phase(:,:,:,1) - 2*phase(:,:,:,2) + phase(:,:,:,3);
    first_omega = mod(first_omega - lower_bound, 2*pi) + lower_bound;
    
    unwrapped_phase = zeros(size(phase));
    for echo = 1:3
       [unwrapped_phase(:,:,:,echo), debug_unwrap{echo}] = umpireUnwrap(phase(:,:,:,echo), TEs(echo), first_omega, time);
    end
    
    debug.first_omega = first_omega;
    debug.unwrap = debug_unwrap;
    
end

