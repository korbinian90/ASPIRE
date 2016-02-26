function hermitian = calculateHip(echo, compl)
    
    complexDifference = compl(:,:,:,echo(2),:) .* conj(compl(:,:,:,echo(1),:));
    hermitian = sum(complexDifference,5);
    
end