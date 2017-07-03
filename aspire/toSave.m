function [ save ] = toSave( save, image, name )
%TOSAVE creates a struct, which can be written to disk in aspire.m
% use saveStruct() in aspire.m to to save this.

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

