function [ rpo, save ] = getRPO_MCPC3D_saving( data, compl )
%GETRPO_MCPC3D calculates the RPO of multi-echo phase using MCPC-3D-I

    %% initialize
    save = [];

    TEs = data.TEs;
    if isfield(data,'mcpc3d_echoes')
        echo = data.mcpc3d_echoes;
    else
        echo = [1 2];
    end
    
    subdir = 'steps';
    write_dir = fullfile(data.write_dir, subdir);
    sep_dir = fullfile(write_dir, 'sep');
    fn_unwrappedHip = fullfile(write_dir, ['hermitianUnwrapped_e' int2str(echo(1)) '_e' int2str(echo(2)) '.nii']);
    
    if ~exist(write_dir, 'dir')
        mkdir(write_dir);
    end
    if ~exist(sep_dir, 'dir')
        mkdir(sep_dir);
    end
    
    %% get unwrapped HiP
    if ~exist(fn_unwrappedHip, 'file')
        hip = sum(compl(:,:,:,echo(2),:) .* conj(compl(:,:,:,echo(1),:)),5);
        unwrappedHip = cusackUnwrap(angle(hip), abs(hip));
        save_nii(make_nii(unwrappedHip), fn_unwrappedHip);
    else
        unwrappedHip_nii = load_nii(fn_unwrappedHip);
        unwrappedHip = unwrappedHip_nii.img; clear unwrappedHip_nii;
    end
    
    %% get phase offsets
    dims = size(compl);
    rpo = complex(zeros([dims(1:3) dims(5)], 'single'));
    compl_loop = compl(:,:,:,[echo(1) echo(2)], :);
    parfor cha = 1:data.n_channels
        
        weight = abs(compl_loop(:,:,:,:,cha));
        unwrapped = zeros([dims(1:3) 2], 'single');
        
        for unwrap_echo = 1:2
	        fn_unwrapped = fullfile(sep_dir, ['unwrapped_c' int2str(cha) '_e' int2str(echo(unwrap_echo)) '.nii']);
            
            if ~exist(fn_unwrapped, 'file')
            
                %% usual case
                disp(['Unwrapping channel ' int2str(cha) ' echo ' int2str(echo(unwrap_echo))]);        
                if isfield(data, 'mcpc3d_unwrapping_method') && strcmp(data.mcpc3d_unwrapping_method, 'cusack')
                    unwrapped(:,:,:,unwrap_echo) = cusackUnwrap(angle(compl_loop(:,:,:,unwrap_echo,cha)), weight(:,:,:,unwrap_echo));
                else
                    unwrapped(:,:,:,unwrap_echo) = preludeUnwrap(data, angle(compl_loop(:,:,:,unwrap_echo,cha)), weight(:,:,:,unwrap_echo), cha);
                end

                save_nii(make_nii(unwrapped(:,:,:,unwrap_echo)), fn_unwrapped);

		    else
	        	disp(['Unwrapped channel ' int2str(cha) ' found for echo ' int2str(echo(unwrap_echo)) '!']);
	        	unwrapped_nii = load_nii(fn_unwrapped);
	        	unwrapped(:,:,:,unwrap_echo) = unwrapped_nii.img;
            end
        end
        
        unwrapped = echoJumpCorrection(unwrapped, unwrappedHip, TEs(echo(1)), TEs(echo(2)));
        
        %% Phase Offset calculation
        % formula 5 of MCPC3D paper
        rpo_angle = (unwrapped(:,:,:,1) * TEs(echo(2)) - unwrapped(:,:,:,2) * TEs(echo(1))) / (TEs(echo(2)) - TEs(echo(1)));
        %save = toSave(save, unwrapped, ['echoJumpCorrected_c' int2str(cha)]);
        % get complex rpo with mag=1
        rpo(:,:,:,cha) = single(exp(1i * squeeze(rpo_angle)));  
    end
    disp('Finished correcting for 2pi jumps');
    
end
