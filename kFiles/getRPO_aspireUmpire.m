function [ rpo, save ] = getRPO_aspireUmpire( data, compl, weight )
%GETRPO_ASPIREUMPIRE calculates the RPO with the aspireUmpire method

    % calculate scaled fieldmap
    [scaled_fm, save] = getFM_umpire(data.TEs, compl, weight);
    save = toSave(save, scaled_fm, 'scaled_fm');
    scaled_fm = exp(1i * scaled_fm);
    
    % subtract FM to get RPO
    size_compl = size(compl);
    rpo = complex(zeros([size_compl(1:3) size_compl(5)], 'single'));
    for cha = 1:data.n_channels
        rpo_temp = double(compl(:,:,:,1,cha)) .* double(conj(scaled_fm));
        rpo(:,:,:,cha) = single(rpo_temp ./ abs(rpo_temp));
    end
    
end

