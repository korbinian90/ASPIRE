function sizeInVoxel = mmToVoxel( sizeInMM, nii_pixdim )
    sizeInVoxel = sizeInMM / nii_pixdim(2);
end
