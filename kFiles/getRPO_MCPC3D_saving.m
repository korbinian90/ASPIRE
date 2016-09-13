function [ rpo, save ] = getRPO_MCPC3D_saving( data, compl )
%GETRPO_MCPC3D calculates the RPO of multi-echo phase using MCPC-3D-I
    save = [];

    TEs = data.TEs;
    if isfield(data,'mcpc3di_echoes')
        echo = data.mcpc3di_echoes;
    else
        echo = [1 2];
    end
    
    subdir = 'steps';
    write_dir = fullfile(data.write_dir, subdir);
    sep_dir = fullfile(write_dir, 'sep');
    fn_unwrappedHip = fullfile(write_dir, 'hermitianUnwrapped.nii');
    
    if ~exist(write_dir, 'dir')
        mkdir(write_dir);
    end
    if ~exist(sep_dir, 'dir')
        mkdir(sep_dir);
    end
    
    if ~exist(fn_unwrappedHip, 'file')
        hip = sum(compl(:,:,:,echo(2),:) .* conj(compl(:,:,:,echo(1),:)),5);
        unwrappedHip = cusackUnwrap(angle(hip), abs(hip));
        save_nii(make_nii(unwrappedHip), fn_unwrappedHip);
    else
        unwrappedHip_nii = load_nii(fn_unwrappedHip);
        unwrappedHip = unwrappedHip_nii.img; clear unwrappedHip_nii;
    end
    
    dims = size(compl);
    rpo = complex(zeros([dims(1:3) dims(5)], 'single'));
    for cha = 1:data.n_channels
        
        weight = abs(compl(:,:,:,[echo(1) echo(2)],cha));
        fn_unwrapped = fullfile(sep_dir, ['unwrapped_c' int2str(cha) '.nii']);
        if ~exist(fn_unwrapped, 'file')
            disp(['Unwrapping channel ' int2str(cha)]);
            unwrapped = cusackUnwrap(angle(compl(:,:,:,[echo(1) echo(2)],cha)), weight);
            save_nii(make_nii(unwrapped), fn_unwrapped);
        else
            disp(['Unwrapped channel ' int2str(cha) ' found!']);
            unwrapped_nii = load_nii(fn_unwrapped);
            unwrapped = unwrapped_nii.img;
        end
        
        
        %% calculation of jumps between echoes
        % formula 7 of MCPC3D paper
        diff = (unwrapped(:,:,:,2) - (unwrapped(:,:,:,1) + unwrappedHip)) / (2*pi);
        save = toSave(save, diff, ['diff_c' int2str(cha)]);
        mask_weight = weight(:,:,:,1);
        
        % take the middle part of the image
        mask = zeros(size(mask_weight));
        [x,y,z,~] = size(mask);
        mask_x = round(x * 0.3):round(x * 0.7);
        mask_y = round(y * 0.3):round(y * 0.7);
        mask_z = round(z * 0.4):round(z * 0.6);
        mask(mask_x,mask_y,mask_z) = 1;
        %save = toSave(save, mask, ['mask_c' int2str(cha)]);
        % idea: high magnitude in middle of brain
        
%         maskMax = mask_weight > 0.1 * max(mask_weight(:)); % mask good enough?
%         save = toSave(save, maskMax, ['maskMax_c' int2str(cha)]);
%         
%         maskMedian = mask_weight > median(mask_weight(:)); % mask alternative
%         save = toSave(save, maskMedian, ['maskMedian_c' int2str(cha)]);
%         
        n2pi = round(median(diff(mask == 1)));
%         save = toSave(save, n2pi, ['n2pi_c' int2str(cha)]);
        % correction for jumps
        unwrapped = unwrapped - n2pi;
        %% Phase Offset calculation
        % formula 5 of MCPC3D paper
        rpo_angle = (unwrapped(:,:,:,1) * TEs(echo(2)) - unwrapped(:,:,:,2) * TEs(echo(1))) / (TEs(echo(2)) - TEs(echo(1)));
        save = toSave(save, rpo_angle, ['rpo_angle_c' int2str(cha)]);
        % get complex rpo with mag=1
        rpo(:,:,:,cha) = single(exp(1i * squeeze(rpo_angle)));  
    end
    disp('Finshed correcting for 2pi jumps');
%     
%     if data.parallel
%        matlabpool('close');
%     end

    
end
