function boxSizes = getBoxSizes(sigma, n)

    wIdeal = sqrt((12 * sigma .^ 2 / n) + 1);
    
    wl = floor(wIdeal);
    
    if (mod(wl, 2) == 0)
        wl = wl - 1;
    end
    
    wu = wl + 2;
				
    mIdeal = (12*sigma.^2 - n*wl.^2 - 4*n*wl - 3*n) ./ (-4*wl - 4);
    
    m = round(mIdeal);
    %// var sigmaActual = Math.sqrt( (m*wl*wl + (n-m)*wu*wu - n)/12 );
				
    boxSizes = zeros(length(sigma), n);
    for j = 1:length(sigma)
        for i = 1:n
            if (i < m(j))
                boxSizes(j, i) = wl(j);
            else
                boxSizes(j, i) = wu(j);
            end
        end
    end
 end