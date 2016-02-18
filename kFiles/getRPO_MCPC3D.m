function [ rpo ] = getRPO_MCPC3D( data, compl, weight )
%GETRPO_MCPC3D calculates the RPO of multi-echo phase using MCPC-3D
%   Uses echoes 2 and 3

    TEs = data.TEs;
    if isfield(data,'mcpc3di_echoes')
        echo = data.mcpc3di_echoes;
    else
        echo = [1 2];
    end
    
    if data.parallel
        matlabpool('open', min(2,data.parallel));
    end

    hermitian = sum(compl(:,:,:,echo(2),:) .* conj(compl(:,:,:,echo(1),:)),5);
    hermitian_uw = cusackUnwrap(angle(hermitian), abs(hermitian));
    
    dims = size(compl);
    rpo = complex(zeros([dims(1:3) dims(5)], 'single'));
    % correct n2pi jumps between unwrapped echoes
    for cha = 1:data.n_channels
        disp(['Unwrapping channel ' int2str(cha)]);
        weight = abs(compl(:,:,:,[echo(1) echo(2)],cha));
        unwrapped = cusackUnwrap(angle(compl(:,:,:,[echo(1) echo(2)],cha)), weight);
        % calculation of wraps
        diff = unwrapped(:,:,:,2) - unwrapped(:,:,:,1) - hermitian_uw;
        mask_weight = weight(:,:,:,1);
        mask = mask_weight > 0.5 * max(mask_weight(:));
        n2pi = round(mean(diff(mask)) / (2*pi));
        % correction for wraps
        unwrapped = unwrapped - n2pi;
        % Phase Offset formula
        rpo_angle = (unwrapped(:,:,:,1) * TEs(echo(2)) - unwrapped(:,:,:,2) * TEs(echo(1))) / (TEs(echo(2)) - TEs(echo(1)));
        % get complex rpo with mag=1
        rpo(:,:,:,cha) = single(exp(1i * squeeze(rpo_angle)));  
    end
    disp('Finshed correcting for 2pi jumps');
    
    if data.parallel
       matlabpool('close'); 
    end

    
end
