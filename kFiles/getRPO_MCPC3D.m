function [ rpo, save ] = getRPO_MCPC3D( data, compl )
%GETRPO_MCPC3D calculates the RPO of multi-echo phase using MCPC-3D-I

    TEs = data.TEs;
    if isfield(data,'mcpc3d_echoes')
        echo = data.mcpc3d_echoes;
    else
        echo = [1 2];
    end
    
%     if data.parallel
%         matlabpool('open', min(2,data.parallel));
%     end

    hermitian = sum(compl(:,:,:,echo(2),:) .* conj(compl(:,:,:,echo(1),:)),5);
    unwrappedHip = cusackUnwrap(angle(hermitian), abs(hermitian));
    
    save = toSave([], hermitian, 'hermitian');
    save = toSave(save, unwrappedHip, 'hermitian_unwrapped');
    
    dims = size(compl);
    rpo = complex(zeros([dims(1:3) dims(5)], 'single'));
    for cha = 1:data.n_channels
        disp(['Unwrapping channel ' int2str(cha)]);
        weight = abs(compl(:,:,:,[echo(1) echo(2)],cha));
        
        if isfield(data, 'mcpc3d_unwrapping') && strcmp(data.mcpc3d_unwrapping, 'cusack')
            unwrapped = cusackUnwrap(angle(compl(:,:,:,[echo(1) echo(2)],cha)), weight);
        else
            unwrapped = preludeUnwrap(data, angle(compl(:,:,:,[echo(1) echo(2)],cha)), weight, cha);
        end
        
        unwrapped = echoJumpCorrection(unwrapped, unwrappedHip);
        
        save = toSave(save, unwrapped, ['unwrapped_c' int2str(cha)]);
        
        %% Phase Offset calculation
        % formula 5 of MCPC3D paper
        rpo_angle = (unwrapped(:,:,:,1) * TEs(echo(2)) - unwrapped(:,:,:,2) * TEs(echo(1))) / (TEs(echo(2)) - TEs(echo(1)));
        %save = toSave(save, rpo_angle, ['rpo_angle_c' int2str(cha)]);
        % get complex rpo with mag=1
        rpo(:,:,:,cha) = single(exp(1i * squeeze(rpo_angle)));  
    end
    disp('Finshed MCPC3D Unwrapping');
%     
%     if data.parallel
%        matlabpool('close');
%     end

    
end
