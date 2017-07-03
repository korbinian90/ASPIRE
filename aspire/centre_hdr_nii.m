%   centre_header_file.m
%   Simon Robinson. 21/11/2007
%   Sets the origin of a NIfTI image to be the centre of the image
%   syntax: centre_header_file(filename)

function centre_hdr_nii(filename)

hdr = load_nii_hdr(filename);

% centre originator
hdr.hist.originator(1) = ceil(hdr.dime.dim(2)/2);
hdr.hist.originator(2) = ceil(hdr.dime.dim(3)/2);
hdr.hist.originator(3) = ceil(hdr.dime.dim(4)/2);
hdr.hist.originator(4) = 0;
hdr.hist.originator(5) = 0;

% set to 0 -> recalculate hdr parameters
hdr.hist.qform_code = 0;
hdr.hist.sform_code = 0;

% open file for changing, rewrite the header and close file
fid = fopen(filename,'r+');
save_nii_hdr(hdr, fid);
fclose(fid);

end