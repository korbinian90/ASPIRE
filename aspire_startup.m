directory = fileparts(mfilename('fullpath'));
subfolders = {'aspire', 'dependencies', 'kFiles', 'testFileDir'};
addpath(strjoin(fullfile(directory, subfolders), ';'));
