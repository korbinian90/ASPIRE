function data = checkForWrongOptions(data)

 % check for enough echoes for UMPIRE
    if (data.n_echoes < 3)
        if (strcmpi(data.combination_mode, 'umpire') || strcmpi(data.combination_mode, 'cusp3'))
            disp(['UMPIRE based combination not possible with ' int2str(data.n_echoes) ' echoes']);
            if (data.n_echoes == 2)
                disp('aspire is used instead');
                data.combination_mode = 'aspire';
            else
                exit;
            end
        end
        if (strcmpi(data.unwrapping_method, 'umpire') || strcmpi(data.unwrapping_method, 'mod'))
            disp(['UMPIRE based unwrapping not possible with ' int2str(data.n_echoes) ' echoes. No unwrapping performed.']);
            data.unwrapping_method = 'none';
        end
    end

    % MCPC3D works only with all_at_once because of cusack unwrapping
    if (strcmpi(data.combination_mode, 'mcpc3d'))
        if ~isfield(data, 'processing_option') || strcmpi(data.processing_option, 'slice_by_slice')
            disp([data.combination_mode ' only works with processing_option all_at_once']);
            data.processing_option = 'all_at_once';
        end
    end
    
    % cusack unwrapping needs all_at_once
    if (strcmpi(data.processing_option, 'slice_by_slice') && (~strcmpi(data.combination_mode, 'mcpc3ds')) && strcmpi(data.unwrapping_method, 'cusack'))
        disp('cusack unwrapping needs all_at_once');
        data.processing_option = 'all_at_once';
    end
    
    % umpire ddTE ~= 0
    if (strcmpi(data.combination_mode, 'umpire') || strcmpi(data.combination_mode, 'cusp3'))
        TEs = data.TEs;
        if (TEs(2) - TEs(1) == TEs(3) - TEs(2))
            error('umpire based combination is not possible with these echo times');
        end
    end
    
    % warning for aspire if TE2 ~= 2*TE1
    if (strcmpi(data.combination_mode, 'aspire'))
        TEs = data.TEs;
        echoes = data.aspire_echoes;
        if (TEs(echoes(2)) ~= 2 * TEs(echoes(1)))
            disp('Warning: TE2 = 2 * TE1 is not fulfilled. There may be combination problems.');
        end
    end

end
