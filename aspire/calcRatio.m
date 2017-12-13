function [ ratio ] = calcRatio(nEchoes, combined, compl, doWeighted)
    ratio = zeros(size(combined));
    
    if doWeighted
        ratio = calculateRatioWeightedAspire(abs(combined), abs(compl), abs(compl));
    else
        for eco = 1:nEchoes;
            magSum = sum(abs(compl(:,:,:,eco,:)), 5);
            ratio(:,:,:,eco) = abs(combined(:,:,:,eco)) ./ magSum(:,:,:);
        end
    end
end
