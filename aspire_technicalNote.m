clear all;
aspire_startup
for run=1
    %% Config
    net_app = '/net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/nifti_and_ima/';
    cspa_dir = fullfile(net_app, '19860116CSPA_201506051000/nifti/');
    abrc_dir = fullfile(net_app, '19870415ABRC_201506151016/nifti/');
    krek_dir = fullfile(net_app, '19900813KREK_201506161100/nifti/');
    cspaComp_dir = fullfile(net_app, '19860116CSPA_201601281600/nifti/');
    mtjv_dir = fullfile(net_app, '19900620MTJV_201602011545/nifti/');
    sacher_dir = '/sacher/melange/users/keckstein/data/ASPIRE/';
    local_dir = '/data/korbi/data/CUSP/matlab_data/';
    data.combination_mode = 'aspire';
    
    switch run
        case 1
            % 
            read_dir = mtjv_dir;
            readfile_dirs = {'67','69'};
%             data.readfile_dirs_ute = {'45','47'};
            data.processing_option = 'slice_by_slice'; % choices: 'slice_by_slice', 'all_at_once'
            data.unwrapping_method_after_combination = 'mod'; % choices: 'umpire', 'cusack', 'mod', 'est'
            data.combination_mode = 'aspire'; % choices: 'aspire', 'cusp3', 'composer', 'MCPCC', 'MCPC3D', 'MCPC3Di', 'add'
            data.parallel = 8; % specify number of workers for parallel computation (only in slice_by_slice mode) 
%             data.slices = 5:6; % limit the range to these slices (only in slice_by_slice mode)
            write_dir = fullfile(sacher_dir, 'technicalNote/MTJV/');
    end
    
    data.read_dir = read_dir;
    data.filename_mag = fullfile(read_dir, readfile_dirs{1}, 'reform', 'Image.nii');
    data.filename_phase = fullfile(read_dir, readfile_dirs{2}, 'reform', 'Image.nii');
    data.filename_magTextHeader = fullfile(read_dir, readfile_dirs{1}, 'text_header.txt');
    data.filename_phaseTextHeader = fullfile(read_dir, readfile_dirs{2}, 'text_header.txt');
    data.write_dir = write_dir;
    data.wrap_estimator_range = [-5 3];
    tic;
    aspire(data);
    disp(['Whole calculation takes: ' secs2hms(toc)]);
    disp(['Files written to: ' write_dir]);
end
