clear all;
aspire_startup
 %% Config
    net_app = '/net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/nifti_and_ima/';
    cspa_dir = fullfile(net_app, '19860116CSPA_201601281600/nifti/');
    mtjv_dir = fullfile(net_app, '19900620MTJV_201602011545/nifti/');
    sacher_dir = '/sacher/melange/users/keckstein/data/ASPIRE/';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    study_dir = 'comparison_mcpc3dMaskMiddle';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    id_list = [2]; % cspa mtjv
    id_name = {'CSPA', 'MTJV'};
    id_read_dir = {cspa_dir, mtjv_dir};
    id_readfile_dirs_aspire = {{'37','39'}, {'67','69'}};
    id_readfile_dirs_mcpc3di = {{'41','43'}, {'63','65'}};
    id_readfile_dirs_ute = {{'24','26'}, {'20','22'}};
    
    combinations = {'aspire', 'mcpc3di', 'mcpc3d'};
    %data.channels = [6 7]; % channels used for combination
    combinations = {'mcpc3d'};
    data.write_channels = 1:32;
    %data.slices = 65:75;

for id = id_list

    for co = combinations
   
        %data.unwrapping_method_after_combination = 'cusack';
        data.read_dir = id_read_dir{id};
        data.write_dir = fullfile(sacher_dir, study_dir, id_name{id}, co{1});
        data.readfile_dirs_ute = id_readfile_dirs_ute{id};
        data.combination_mode = co{1};
  
        if strfind(co{1}, 'mcpc3d')
            readfile_dirs = id_readfile_dirs_mcpc3di{id};
            data.parallel = 0;
            data.processing_option = 'all_at_once';
        else
            readfile_dirs = id_readfile_dirs_aspire{id};
            data.parallel = 8;
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
