function hermitian = calculateHip(data, compl)

    if isfield(data,'mcpc3di_echoes')
        echo = data.mcpc3di_echoes;
    else
        echo = [1 2];
    end
    
    % GET HIP
    hermitian = compl(:,:,:,echo(2),:) .* conj(compl(:,:,:,echo(1),:));
    hermitian = sum(hermitian,5);
    
end