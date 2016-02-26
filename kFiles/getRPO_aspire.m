function [ rpo, save ] = getRPO_aspire(data, compl)
%GETRPO_ASPIRE calculates the RPO using the aspire method
%   Detailed explanation goes here

    % hermitian inner product combination
    hermitian = calculateHip(data.aspire_echoes, compl);
    save = toSave([], hermitian, 'scaled_fm');
    
    % subtract hermitian to get RPO
    size_compl = size(compl);
    rpo = complex(zeros([size_compl(1:3) size_compl(5)], 'single'));
    for cha = 1:data.n_channels
        rpo_temp = double(compl(:,:,:,data.aspire_echoes(1),cha)) .* double(conj(hermitian));
        rpo(:,:,:,cha) = single(rpo_temp ./ abs(rpo_temp));
    end
    
end
