clear;
aspire_startup
for run=17
    %% Config
    net_app = '/net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/nifti_and_ima/';
    cspa_dir = fullfile(net_app, '19860116CSPA_201506051000/nifti/');
    abrc_dir = fullfile(net_app, '19870415ABRC_201506151016/nifti/');
    krek_dir = fullfile(net_app, '19900813KREK_201506161100/nifti/');
    ktdo_dir = fullfile(net_app, '19920502KTDO_201610201745/nifti/');
    cspaComp_dir = fullfile(net_app, '19860116CSPA_201601281600/nifti/');
    sacher_dir = '/sacher/melange/users/keckstein/data/ASPIRE/';
    local_dir = '/data/korbi/data/CUSP/matlab_data/';
    data.combination_mode = 'aspire';
    
    switch run
        case 1
            % local test
            read_dir = cspa_dir;%fullfile(local_dir, 'CSPA/nifti/');
            readfile_dirs = {'2','4'};
%             data.readfile_dirs_ute = {'6','8'};
            data.processing_option = 'all_at_once'; % choices: 'slice_by_slice', 'all_at_once'
            data.unwrapping_method_after_combination = 'none'; % choices: 'umpire', 'cusack', 'mod', 'est'
            data.combination_mode = 'MCPC3D'; % choices: 'aspire', 'cusp3', 'composer', 'MCPCC', 'MCPC3D', 'MCPC3Di', 'add'
%             data.parallel = 0; % specify number of workers for parallel computation (only in slice_by_slice mode) 
%             data.slices = 5:6; % limit the range to these slices (only in slice_by_slice mode)
            write_dir = fullfile(local_dir, 'mcpc3d/');
            data.fn_mask = fullfile('/sacher/melange/users/keckstein/data/ASPIRE/db0_hist/bet/local_test_aspire/mask_mask.nii');

        case 2
            % composer test
            read_dir = abrc_dir;
            readfile_dirs = {'20','22'};
            data.combination_mode = 'composer';
%             data.processing_option = 'all_at_once';
%             data.slices = 20:21;
            data.parallel = 12;
            data.readfile_dirs_ute = {'6','8'};
            write_dir = fullfile(sacher_dir, 'ABRC/composerAngle/');

        case 3
            % lowResTest
            read_dir = cspa_dir;
            readfile_dirs = {'2','4'};
            write_dir = fullfile(sacher_dir, 'test/');
            data.unwrapping_method = 'none';
            %data.mcpc3di_unwrapping_method = '';
            data.processing_option = 'slice_by_slice';
            data.combination_mode = 'aspire';
        case 4
            % CSPA 0.5ms Test
            read_dir = cspa_dir;
            readfile_dirs = {'26','28'};
            write_dir = fullfile(sacher_dir, 'test/weight/');
            data.slices = 20:25;
        case 5
            % CSPA 0.5ms
            read_dir = cspa_dir;
            readfile_dirs = {'26','28'};
            write_dir = fullfile(sacher_dir, 'CSPA/05/cusp2/');
        case 6
            % CSPA 1ms check
            read_dir = cspa_dir;            
            readfile_dirs = {'22','24'};
            write_dir = fullfile(sacher_dir, 'CSPA/10/cusp2_mod/');
            data.parallel = 4;
            data.unwrapping_method_after_combination = 'mod';
        case 7
            % CSPA comparison data isotrop 1ms
            read_dir = cspa_dir;
            readfile_dirs = {'6','8'};
            write_dir = fullfile(sacher_dir, 'test/MCPC3D');
            data.parallel = 12;            
%             data.slices = 22;
            data.processing_option = 'all_at_once';
%             data.write_channels = 1:32;
            data.unwrapping_method_after_combination = 'mod';
            data.combination_mode = 'MCPC3D';
        case 8
            % CSPA 1,5ms
            read_dir = cspa_dir;
            readfile_dirs = {'18','20'};
            write_dir = fullfile(sacher_dir, 'CSPA/15/cusp2/');
        case 9
            % CSPA 2ms
            read_dir = cspa_dir;
            readfile_dirs = {'14','16'};
            write_dir = fullfile(sacher_dir, 'CSPA/20/cusp2/');
        case 10
            % CSPA 2,5ms
            read_dir = cspa_dir;
            readfile_dirs = {'30','32'};
            write_dir = fullfile(sacher_dir, 'CSPA/25/cusp2/');
        case 11
            % ABRC
            read_dir = abrc_dir;
            readfile_dirs = {'20','22'};
            write_dir = fullfile(sacher_dir, 'singleSlice/ABRC/ASPIRE');
%             data.parallel = 12;
            data.slices = 57;
            data.write_channels = [8 12 13 16 24 28 29 32];
            data.processing_option = 'slice_by_slice';
            data.combination_mode = 'aspire';
            data.unwrapping_method_after_combination = 'mod';
            %TODO error when wrong option
        case 12
            % ABRC
            read_dir = abrc_dir;
            readfile_dirs = {'20','22'};
            write_dir = fullfile(sacher_dir, 'ABRC/MCPC3DNew');
%             data.parallel = 12;
%             data.slices = 57;
            data.write_channels = [8 12 13 16 24 28 29 32];
            data.processing_option = 'all_at_once';
            data.combination_mode = 'mcpc3d';
            data.unwrapping_method_after_combination = 'cusack';
        case 13
            % KREK
            read_dir = krek_dir;
            readfile_dirs = {'8','10'};
            data.unwrapping_method_after_combination = 'cusack';
%             data.readfile_dirs_ute = {'2','4'};
            data.combination_mode = 'mcpc3di';
            write_dir = fullfile(sacher_dir,'noUnwrappingMcpc3diTest');%, data.combination_mode);
            data.processing_option = 'all_at_once';
            data.parallel = 12;            
            %data.channels = [1 2 3 4];
%             data.channels = [1 32];
%             data.write_channels = [1 2];
            data.mcpc3di_echoes = [2 3];
            data.aspire_echoes = [2 4];
%             data.slices = 50:51;
        case 14
            % local test
            read_dir = fullfile(local_dir, 'CSPA/nifti/');
            readfile_dirs = {'2','4'};
            % data.readfile_dirs_ute = {'6','8'};
            data.processing_option = 'all_at_once'; % choices: 'slice_by_slice', 'all_at_once'
            data.unwrapping_method_after_combination = 'mod'; % choices: 'umpire', 'cusack', 'mod', 'est'
            data.combination_mode = 'mcpc3d'; % choices: 'aspire', 'cusp3', 'composer', 'MCPCC', 'MCPC3D', 'MCPC3Di', 'add'
%             data.parallel = 0; % specify number of workers for parallel computation (only in slice_by_slice mode) 
%             data.slices = 5:6; % limit the range to these slices (only in slice_by_slice mode)
            write_dir = fullfile(local_dir, 'test', data.combination_mode);
            data.channels = [6 7];
            data.write_channels = [1 2];
            data.mcpc3di_echoes = [2 3];
%             data.slices = 50:51;
        case 15
            data.parallel = 0;
            read_dir = ktdo_dir;
            readfile_dirs = {'31', '33'};
            data.processing_option = 'slice_by_slice';
            data.unwrapping_method_after_combination = 'none';
            data.combination_mode = 'aspire';
            write_dir = '/home/keckstein/data/abstract/aspire';
            data.write_channels = 1:4;
        case 16
            data.parallel = 0;
            read_dir = ktdo_dir;
            readfile_dirs = {'31', '33'};
            data.processing_option = 'all_at_once';
            data.unwrapping_method_after_combination = 'none';
            data.combination_mode = 'mcpc3d';
            write_dir = '/net/mri.meduniwien.ac.at/projects/radiology/swi/data/simon/phase_comb-comparison_ismrm_2017/results/s1/scan_31_33/mcpc-3d-i/using_echoes_1_3/';
            data.write_channels = 1:4;
            data.mcpc3d_echoes = [1 3];
        case 17
            data.parallel = 0;
            read_dir = ktdo_dir;
            readfile_dirs = {'17', '19'};
            data.processing_option = 'all_at_once';
            data.unwrapping_method_after_combination = 'none';
            data.mcpc3d_unwrapping_method = 'prelude';
            data.combination_mode = 'mcpc3d';
            write_dir = '/home/keckstein/data/test/prelude';
            data.mcpc3d_echoes = [1 3];

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
