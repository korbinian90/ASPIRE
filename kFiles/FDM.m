classdef FDM
    %FDM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function deviation = getFrequencyDeviation(compl)
            nEchoes = size(compl, 4);
            for iEco = 1:nEchoes
                compl(iEco,:) .* conj(compl(1));
            end
        end
        
        function estimatePools(compl)
            objfcn = @(v, t2, f) sum(v .* exp(2i * pi * f - t / t2));
            %objfcn = @(v) v(1) .* exp(2i * pi * v(2) - t / v(3)) + v(4) .* exp(2i * pi * v(5) - t / v(6));
            opts = optimoptions(@lsqnonlin, 'Display', 'off'); % @lsqcurvefit
            v0 = [100, 100];
            t20 = [100, 100];
            f0 = [100, 100];
            [vestimated,resnorm,residuals,exitflag,output] = lsqnonlin(objfcn,x0,[],[],opts);
            vestimated,resnorm,exitflag,output.firstorderopt
            
    end
    
end

