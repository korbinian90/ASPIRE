clear all;
aspire_startup
 %% Config
    net_app = '/net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/nifti_and_ima/';
    sacher_dir = '/sacher/melange/users/keckstein/data/ASPIRE/';

    id_list = [1 2 3]; % cspa abrc krek
    id_name = {'19700417PAAD_201210251715', '19700522ADDE_2009082511815', '19701007SMRB_201303211650', '19701007SMRB_201303211650', '19790301PDCR_201302071630','19790301PDCR_201302071630', '19810629CRLU_201303141600', '19870316ADHF_201303071630', '19881204BRDM_20130321', 'Cadaver1_head_201401162100'};
    id_readfile_dirs = {{'78','80'}, {'12','14'}, {'6','8'}, {'10', '12'}, {'39', '41'}, {'47', '49'}, {'28', '30'}, {'4', '6'}, {'6', '8'}, {'13', '15'}};
    %id_readfile_dirs_ute = {{'10','12'}, {'6','8'}, {'2','4'}};
    dte_list = [-1200 -3000 3000 880 2500 1990 -2500 3000 3000 -2650];
    
    combinations = {'aspire', 'cusp3', 'MCPC3Di'};
    %combinations = {'cusp3', 'MCPCC', 'MCPC3Di'};
    %combinations = {'cusp3'};
    %combinations = {'MCPC3Di', 'hip'};
    
for id = 2:9
    for co = combinations
   
        data.unwrapping_method = 'none';
        read_dir = fullfile(net_app, id_name{id} , 'nifti');
        write_dir = fullfile(sacher_dir, 'notDoubleTE' , [int2str(id) id_name{id}], co{1});
        readfile_dirs = id_readfile_dirs{id};
        %data.readfile_dirs_ute = id_readfile_dirs_ute{id};
        data.combination_mode = co{1};
  
        if strfind(co{1}, 'MCPC')
            data.processing_option = 'all_at_once';
            data.parallel = 0;
        else
            data.parallel = 8;
            data.processing_option = 'slice_by_slice';
        end
    

 
    
        data.read_dir = read_dir;
        data.filename_mag = fullfile(read_dir, readfile_dirs{1}, 'reform', 'Image.nii');
        data.filename_phase = fullfile(read_dir, readfile_dirs{2}, 'reform', 'Image.nii');
        data.filename_magTextHeader = fullfile(data.read_dir, readfile_dirs{1}, 'text_header.txt');
        data.filename_phaseTextHeader = fullfile(data.read_dir, readfile_dirs{2}, 'text_header.txt');
        data.write_dir = write_dir;
        data.wrap_estimator_range = [-5 3];
        tic;
        if strcmp(co{1}, 'hip')
            hermitianInnerProduct(data);
        else
            aspire(data);
        end
        disp(['Whole calculation takes: ' secs2hms(toc)]);
        disp(['Files written to: ' write_dir]);

    end
      
end
