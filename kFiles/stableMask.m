function mask = stableMask(weight)
    noise_mask = weight <= mean(weight(:));
    noise_mean = mean(weight(noise_mask));
    
    signal_mean = mean(weight(~noise_mask));
    
    mask = weight > max(noise_mean * 2, signal_mean / 8);
                % TODO remove too high values
%         threshold = 0.15;
%                 weight = sum(weight, 5);
        % TODO slicewise for 3d
%         z = weight;
%         z(:) = zscore(weight(:));
%         
%         z(z > 3) = 0;
%         
%         weight = z;
        
%         mean_mask = weight >= mean(weight(:));
%         mean_mask = weight >= mean(weight(mean_mask));
%         mean_mask = weight >= mean(weight(mean_mask));
%         mask = weight < threshold * mean(weight(mean_mask));
end

