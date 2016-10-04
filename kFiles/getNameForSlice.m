function [ filename ] = getNameForSlice(name, slice, cha)
%GETNAMEFORSLICE get a standard name for a slice
    if nargin == 3
        filename = [name '_c' num2str(cha) '_' num2str(slice) '.nii'];
    else
        filename = [name '_' num2str(slice) '.nii'];
    end

end