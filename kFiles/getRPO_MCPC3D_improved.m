function [ rpo, save ] = getRPO_MCPC3D_improved( data, compl )
%GETRPO_MCPC3D calculates the RPO of multi-echo phase using MCPC-3D
%   Uses echoes 2 and 3
    
    TEs = data.TEs;
    if isfield(data,'mcpc3di_echoes')
        echo = data.mcpc3di_echoes;
    else
        echo = [1 2];
    end
    
    hermitian = calculateHip(data.mcpc3di_echoes, compl);
    
    % UNWRAP HIP
    unwrapped = cusackUnwrap(angle(hermitian), abs(hermitian)); %TODO improve weigthing
    % unwrapped = angle(hermitian); <- no unwrapping
    %[unwrapped, save] = preludeUnwrap(data.write_dir, angle(hermitian), weight); <- experimental
    
    
    % SCALE
    scale = TEs(1) / (TEs(echo(2)) - TEs(echo(1)));
    unwrapped = unwrapped * scale;
    
    % SUBTRACT FROM INDIV CHANNELS AT ECHO 1
    
    dim = size(compl);
    nChannels = size(compl,5);
    rpo = zeros([dim(1:3) nChannels]);
    for cha = 1:size(rpo,4)
        rpo(:,:,:,cha) = angle(compl(:,:,:,1,cha)) - unwrapped;
    end
    
    % get complex rpo with mag=1
    rpo = exp(1i * squeeze(rpo));
    
    save = toSave([], hermitian, 'hermitian');
    save = toSave(save, unwrapped, 'unwrapped');
    
end
