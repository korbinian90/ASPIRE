function image = edgeFill(complSens, kernelSize)
    notValid = noObjectArea(sum(abs(complSens), 4));
    dimension = size(complSens);
    
    for it = 1:2
        complSens = transpose(complSens);
        for iSlice = 1:dimension(3)
            for iLine = 1:dimension(2)
                complSens(:,iLine,iSlice,:) = calculateLine(complSens, iSlice, iLine, kernelSize);
                transpose
            end
        end
    end
end









% function line = edgeFill(line, weighting, kernelSize)
%     % config
%     threshFactor = 10;
% 
%     radius = (kernelSize - 1) / 2;
%     r2 = 2 * radius;
%     iterations = radius;
%     for it = 1:2 * iterations
%         line = line';
%         weighting = weighting';        
%         dimension = size(line);
%         
%         for iLine = 1:dimension(1)
%             weightSum = 0;
%             for i = 1:dimension(2)
%                 weightSum = weightSum + weighting(iLine,i);
%                 if i > kernelSize
%                     weightSum = weightSum - weighting(iLine,i-kernelSize);
%                     voxel = findIfOneVoxelIsLow(weighting(iLine, i-r2:i), threshFactor);
%                     if voxel % happens seldom
%                         index = voxel + i - kernelSize;
%                         % averageWeight * 
%                         averageWeight = weightSum / (kernelSize - 1);
%                         line(iLine,index) = line(iLine, i - radius) * kernelSize - (sum(line(iLine, i-r2:i)) - line(iLine, index));
%                         weighting(iLine,index) = averageWeight;
%                     end
%                     % same for weighting(iLine,i-kernelSize)
%                 end
%             end
%         end
%     end
% end
% 
% % happens often % care if it is midVoxel
% function voxel = findIfOneVoxelIsLow(voxels, threshold)
%     below = voxels < sum(voxels) / length(voxels) / threshold;
%     
%     voxel = 0;
%     if sum(below) == 1
%         voxel = below(1);
%     end
% end
