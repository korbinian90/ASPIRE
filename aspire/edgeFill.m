function complSens = edgeFill(complSens, kernelSize)
    kernelSize = ceil(kernelSize);
    valid = getObjectArea(sum(abs(complSens), 5));
    
    for it = 1:2
        for iSlice = 1:size(complSens, 3)
            for iLine = 1:size(complSens, 2)
                [v, line] = calculateLine(valid(:,iLine,iSlice), complSens(:,iLine,iSlice,1,:), kernelSize);
                complSens(:,iLine,iSlice,1,:) = line;
                valid(:,iLine,iSlice) = v;
            end
        end
        complSens = permute(complSens, [2 1 3 4 5]);
        valid = permute(valid, [2 1 3]);
    end
end

function valid = getObjectArea(mag)
    valid = mag > max(mag(:)) / 30;
end

function [valid, line] = calculateLine(valid, line, kernelSize)
    for it = 1:2
        validPoints = 0;
        i = 0;
        line = flipdim(line, 1);
        valid = flipdim(valid, 1);
        while i < size(line, 1) - 1
            i = i + 1;
            if valid(i)
                validPoints = validPoints + 1;
                if ~valid(i+1) && validPoints >= 5
                    radius = min(kernelSize - 1, floor((validPoints - 1) / 2));
                    
                    nSteps = min(radius, size(valid, 1) - i);
                    count = 1;
                    for j = i+2:i+nSteps
                        if valid(j)
                            break
                        end
                        count = count + 1;
                    end
                    nSteps = min(nSteps, count);
                    
%                     line(i+1:i+nSteps,:) = extrapolate(line(i-2*radius+1:i,:), radius, nSteps);
                    line(i:i+nSteps,:) = extrapolate(line(i-2*radius:i-1,:), radius, nSteps + 1);
                    valid(i+1:i+nSteps,:) = true;
                    validPoints = 0;
                    i = i + nSteps + 1;
                end
            end
        end
    end
end

function points = extrapolate(line, radius, nSteps)
    lengthLine = size(line, 1);
    
    lSum = sum(line(2:end,:));
    points = [line; zeros(nSteps, size(line, 2))];
    for iP = lengthLine+1:lengthLine+nSteps
        points(iP,:) = (2 / (lengthLine - 1)) * lSum - points(iP-lengthLine,:);
        lSum = lSum - line(iP-lengthLine+1,:) + points(iP,:);
    end
    points = points(end-nSteps+1:end,:);
end

%
% function points = extrapolate(line, radius, nSteps)
%     m = size(line,1);             % number of points
%     X = [ones(m,1), (1:m)'];   % forming X of X beta = y
%     points = zeros(nSteps, size(line,2));
%     for iCha = 1:size(line,2)
%         y = line(:,iCha);                % forming y of X beta = y
%         betaHat = (X' * X) \ (X' * y);
%         points(:,iCha) = betaHat(1) + betaHat(2) * (m+1:m+nSteps);
%     end
% end

% function points = extrapolate(line, radius, nSteps)
%     nAverage = 3;
%     s1 = sum(line(1:nAverage,:),1) / nAverage;
%     s2 = sum(line(end-nAverage+1:end,:),1) / nAverage;
%     y = (s2 - s1) / (size(line, 1) - 3);
%     points = ones(nSteps,1) * s2 + (2:(nSteps + 1))' * y;
% end

% 
% function points = extrapolate(line, radius, nSteps)
%     r2p1 = 2 * radius + 1;
%     line = [line; zeros(nSteps, size(line,2))];
%     line(r2p1,:) = r2p1 * line(radius + 1,:) - sum(line, 1);
%     for i = 1:nSteps - 1
%         line(r2p1 + i,:) = r2p1 * (line(radius + 1 + i,:) - line(radius + i,:)) + line(i);
%     end
%     points = line(r2p1:end,:);
% end



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
