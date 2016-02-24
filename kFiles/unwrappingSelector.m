function [ unwrapped, save ] = unwrappingSelector(data, combined_phase, weight)
%UNWRAPPINGSELECTOR calls the correct unwrapping method
    save = [];
    if (data.weighted_smoothing)
        smooth_weight = weight;
    else
        smooth_weight = [];
    end
        
    if strcmpi(data.unwrapping_method, 'umpire')
        [unwrapped, save] = umpire(combined_phase, data.TEs, smooth_weight);
    
    elseif strcmpi(data.unwrapping_method, 'cusack')
        unwrapped = cusackUnwrap(combined_phase, weight);
    
    elseif strcmpi(data.unwrapping_method, 'est')
        unwrapped = wrapEstimator(combined_phase, data.TEs, weight, data.wrap_estimator_range);
        
    elseif strcmpi(data.unwrapping_method, 'mod')
        [unwrapped, save] = umpireMod(combined_phase, data.TEs, smooth_weight);
        
    % experimental CHECK BEFORE USAGE
    elseif strcmpi(data.unwrapping_method, 'mod2')
        unwrapped = umpireMod2(combined_phase, data.TEs, smooth_weight);
        
    elseif strcmpi(data.unwrapping_method, 'median')
        unwrapped = umpireMedian(combined_phase, data.TEs, weight);
        
    elseif strcmpi(data.unwrapping_method, 'umpire_quick')
        unwrapped = umpireQuick(combined_phase, data.TEs);
        
    elseif strcmpi(data.unwrapping_method, 'prelude')
        unwrapped = preludeUnwrap(data, combined_phase, weight);
        
    % no unwrapping
    else
        disp(['unwrapping method: ' data.unwrapping_method ' not available. No unwrapping performed in this step.']);
        unwrapped = combined_phase;
    end

end
