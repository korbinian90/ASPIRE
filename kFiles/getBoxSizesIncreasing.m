function boxSizes = getBoxSizesIncreasing(sigma, n, smallestSize)

    boxSizes = zeros(length(sigma), n);
    for j = 1:length(sigma)
        rt = 0:2:sigma(j);
        wt = floor((smallestSize + (n / 2) * rt) / 2) * 2 + 1;
        test = ((n * (n * n + 2) * rt .* rt) / 12 - n * rt .* wt + n * wt .* wt - n) / 12; % calculation of sigma^2 from wolfram alpha
        
        for iTest = 1:length(test)
            if test(iTest) > sigma(j) ^ 2
                r = rt(iTest);
                wl = wt(iTest) - (n / 2) * r;
                break
            end
        end
        
        
        for i = 1:n
            boxSizes(j, i) = wl + (i - 1) * r;
        end
    end
 end