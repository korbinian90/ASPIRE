function boxSizes = getBoxSizesWithSmall(sigma, n, smallestSize)
    % modified from https://www.peterkovesi.com/papers/FastGaussianSmoothing.pdf
    % n elements of smallestSize are taken
    
    insertAt = [3 4];
    nSmallest = size(insertAt, 2);
    
    smallestSize = ceil(smallestSize / 2) * 2 - 1;
    smallestSize(smallestSize < 3) = 3;
    
    wIdeal = sqrt(((12 * sigma .^ 2 - nSmallest * (smallestSize .^ 2 - 1)) / (n - nSmallest)) + 1);
    
    wl = floor(wIdeal);
    
    wl = wl - 1 * mod(wl + 1, 2);
    
    wu = wl + 2;
				
    mIdeal = (12*sigma.^2 - (n-nSmallest)*(wu.^2 - 1) - nSmallest * (smallestSize.^2 - 1)) ./ (wl.^2 - wu.^2);
    
    m = round(mIdeal);
    %// var sigmaActual = Math.sqrt( (m*wl*wl + (n-m)*wu*wu - n)/12 );
				
    boxSizes = zeros(length(sigma), n - nSmallest);
    for j = 1:length(sigma)
        for i = 1:(n - nSmallest)
            if (i <= m(j))
                boxSizes(j, i) = wl(j);
            else
                boxSizes(j, i) = wu(j);
            end
        end
    end
    for i = insertAt
        boxSizes = [boxSizes(:,1:i-1) smallestSize' boxSizes(:,i:end)];
    end
 end