function boxSizes = getBoxSizesSmallFirst(sigma, n, smallestSize)
    % modified from https://www.peterkovesi.com/papers/FastGaussianSmoothing.pdf
    
    smallestSize = ceil(smallestSize / 2) * 2 - 1;
    smallestSize(smallestSize < 3) = 3;
    
    wIdeal = sqrt(((12 * sigma .^ 2 - smallestSize .^ 2 - 1) / (n - 1)) + 1);
    
    wl = floor(wIdeal);
    
    wl = wl - 1 * mod(wl + 1, 2);
    
    wu = wl + 2;
				
    mIdeal = (12*sigma.^2 - (n-1)*(wu.^2 - 1) - smallestSize.^2 + 1) ./ (wl.^2 - wu.^2);
    
    m = round(mIdeal);
    %// var sigmaActual = Math.sqrt( (m*wl*wl + (n-m)*wu*wu - n)/12 );
				
    boxSizes = zeros(length(sigma), n);
    boxSizes(:,1) = smallestSize;
    for j = 1:length(sigma)
        for i = 2:n
            if (i <= m(j))
                boxSizes(j, i) = wl(j);
            else
                boxSizes(j, i) = wu(j);
            end
        end
    end
 end