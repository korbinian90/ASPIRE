function saveNii(data, i, subdir, image, name, channels)
%SAVENII Saves the image file to the specified folder
% can save slice or whole image, when data.processing_option=='all_at_once'

    % always save results, save rest only if data.save_steps
    if data.save_steps || strcmp(subdir, 'results')

        % Only save the specified channels
        if nargin > 5
            if ndims(image) == 5
                image = image(:,:,:,:,channels);
            else
                image = image(:,:,:,channels);
            end
        end
        
        %config
        all_at_once = strcmpi(data.processing_option, 'all_at_once');
        dir = fullfile(data.write_dir, subdir);
        sep_dir = fullfile(dir, 'sep');
        pixdim = data.nii_pixdim(2:4);
        
        % Make directories
        if ~exist(dir, 'dir')
            if ~mkdir(dir); disp(['Could not create folder: ' dir]); end;
        end
        if ~all_at_once && ~exist(sep_dir, 'dir')
            if ~mkdir(sep_dir); disp(['Could not create folder: ' sep_dir]); end;
        end

        % calc and save only phase if image is complex
        if isreal(image)
            save_image = image;
        else
            save_image = angle(image);
        end
        
        % if image is 5D, save each channel in seperate 4D image
        if ndims(image) == 5
            for cha = 1:size(image,5)
                if all_at_once
                    filename = fullfile(dir, [name '_c' num2str(channels(cha)) '.nii']);
                else
                    % name for single slice
                    filename = fullfile(sep_dir, getNameForSlice(name, data.slices(i), channels(cha)));
                end

                image_nii = make_nii(single(save_image(:,:,:,:,cha)), pixdim);
                centre_and_save_nii(image_nii, filename, image_nii.hdr.dime.pixdim); 
            end
        else
            if all_at_once
                filename = fullfile(dir, [name '.nii']);
            else
                % name for single slice
                filename = fullfile(sep_dir, getNameForSlice(name, data.slices(i)));
            end

            image_nii = make_nii(single(save_image), pixdim);
            centre_and_save_nii(image_nii, filename, image_nii.hdr.dime.pixdim);
        end
    end
    
end
