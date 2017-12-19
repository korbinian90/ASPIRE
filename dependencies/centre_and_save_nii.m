%   Simon Robinson
%   syntax centre_and_save_nii(image_nii, filename, pixdim)
%   sets the image origin to the centre of the image
%   sets the voxel dimensions to pixdim
%   saves to an nii file using save_nii
function centre_and_save_nii(image_nii, filename, pixdim)
        image_nii.hdr = centre_header(image_nii.hdr);
        image_nii.hdr = set_nii_voxel_size(image_nii.hdr, pixdim);
        save_nii(image_nii, filename);
end
