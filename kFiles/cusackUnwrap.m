function [unwrapped] = cusackUnwrap(phase, weight)
%CUSACKUNWRAP unwraps the phase (can be multi-echo, multi-channel data).
% the weight can have channels as additional dimension

    for i = 1:5
        dim_phase(i) = size(phase,i); %#ok<AGROW>
    end
    
    unwrapped = zeros(dim_phase, 'single');
    seed_voxel = [round(dim_phase(1)/2.5) round(dim_phase(2)/2.5) round(dim_phase(3)/2)];
            
    for cha_eco = 1:size(phase(:,:,:,:),4)
        eco = mod(cha_eco, dim_phase(5)) + 1;
        cha = ceil(double(cha_eco) / dim_phase(4));
        if size(weight,4) == 1 && size(weight,5) == 1
            loop_weight = double(weight);
        elseif size(weight,5) == 1
            loop_weight = double(weight(:,:,:,eco));
        elseif size(weight,4) == 1
            loop_weight = double(weight(:,:,:,1,cha));
        else
            loop_weight = double(weight(:,:,:,cha_eco));
        end
       
        unwrapped(:,:,:,cha_eco) = single(robustunwrap(seed_voxel, double(phase(:,:,:,cha_eco)), loop_weight));
    end

end