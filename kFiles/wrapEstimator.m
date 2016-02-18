function [ unwrapped, uweight ] = wrapEstimator(combined_phase, TEs, weight, wrap_range)
%WRAP_ESTIMATOR Estimates the most probable number of wraps and unwraps
orig_dim = size(combined_phase);
n_pixel = prod(orig_dim(1:3));
n_echoes = orig_dim(4);
combined_phase = reshape(combined_phase, [n_pixel, n_echoes]);
unwrapped = zeros(n_pixel, n_echoes);
uweight = zeros(orig_dim(1:3));
db0 = zeros(orig_dim(1:3));
out_n = zeros(orig_dim(1:3));

weight_thresh = 2;

for p = 1:n_pixel
    if weight(p) > weight_thresh
        var_db0 = pi;

        for nWraps = wrap_range(1):wrap_range(2)

            [unwrapped_temp, db0_temp, var_temp] = singleWrapEstimate( combined_phase(p,:), nWraps, TEs );
            
            %var_temp = var_temp * power(1+abs(nWraps), 0.5); %<- probably bad idea
            %change = var_temp < var_db0;
            if var_temp < var_db0
                var_db0 = var_temp;
                db0(p) = db0_temp;
                out_n(p) = nWraps;
                unwrapped(p,:) = unwrapped_temp;
                uweight(p) = var_temp;
            end

        end
    end
end

unwrapped = reshape(unwrapped, orig_dim);
uweight = (1 - uweight./pi).^4; % only idea

end