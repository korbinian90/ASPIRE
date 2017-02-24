classdef Mcpc3dsSlicewisePoCalculator < Mcpc3dsPoCalculator
    
properties
    dim
    slices
    filenameUnwrappedHip
end

methods
    % override
    function setup(self, data)
        setup@Mcpc3dsPoCalculator(self, data); % call super-method
        self.slices = data.slices;
        self.dim = data.dim;
        self.filenameUnwrappedHip = 'unwrappedHip.nii';
    end
    % override
    function preprocess(self)
        hip = complex(zeros(self.dim, 'single'));
        for i = 1:length(self.slices)
            % iSlice is the anatomical slice (i is the loop counter)
            iSlice = self.slices(i);
            self.storage.setSlice(iSlice);
            compl = self.storage.importImages();
            hip(:,:,i) = calculateHip(compl);
        end
        unwrappedHip = cusackUnwrap(angle(hip), abs(hip));
        unwrappedHip = self.scaleHip(unwrappedHip);
   
        self.storage.write(unwrappedHip, self.filenameUnwrappedHip);
    end 
end

methods (Access = protected)
    % override
    function unwrappedHip = getUnwrappedHip(self, ~)
        unwrappedHip = self.storage.getImageInPath(self.filenameUnwrappedHip);
    end
end
    
end

