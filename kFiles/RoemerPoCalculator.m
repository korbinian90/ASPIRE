classdef RoemerPoCalculator < PoCalculator
    
properties
    filenames
    refStorage
    subdir
end

methods
    % override
    function setup(self, data)
        setup@PoCalculator(self, data); % call super-method
        self.subdir = 'sens';
        self.setFilenames(data);
        self.refStorage = FlexibleStorage(data.write_dir, self.subdir, self.filenames.acPhase);
    end
    % override
    function preprocess(self)    
        self.calculateSensitivities();
        self.coregisterSensitivities();
    end
    % override
    function calculatePo(self, ~)
        realSens = self.storage.getImage(self.inDir(self.filenames.coregSensReal));
        imagSens = self.storage.getImage(self.inDir(self.filenames.coregSensImag));
        self.po = angle(complex(realSens, imagSens));
    end
end

methods (Access = private)
    
    function calculateSensitivities(self)
        fn = self.filenames;
        vc = self.storage.getComplex(fn.vcMag, fn.vcPhase);
        sens = self.storage.getComplex(fn.acMag, fn.acPhase);
        for iCha = 1:size(sens, 4)
            sens(:,:,:,iCha) = sens(:,:,:,iCha) ./ vc;
        end
        sens(~isfinite(sens)) = 0;
        self.refStorage.write(real(sens), fn.sensReal);
        self.refStorage.write(imag(sens), fn.sensImag);
    end
    

    function coregisterSensitivities(self)
        fn = self.filenames;
        % calculate coreg
        flirt_command{1} = sprintf('flirt -in %s -ref %s -omat %s', fn.vcMag, fn.ImageCombMag, self.inDir(fn.coregMat));
        % apply coreg
        flirt_command{2} = sprintf('flirt -in %s -ref %s -applyxfm -init %s -out %s', self.inDir(fn.sensReal), fn.ImageCombMag, self.inDir(fn.coregMat), self.inDir(fn.coregSensReal));
        flirt_command{3} = sprintf('flirt -in %s -ref %s -applyxfm -init %s -out %s', self.inDir(fn.sensImag), fn.ImageCombMag, self.inDir(fn.coregMat), self.inDir(fn.coregSensImag));
        
        display('Running FLIRT coregistration of sensitivities...')
        for cmd = flirt_command
            [res, message] = unix(cmd{1});
            if res ~= 0
                error('Coregistration failed with error: %s', message);
            end
        end
        display('Coregistration finished!')
    end    
    
    
    function setFilenames(self, data)
        fn = data.roemer_fn;
        
        fn.coregMat = 'coreg_mat.m';
        fn.sensReal = 'sens_real.nii';
        fn.sensImag = 'sens_imag.nii';
        fn.coregSensReal = 'coreg_sens_real.nii';
        fn.coregSensImag = 'coreg_sens_imag.nii';
        
        self.filenames = fn;
    end
    
    function path = inDir(self, filename)
         path = fullfile(self.refStorage.getPath(), filename);
    end
end

end

