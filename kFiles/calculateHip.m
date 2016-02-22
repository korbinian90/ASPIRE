function hermitian = calculateHip(echo, compl)
    
    % GET HIP
    hermitian = compl(:,:,:,echo(2),:) .* conj(compl(:,:,:,echo(1),:));
    hermitian = sum(hermitian,5);
    
end