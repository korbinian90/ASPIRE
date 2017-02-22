classdef ComposerPoCalculator < PoCalculator
    
properties
    TEs
    fovReductionFactor
    filenames
end

methods
    % override
    function setup(self, data)
        setup@PoCalculator(self, data); % call super-method
        self.TEs = data.TEs;
        self.fovReductionFactor = 4;
        self.setFilenames(data);
    end
    % override
    function preprocess(self)    
        self.coregisterUte();
    end
    % override
    function calculatePo(self, ~)
        self.po = self.storage.getPhase(self.filenames.utePhaseCoreg);
    end
end

methods (Access = private)
    
    function setFilenames(self, data)
        composer_dir = self.storage.getPath();
        fn.uteCombMag = fullfile(data.read_dir, num2str(str2double(data.readfile_dirs_ute{1}) + 1), 'Image.nii');
        fn.geCombMag = fullfile(data.read_dir, num2str(str2double(data.readfile_dirs{1}) + 1), 'reform', 'Image.nii');    
        fn.utePhase = fullfile(data.read_dir, data.readfile_dirs_ute{2}, 'reform', 'Image.nii');
        fn.coregMat = fullfile(composer_dir, 'coreg_mat.m');
        fn.utePhaseCoreg = fullfile(composer_dir, 'ute_phase_coreg.nii');
        
        self.filenames = fn;
    end
    
    function coregisterUte(self)
        fn = self.filenames;
        flirt_command = sprintf('flirt -in %s -ref %s -omat %s', fn.uteCombMag, fn.geCombMag, fn.coregMat);
        [res, message] = unix(flirt_command);
        if res ~= 0
            error('Coregistration failed with error: %s', message);
        end    

        % apply coreg mat
        flirt_command = sprintf('flirt -interp nearestneighbour -in %s -ref %s -applyxfm -init %s -out %s', fn_ute_phase, fn_ge_m_comb, fn_coreg_mat, fn_ute_phase_coreg);
        [res, message] = unix(flirt_command);
        if res ~= 0
            error('Coregistration failed with error: %s', message);
        end
    end
end

end

