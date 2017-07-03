function make_aspire_package

zip_type='zip'; %'tar.gz'/'zip';
    %   tar preserves directory structure, zip option maybe easier for
    %   Windows users? 

%   directories, source and destination
ProgramDir = '/home/keckstein/matlab/korbinian/aspire/';
ProgramName = 'aspire_custom.m';
ArchiveDir = '/home/keckstein/matlab/korbinian/aspire';
%   derive archive name from version
fullProgramName = fullfile(ProgramDir, ProgramName);
version_number = strrep(strrep(search_all_header_func(fullProgramName, 'current_version_number'),'''',''),';','');
%   get all dependent m files
file_list = getFileDependencies(ProgramName);
numfiles=size(file_list,1);
for i=1:numfiles
    file_list(i)=strrep(file_list(i), '/bilbo/home/', '/home/');
    %file_list(i)=regexprep(file_list(i), '(/bilbo)?/home/(keckstein|srobi)/', '');
end
switch zip_type
    case 'zip'
        ArchiveName = strrep(strrep(ProgramName, '.m', ['_' version_number '.m.zip']),'_main','');
        fullArchiveName = fullfile(ArchiveDir,ArchiveName);
        zip(fullArchiveName, file_list);
    case 'tar'
        ArchiveName = strrep(strrep(ProgramName, '.m', ['_' version_number '.m.tar.gz']),'_main','');
        fullArchiveName = fullfile(ArchiveDir,ArchiveName);
        tar_command=sprintf('tar cvfz %s ', fullArchiveName);
        numfiles=size(file_list,1);
        for i=1:numfiles
            tar_command=sprintf('%s %s', tar_command, char(file_list(i)));
        end
        unix(tar_command);
end
disp(['Written archive to ' fullArchiveName]);

