function hermitian = calculateHip(echo, compl)
    
    dim = size(compl);
    hermitian = zeros(dim(1:3));
    for iCha = 1:size(compl, 5)
        complexDifference = compl(:,:,:,echo(2),iCha) .* conj(compl(:,:,:,echo(1),iCha));
        hermitian = hermitian + complexDifference;
    end
    
end