function hermitian = calculateHip(compl, e)
    echo = [1 2];
    if nargin == 2
        echo = e;
    end

    dim = size(compl);
    hermitian = zeros(dim(1:3));
    for iCha = 1:size(compl, 5)
        complexDifference = compl(:,:,:,echo(2),iCha) .* conj(compl(:,:,:,echo(1),iCha));
        hermitian = hermitian + complexDifference;
    end
    
end