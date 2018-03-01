classdef RefScan < PoCalculator
    %REFSCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        storedPo
        filenames
        refScan
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
%             refData = getHeaderInfo(refData);
%             if ~isfield(refData, 'singleEcho')
%                 refData.singleEcho = 0;
%             end
%             refData.channels = [];
%             refData.smoother = data.smoother;
%             refData.iterativeSteps = 0;
%             
%             %temp
%             refData.smoothingSigmaSizeInVoxel = data.smoothingSigmaSizeInVoxel;
%             refData.weighted_smoothing = data.weighted_smoothing;
%             refData.smooth3d = data.smooth3d;
%             refData.n_channels = data.n_channels;
            self.refScan = refData;
            
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
        
        % override
        function smoothPo(~, ~)
        end
        
        % overrid
        function setSens(~,~)
        end
    end
    
end

