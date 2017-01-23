function rpo = calculateAspirePO(compl, e)
    echo = [1 2];
    if nargs == 2
        echo = e;
    end
    nChannels = size(compl, 5);
    % hermitian inner product combination
    hermitian = calculateHip(compl, echo);
    
    % subtract hermitian to get RPO
    size_compl = size(compl);
    rpo = complex(zeros([size_compl(1:3) nChannels], 'single'));
    for cha = 1:nChannels
        rpo_temp = double(compl(:,:,:,echo(1),cha)) .* double(conj(hermitian));
        rpo(:,:,:,cha) = single(rpo_temp ./ abs(rpo_temp));
    end
end

