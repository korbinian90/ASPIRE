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
        
        hip = calculateHip(compl);

        unwrappedHip = cusackUnwrap(angle(hip), abs(hip));
        
        unwrappedHip = self.scaleHip(unwrappedHip);
        hipComplex = exp(1i * unwrappedHip);
        
        self.po = self.subtractHipFromEcho(compl, hipComplex, 1);
    end
   
end

methods (Access = private)
    function unwrappedHip = scaleHip(self, unwrappedHip)
        scale = self.TEs(1) / (self.TEs(2) - self.TEs(1));
        unwrappedHip = unwrappedHip * scale;
    end
end
    
end

