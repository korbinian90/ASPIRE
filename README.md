# ASPIRE / MCPC-3D-S for MATLAB
MRI phase combination algorithm for combining channels of array-coils

ASPIRE requires 2 * TE1 = TE2

## Other versions
* [compiled MCPC-3D-S](https://github.com/korbinian90/CompileMRI.jl/releases) (no MATLAB required)  
* [MCPC-3D-S written in julia](https://github.com/korbinian90/MriResearchTools.jl)

# Publication
[Eckstein, K. et al. Computationally efficient combination of multi-channel phase data  
from multi-echo acquisitions (ASPIRE). Magn. Reson. Med. 79, 2996–3006 (2018).](https://onlinelibrary.wiley.com/doi/abs/10.1002/mrm.26963)

# Patent
There is a patent on [ASPIRE](https://patents.google.com/patent/US10605885B2/en) and a license is required for commercial use.
However, it is not a medical product, which means that the method may not be used for diagnosis in humans.

For scientific purposes no licence is required and the method can be applied free of charge.

# Installation
Clone the repository with git or download as ZIP file.

# Configuration
Set the data location and parameters in aspire_custom.m  
Uncombined magnitude and phase images are required as NIfTI files.  
The dimensions of the input NIfTI files have to be [x, y, z, echo, channel].

# Run ASPIRE
Start aspire_custom.m

# Additional Requirements
For the slice_by_slice option (low memory usage), fslmerge is required.

# Advanced
Experimental stuff is shared in the folder kFiles

# Old version
The version 1.6 can be accessed here: https://github.com/korbinian90/ASPIRE/tree/old_github
