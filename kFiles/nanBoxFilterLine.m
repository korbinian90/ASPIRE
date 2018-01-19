function output_line = nanBoxFilterLine(line, boxSize)
%WEIGHTEDBOXFILTERLINE Weighted Box Smoothing along first dimension
%   Detailed explanation goes here

    % there should be no division by zero error, if the weights are
    % strictly positive (ensured in calling function
    % weightedGaussianSmooth)

    r = floor(boxSize / 2);

    % padding of line for easy calculation
    zz = nan(r * 2, size(line, 2));
    line = [zz; line; zz];
    
    dimension = size(line);
    
    % initialize sums
    lSum = zeros(1, dimension(2));
    output_line = zeros(dimension);
    nFills = 0;
    nValids = 0;
    
    mode = 'nan';
    
    % smoothing along
    
    for i = 1:dimension(1)-r
        % check for mode change
        switch mode
            case 'normal'
                if isnan(line(i+r,1))
                    mode = 'fill';
                end
            case 'nan'
                if isnan(line(i+r,1))
                    nValids = 0;
                else
                    nValids = nValids + 1;
                end
                if nValids > boxSize
                    %backfill
                    lSum = sum(line(i-r-1:i+r-1,:),1);
                    mode = 'normal';
                end
            case 'fill'
                if isnan(line(i+r,1))
                    nFills = nFills + 1;
                    if nFills > r
                        mode = 'nan';
                        nFills = 0;
                        lSum = zeros(1, dimension(2));
                        nValids = 0;
                    end
                else
                    mode = 'normal';
                    nFills = 0;
                end
        end
            
        % perform operation
        switch mode
            case 'normal'
                lSum = lSum + line(i+r,:);
                lSum = lSum - line(i-r-1,:);
                output_line(i,:) = lSum / boxSize;
            case 'nan'
                output_line(i,:) = line(i,:);
            case 'fill'
                lSum = lSum - line(i-r-1,:);
                output_line(i,:) = (lSum - line(i-r,:)) / (boxSize - 2);
                
                line(i+r,:) = 2 * output_line(i,:) - line(i-r,:);
                lSum = lSum + line(i+r,:);
        end
    end
    output_line = output_line(2*r+1:end-2*r,:);
end