function [ rpo ] = getRPO_MCPCC( compl )
%GETRPO_MCPC3D calculates the RPO of multi-echo phase using MCPC-3D
%   Detailed explanation goes here
    
    dim = size(compl);
    center = [round(dim(1)/2) round(dim(2)/2) round(dim(3)/2)];
    rpo = complex(zeros(dim(1),dim(2),dim(3),dim(5),'double'));
    for cha = 1:dim(5)
        val = angle(compl(center(1), center(2), center(3), 1, cha));
        rpo(:,:,:,cha) = exp(1i * val);
    end
    
end

