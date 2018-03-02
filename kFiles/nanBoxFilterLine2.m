function output_line = nanBoxFilterLine2(line, boxSize)
%WEIGHTEDBOXFILTERLINE Weighted Box Smoothing along first dimension
%   Detailed explanation goes here

    % there should be no division by zero error, if the weights are
    % strictly positive (ensured in calling function
    % weightedGaussianSmooth)

    if mod(boxSize, 2) == 0
        warning('boxSize is even!')
        warning('Changed to next smaller odd integer')
        boxSize = boxSize - 1;
    end
    
    r = floor(boxSize / 2);

    maxFills = r;
    
    % padding of line for easy calculation
    zz = nan(r * 2, size(line, 2));
    line = [zz; line; zz];
    
    dimension = size(line);
    
    % initialize sums
    lSum = zeros(1, dimension(2));
    output_line = line;
    nFills = 0;
    nValids = 0;
    
    mode = 0;
    
    %% smoothing along
    
    for i = 1:dimension(1)-r-1
        % check for mode change
        switch mode % 0 NaN-mode  1 normal-mode  2 fill-mode
            case 1
                if isnan(line(i+r+1,1))
                    mode = 2;
                end
            case 0
                if isnan(line(i+r,1))
                    nValids = 0;
                else
                    nValids = nValids + 1;
                end
                if nValids > boxSize
                    %backfill
                    lSum = sum(line(i-r-1:i+r-1,:),1);
                    if isnan(line(i+r+1,1))
                        mode = 2;
                    else
                        mode = 1;
                    end
                end
            case 2
                if isnan(line(i+r,1))
                    nFills = nFills + 1;
                    if nFills > maxFills
                        mode = 0;
                        nFills = 0;
                        lSum = zeros(1, dimension(2));
                        nValids = 0;
                    end
                elseif ~isnan(line(i+r+1,1))
                    mode = 1;
                    nFills = 0;
                end
        end
        
        % perform operation
        switch mode
            case 1
                lSum = lSum + line(i+r,:);
                lSum = lSum - line(i-r-1,:);
                output_line(i,:) = lSum / boxSize;
            case 2
                lSum = lSum - line(i-r-1,:);
                output_line(i,:) = (lSum - line(i-r,:)) / (boxSize - 2);
                
                line(i+r,:) = 2 * output_line(i,:) - output_line(i-r,:);
                output_line(i+r,:) = line(i+r,:);
                lSum = lSum + line(i+r,:);
        end
    end
    % remove padding
    output_line = output_line(2*r+1:end-2*r,:);
end