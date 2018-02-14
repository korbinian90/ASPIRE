function [ data ] = getHeaderInfo( data )
%GETHEADERINFO gets important information from nifti header
%   Detailed explanation goes here
    
    phaseData = fromNiiHeader(data.filename_phase);
    
    if isfield(data, 'filename_mag')
        magData = fromNiiHeader(data.filename_mag);
        if ~isequal(phaseData, magData)
            warning('Magnitude and phase have different Header info!');
        end
    end
    
    % Output variables
    data.n_echoes = phaseData.n_echoes;
    data.n_channels = phaseData.n_channels;
    if isfield(data, 'singleEcho') && data.singleEcho
        data.n_channels = data.n_echoes;
        data.n_echoes = 1;
    end
    data.nii_dim = phaseData.nii_dim;
    data.dim = phaseData.dim;
    data.nii_pixdim = phaseData.nii_pixdim;
    
    if isfield(data, 'filename_textHeader')
        data.TEs = fromTextHeader(data.filename_textHeader, data.n_echoes);
    end
    
    fprintf('There are %i echoes and %i channels\n', data.n_echoes, data.n_channels);
end


function TEs = fromTextHeader(filename, n_echoes)
    %   find out the echo times
    if exist(filename, 'file')==2
        for j=1:n_echoes
            TEs(j) = str2double(search_text_header_func(filename, sprintf('alTE[%s]', num2str(j-1))));
        end
    else
        error(['Could not find ' filename]);
    end
end


function data = fromNiiHeader(filename)
    %   Find out how many echoes and channels there are
    raw_hdr = load_nii_hdr(filename);
    data.n_echoes = raw_hdr.dime.dim(5);
    data.n_channels = raw_hdr.dime.dim(6);
    
    %   Get voxel dimensions
    data.nii_dim = raw_hdr.dime.dim;
    data.dim = data.nii_dim(2:4);
    data.nii_pixdim = raw_hdr.dime.pixdim;
end
