function [ data ] = getHeaderInfo( data )
%GETHEADERINFO gets important information from nifti header
%   Detailed explanation goes here

    if ~isfield(data, 'noHeader')
        % used variables of data
        filename_mag = data.filename_mag;
        filename_phase = data.filename_phase;
        filename_magTextHeader = data.filename_magTextHeader;
        filename_phaseTextHeader = data.filename_phaseTextHeader;

        magData = fromHeader(filename_mag, filename_magTextHeader);
        phaseData = fromHeader(filename_phase, filename_phaseTextHeader);

        if ~isequal(magData, phaseData)
            error('Magnitude and phase have different Header info!');
        end

        fprintf('There are %i echoes and %i channels\n', magData.n_echoes, magData.n_channels);

        % Output variables
        data.n_echoes = magData.n_echoes;
        data.n_channels = magData.n_channels;
        data.nii_dim = magData.nii_dim;
        data.dim = magData.dim;
        data.nii_pixdim = magData.nii_pixdim;
        data.TEs = magData.TEs;
    end
end


function headerData = fromHeader(filename_nii, filename_header)
    
    %   Find out how many echoes and channels there are
    raw_hdr = load_nii_hdr(filename_nii);
    n_echoes = raw_hdr.dime.dim(5);
    n_channels = raw_hdr.dime.dim(6);
    
    %   Get voxel dimensions
    nii_dim = raw_hdr.dime.dim;
    dim = nii_dim(2:4);
    nii_pixdim = raw_hdr.dime.pixdim;
    
    %   find out the echo times
    if exist(filename_header, 'file')==2
        for j=1:n_echoes
            TEs(j) = str2double(search_text_header_func(filename_header, sprintf('alTE[%s]', num2str(j-1))));
        end
    else
        error(['Could not find ' filename_header]);
    end
    
    headerData.n_echoes = n_echoes;
    headerData.n_channels = n_channels;
    headerData.nii_dim = nii_dim;
    headerData.dim = dim;
    headerData.nii_pixdim = nii_pixdim;
    headerData.TEs = TEs;
end
