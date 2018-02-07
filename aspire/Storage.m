classdef Storage < FlexibleStorage
    
    methods
        
        function obj = Storage(data)
            obj = obj@FlexibleStorage(data.write_dir, 'results');
            obj.saveSteps = data.save_steps;
            obj.slicewise = strcmp(data.processing_option, 'slice_by_slice');
            obj.pixdim = data.nii_pixdim(2:4);
            if data.channels
                obj.channels = data.channels;
            else
                obj.channels = 1:data.n_channels;
            end
            obj.filenames.mag = data.filename_mag;
            obj.filenames.phase = data.filename_phase;
            obj.singleEcho = data.singleEcho;
            obj.echoes = [];
            if isfield(data, 'echoes')
                obj.echoes = data.echoes;
            end
        end
    end
    
end

