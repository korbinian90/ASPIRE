classdef RefScan < PoCalculator
    %REFSCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        storedPo
        filenames
        refScan
        flipDim
        permuteDim
    end
    
    methods
        function obj = RefScan(refScan)
            obj.refScan = refScan;
        end
        
        %override
        function setup(self, data)
            setup@PoCalculator(self, data);
            
            refData = self.refScan;
%             refData.processing_option = 'all_at_once';
            refData.read_dir = data.read_dir;
            refData.write_dir = fullfile(data.write_dir, 'referenceScan');
            refData.save_steps = 1;
            refData.write_channels = 1:32; % temp
            self.refScan = refData;
            
            self.flipDim = 0;
            if isfield(refData, 'flip_dim')
                self.flipDim = refData.flip_dim;
            end
            self.permuteDim = [];
            if isfield(refData, 'permute_dim')
                self.permuteDim = refData.permute_dim;
            end
            
            self.setFilenames(data, self.refScan);
            self.storedPo = StoredPo([], [], self.filenames.coregSensReal, self.filenames.coregSensImag);
            self.storedPo.setup(data);
        end
        
        function setFilenames(self, data, refScan)
            fn.coregSensReal = fullfile(data.write_dir, 'poCalculation', 'refSensReal.nii');
            fn.coregSensImag = fullfile(data.write_dir, 'poCalculation', 'refSensImag.nii');
            fn.sensReal = fullfile(refScan.write_dir, 'steps', 'realSens.nii');
            fn.sensImag = fullfile(refScan.write_dir, 'steps', 'imagSens.nii');
            fn.refMagCombined = refScan.filename_magCombined;
            fn.magCombined = data.filename_magCombined;
            fn.verifyCoreg = fullfile(data.write_dir, 'poCalculation', 'verifyCoreg.nii');
            fn.coregMat = fullfile(data.write_dir, 'poCalculation', 'coregMat.m');
            
            fn.flipDir = fullfile(refScan.write_dir, 'flip');
            fn.flipRefMagCombined = fullfile(fn.flipDir, 'refMagCombined.nii');
            fn.flipSensReal = fullfile(fn.flipDir, 'sensReal.nii');
            fn.flipSensImag = fullfile(fn.flipDir, 'sensImag.nii');
            
            self.filenames = fn;
        end
        
        %implement
        function preprocess(self)
            if exist(self.filenames.coregSensReal, 'file')
                display('Coregistered Prescan found!');
                display('Not calculating again');
            else
                display('-------------------------------------');
                display('Calculating reference scan');
                
                run(Aspire(self.refScan));
                self.coregister();
                
                display('Finished calculating reference scan');
                display('-------------------------------------');
            end
        end
        
        %implement
        function calculatePo(self, ~)
            self.storedPo.calculatePo();
            self.po = self.storedPo.po;
        end
        
        function coregister(self)
            if self.flipDim || ~isempty(self.permuteDim)
                disp(['Flipping dimension ' int2str(self.flipDim) ' of reference scan']);
                self.flipDimension(self.flipDim, self.permuteDim);
            end
            
            disp('Coregistering reference scan');
            fn = self.filenames;
            getCoregMat_command = sprintf('flirt -in %s -ref %s -out %s -omat %s', fn.refMagCombined, fn.magCombined, fn.verifyCoreg, fn.coregMat);
            applyCoregSensReal_command = sprintf('flirt -in %s -ref %s -applyxfm -init %s -out %s', fn.sensReal, fn.magCombined, fn.coregMat, fn.coregSensReal);
            applyCoregSensImag_command = sprintf('flirt -in %s -ref %s -applyxfm -init %s -out %s', fn.sensImag, fn.magCombined, fn.coregMat, fn.coregSensImag);

            unix(getCoregMat_command)
            unix(applyCoregSensImag_command)
            unix(applyCoregSensReal_command)
        end
        
        function setSlice(self, iSlice)
            self.storedPo.setSlice(iSlice);
        end
        
        function flipDimension(self, dim, permuteDims)
            fn = self.filenames;
            mkdir(fn.flipDir);
            
            self.flipImage(fn.refMagCombined, fn.flipRefMagCombined, dim, permuteDims);
            self.flipImage(fn.sensReal, fn.flipSensReal, dim, permuteDims);
            self.flipImage(fn.sensImag, fn.flipSensImag, dim, permuteDims);
            
            fn.refMagCombined = fn.flipRefMagCombined;
            fn.sensReal = fn.flipSensReal;
            fn.sensImag = fn.flipSensImag;
            self.filenames = fn;
        end
        
        function flipImage(self, original, flipped, dim, permuteDims)
            permuteDims = [permuteDims 4 5 6 7];
            nii = load_nii(original);
            img = nii.img;
            if dim
                img = flipdim(img, dim);
            end
            if ~isempty(permuteDims)
                img = permute(img, permuteDims);
            end
            pixdim = nii.hdr.dime.pixdim([1 permuteDims + 1]);
            
            
            centre_and_save_nii(make_nii(img), flipped, pixdim);
        end
        
        % override
        function smoothPo(~, ~)
        end
        
        % overrid
        function setSens(~,~)
        end
    end
    
end

