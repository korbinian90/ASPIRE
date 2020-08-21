# ASPIRE
MRI phase combination algorithm for channels of an array-coils

ASPIRE requires 2 * TE1 = TE2

# Patent
There is a patent on [ASPIRE](https://patents.google.com/patent/US10605885B2/en) and a license is required for commercial use.
However, it is not a medical product, which means that the method may not be used for diagnosis in humans.

For scientific purposes no licence is required and the method can be applied free of charge.

# Installation
Clone repository with git or download as ZIP file.

# Configuration
Set the data location and parameters in aspire_custom.m

Uncombined magnitude and phase as NIFTI file is required.

The dimensions have to be [x, y, z, echo, channel].

# Run ASPIRE
Start aspire_custom.m

# Additional Requirements
For the slice_by_slice option (low memory usage), fslmerge is required.

# Advanced
Experimental stuff in kFiles

