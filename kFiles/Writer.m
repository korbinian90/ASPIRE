classdef Writer < handle
    %WRITER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        superDir
        path
        saveSteps
        slice
        slicewise
        pixdim
    end
    
    methods
        
        function obj = Writer(data)
            obj.superDir = data.write_dir;
            obj.saveSteps = data.save_steps;
            obj.slicewise = strcmp(data.processing_option, 'slice_by_slice');
            obj.setSubdir('results');
            obj.pixdim = data.nii_pixdim(2:4);
        end
        
        function write(self, image, name, channels)
            if self.path
                % Only save the specified channels
                if nargin > 3
                    if ndims(image) == 5
                        image = image(:,:,:,:,channels);
                    else
                        image = image(:,:,:,channels);
                    end
                end
                
                % calc and save only phase if image is complex
                if ~isreal(image)
                    image = angle(image);
                end
                
                if ndims(image) == 5
                    for iCha = 1:size(image,5)
                        filePath = fullfile(self.path, [name '_c' num2str(channels(iCha)) '.nii']);
                        self.saveAndCenter(image(:,:,:,:,iCha), filePath);
                    end
                else
                    filePath = fullfile(self.path, [name '.nii']);
                    self.saveAndCenter(image, filePath);
                end
            end
        end

        function setSubdir(self, subdir)
            if strcmp(subdir, 'results') || self.saveSteps
                self.path = fullfile(self.superDir, subdir);
                if ~exist(self.path, 'dir')
                    if ~mkdir(self.path); disp(['Could not create folder: ' self.path]); end;
                end
            else
                self.path = '';
            end
        end
        
        function setSlice(self, slice)
            self.slice = slice;
        end
    end
    
    
    methods (Access = private)
        function saveAndCenter(self, image, path)
            if self.slicewise
                path = [path '_' num2str(self.slice)];
            end
            image_nii = make_nii(image, self.pixdim);
            centre_and_save_nii(image_nii, path, image_nii.hdr.dime.pixdim);
        end
    end
end

