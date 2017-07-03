%   search_text_header_function
%   Simon Robinson. 29.09.2008
%   use to find strings and establish the value of variables in the text
%   section of the text header 
%   scan_parameter_value = search_text_header_func(filename, searchstring)
%   N.B. - only searches the text header and not DICOM header parameters
%   - to search all of the text header use search_all_header_function


function scan_parameter_value = search_text_header_func(filename, searchstring)

start_looking = 0;
scan_parameter_value = 0;

fp_headerfile=fopen(filename, 'r');
while feof(fp_headerfile) == 0
    feof(fp_headerfile);
    tline = fgetl(fp_headerfile);
    if  length(findstr(tline, '### ASCCONV BEGIN ###')) ~= 0
        start_looking = 1;     %useful debug point
    end
    if start_looking == 1
        %identify the beginning of the text header
%         disp(tline);
        matches = findstr(tline, searchstring);
        num_matches = length(matches);
        if num_matches > 0
            line_size=size(tline);
            line_length=line_size(2);
            param_begin=findstr(' = ', tline)+3;
            %pass back the parameter and end the search
            scan_parameter_value=deblank(tline(param_begin:line_length));
            fclose(fp_headerfile);
            break;
        end
        if  length(findstr(tline, '### ASCCONV END ###')) ~= 0
            % disp(['Came to end of text file without finding search string ' searchstring]);
            scan_parameter_value='-1';
            fclose(fp_headerfile);
            break;
        end
    end
end

if scan_parameter_value == 0 
    scan_parameter_value = '-1';
end
