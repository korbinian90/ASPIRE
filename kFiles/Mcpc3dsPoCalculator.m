classdef Mcpc3dsPoCalculator < PoCalculator
    
properties
    TEs
end

methods
    % override
    function setup(self, data)
        setup@PoCalculator(self, data); % call super-method
        self.TEs = data.TEs;
    end
    % override
    function calculatePo(self, compl)
        unwrappedHip = self.getUnwrappedHip(compl);

        hipComplex = exp(1i * unwrappedHip);
        
        self.po = self.subtractFromEcho(compl, hipComplex, 1);
    end
   
end

methods (Access = protected)
    
    function unwrappedHip = getUnwrappedHip(self, compl)
        hip = calculateHip(compl);
        unwrappedHip = cusackUnwrap(angle(hip), abs(hip));
        unwrappedHip = self.scaleHip(unwrappedHip);
    end
    
    function unwrappedHip = scaleHip(self, unwrappedHip)
        scale = self.TEs(1) / (self.TEs(2) - self.TEs(1));
        unwrappedHip = unwrappedHip * scale;
    end
end
    
end

