%   Modified COMPOSER as function to get smooth rpo maps
function [ data ] =  preCompute_composer(data)

    disp('Coregistering the COMPOSER reference scan ...');

    % Filenames
    composer_dir = fullfile(data.write_dir, 'composer');
    if ~exist(composer_dir, 'dir')
        s = mkdir(composer_dir);
        if s == 0
            error('No permission to make directory %s/m', data.write_dir);
        end
    end
    fn_ute_m_comb = fullfile(data.read_dir, num2str(str2double(data.readfile_dirs_ute{1}) + 1), 'Image.nii');
    fn_ge_m_comb = fullfile(data.read_dir, num2str(str2double(data.readfile_dirs{1}) + 1), 'reform', 'Image.nii');    
    fn_coreg_mat = fullfile(composer_dir, 'coreg_mat.m');
    fn_ute_phase = fullfile(data.read_dir, data.readfile_dirs_ute{2}, 'reform', 'Image.nii');
    fn_ute_phase_coreg = fullfile(composer_dir, 'ute_phase_coreg.nii');
    fn_ute_phase_smooth = fullfile(composer_dir, 'ute_phase_smooth.nii');
    
    if ~exist(fn_ute_phase_coreg, 'file')
        % get coreg mat
        flirt_command = sprintf('flirt -in %s -ref %s -omat %s', fn_ute_m_comb, fn_ge_m_comb, fn_coreg_mat);
        [res, message] = unix(flirt_command);
        if res ~= 0
            error('Coregistration failed with error: %s', message);
        end    

        % apply coreg mat
        flirt_command = sprintf('flirt -interp nearestneighbour -in %s -ref %s -applyxfm -init %s -out %s', fn_ute_phase, fn_ge_m_comb, fn_coreg_mat, fn_ute_phase_coreg);
        [res, message] = unix(flirt_command);
        if res ~= 0
            error('Coregistration failed with error: %s', message);
        end
    end
    
    disp('3D smoothing of the COMPOSER RPO ...');
    
    if ~exist(fn_ute_phase_smooth, 'file')
        % 3D smoothing
        pixdim = data.nii_pixdim(2:4);
        ute_smooth = complex(zeros([data.dim data.n_channels], 'single'));
        
        if data.parallel
            matlabpool('open', data.parallel);
            parfor cha = 1:data.n_channels
                ute_smooth(:,:,:,cha) = smooth_channelwise(fn_ute_phase_coreg, cha);
            end
            matlabpool('close');
        else
            for cha = 1:data.n_channels
                ute_smooth(:,:,:,cha) = smooth_channelwise(fn_ute_phase_coreg, cha);               
            end
        end        

        ute_smooth_nii = make_nii(single(angle(ute_smooth)), pixdim);
        centre_and_save_nii(ute_smooth_nii, fn_ute_phase_smooth, ute_smooth_nii.hdr.dime.pixdim);
    end
    
    % pass name of rpo back in data
    data.fn_ute_rpo = fn_ute_phase_smooth;
end


function ute_smooth = smooth_channelwise(fn_ute_phase_coreg, cha)

    ute_phase_nii = load_nii(fn_ute_phase_coreg, cha);
    compl = exp(pi + 1i * 2*pi/4096 * double(ute_phase_nii.img));
    real_part = weightedGaussianSmooth3D(real(compl), 5);
    imag_part = weightedGaussianSmooth3D(imag(compl), 5);
    ute_smooth = complex(real_part, imag_part);
    
end

    
    
%     new_dims = data.dim;
%     if isfield(data, 'permute')
%         permute = data.permute;
%     else
%         permute = [1 2 3 4];
%     end
%     if isfield(data, 'flipdim')
%         flipdim = data.flipdim;
%     else
%         flipdim = [];
%     end
%     smooth_rpo = zeros([new_dims data.n_channels], 'like', single(0));
%     for channel = 1:data.n_channels        
%         smooth_rpo(:,:,:,channel) = single(composer_preprocess(ute_nii.img(:,:,:,channel), permute, flipdim, new_dims));
%     end
