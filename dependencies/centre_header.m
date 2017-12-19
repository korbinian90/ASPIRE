%   centre nii header files - put the origin at the centre of the image
%   syntax new_nii_hdr = centre_header(old_nii_hdr)

function nii_hdr = centre_header(nii_hdr)

nii_hdr.hist.originator(1) = ceil(nii_hdr.dime.dim(2)/2);
nii_hdr.hist.originator(2) = ceil(nii_hdr.dime.dim(3)/2);
nii_hdr.hist.originator(3) = ceil(nii_hdr.dime.dim(4)/2);
nii_hdr.hist.originator(4) = 0;
nii_hdr.hist.originator(5) = 0;

disp('');

end