function [ save ] = toSave( save, image, name )
%TOSAVE Summary of this function goes here
%   Detailed explanation goes here

    if ~isstruct(save)
        save = struct();%'filenames', name, 'images', image);
    end
    
    if isfield(save, 'filenames') && isfield(save, 'images')
        save.filenames = [save.filenames name];
        save.images = [save.images image];
    else
        save.filenames = {name};
        save.images = {image};
    end

end

