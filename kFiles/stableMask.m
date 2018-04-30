function mask = stableMask(weight)
        % TODO remove too high values
        threshold = 0.15;
%                 weight = sum(weight, 5);
        % TODO slicewise for 3d
        mean_mask = weight >= mean(weight(:));
        mean_mask = weight >= mean(weight(mean_mask));
        mean_mask = weight >= mean(weight(mean_mask));
        mask = weight < threshold * mean(weight(mean_mask));
end

