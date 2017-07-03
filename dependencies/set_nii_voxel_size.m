%   set_nii_voxel_size.m
%   Simon Robinson. 21/11/2007
%   sets the pixels dimension to pixdim
%   syntax: new_hdr = set_nii_voxel_size(old_hdr, pixdim)

function new_hdr = set_nii_voxel_size(old_hdr, pixdim)

new_hdr = old_hdr;
new_hdr.dime.pixdim = pixdim;

end