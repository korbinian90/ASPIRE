clear all;
aspire_startup
 %% Config
    net_app = '/net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/nifti_and_ima/';
    cspa_dir = fullfile(net_app, '19860116CSPA_201601281600/nifti/');
    mtjv_dir = fullfile(net_app, '19900620MTJV_201602011545/nifti/');
    sacher_dir = '/sacher/melange/users/keckstein/data/ASPIRE/';

    study_dir = '4echoes';
    id_list = [1 2]; % cspa mtjv
    id_name = {'monopolar', 'bipolar'};
    id_read_dir = {mtjv_dir, mtjv_dir};
    id_readfile_dirs_aspire = {{'71','73'}, {'75','77'}};
    %id_readfile_dirs_mcpc3di = {{'41','43'}, {'63','65'}};
    id_readfile_dirs_ute = {{'24','26'}, {'20','22'}};
    
    echo_list = {[1 2], [2 4]};
    echo_name = {'echo12', 'echo24'};
    combinations = {'aspire'};%, 'MCPC3Di', 'MCPC3D'};
%     combinations = {'MCPC3D'};

for id = id_list

    for co = combinations
   
        for echo_id = 1:2

            data.unwrapping_method_after_combination = 'mod';
            data.rpo_weigthedSmoothing = 1;
            data.read_dir = id_read_dir{id};
            data.write_dir = fullfile(sacher_dir, study_dir, id_name{id}, echo_name{echo_id});
            data.readfile_dirs_ute = id_readfile_dirs_ute{id};
            data.combination_mode = co{1};
            data.aspire_echoes = echo_list{echo_id};

            if strfind(co{1}, 'mcpc3d')
                readfile_dirs = id_readfile_dirs_mcpc3di{id};
                data.parallel = 0;
                data.processing_option = 'all_at_once';
            else
                readfile_dirs = id_readfile_dirs_aspire{id};
                data.parallel = 0;
                data.processing_option = 'all_at_once';
            end


            data.filename_mag = fullfile(data.read_dir, readfile_dirs{1}, 'reform', 'Image.nii');
            data.filename_phase = fullfile(data.read_dir, readfile_dirs{2}, 'reform', 'Image.nii');
            data.filename_magTextHeader = fullfile(data.read_dir, readfile_dirs{1}, 'text_header.txt');
            data.filename_phaseTextHeader = fullfile(data.read_dir, readfile_dirs{2}, 'text_header.txt');
            data.wrap_estimator_range = [-5 3];
            tic;
            aspire(data);
            disp(['Whole calculation takes: ' secs2hms(toc)]);
            disp(['Files written to: ' data.write_dir]);
        end
    end
end