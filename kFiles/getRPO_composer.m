%   Read in COMPSER rpo maps
function [ smooth_rpo ] =  getRPO_composer(data, i)

    fn_ute_rpo = data.fn_ute_rpo;

    if strcmp(data.processing_option, 'all_at_once')
        % read in full image
        ute_phase_nii = load_nii(fn_ute_rpo, [], data.channels);
    else
        % read in the slice
        ute_phase_nii = load_nii_slice(fn_ute_rpo, data.slices(i), [], data.channels);
    end
%     smooth_rpo = exp(1i * 2*pi/4096 * single(ute_phase_nii.img));
    smooth_rpo = exp(1i * ute_phase_nii.img);
    
end
