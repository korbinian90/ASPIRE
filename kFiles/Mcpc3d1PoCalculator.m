classdef Mcpc3d1PoCalculator < PoCalculator
    
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
        
        dims = size(compl);
        self.po = complex(zeros([dims(1:3) dims(5)], 'single'));
        for iCha = 1:dims(5)
            disp(['Unwrapping channel ' int2str(iCha)]);
            
            unwrapped = cusackUnwrapComplex(compl(:,:,:,1:2,iCha));
            unwrapped = echoJumpCorrection(unwrapped, unwrappedHip, self.TEs);

            %% Phase Offset calculation
            % formula 5 of MCPC3D paper
            self.po(:,:,:,iCha) = exp(1i * (unwrapped(:,:,:,1) * self.TEs(2) - unwrapped(:,:,:,2) * self.TEs(1)) / (self.TEs(2) - self.TEs(1)));
        end
    end
   
end
    
end

