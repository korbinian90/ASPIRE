%   Combining phase images from multi-channel coils.  
%   Based on http://www.ncbi.nlm.nih.gov/pubmed/21254207 but with some simplifications, which make it faster and more robust
%   Korbinian Eckstein (korbinian90@gmail.com) and Simon Robinson (simon.robinson@meduniwien.ac.at). 16.2.2016
%   version_number = 1.0 : 16.2.2016
%   version_number = 1.1 : 17.2.2016 : S.R. removed 'like' formulation in calls to 'zeroes' and 'ones' to give compabitility back to MATLAB7 (for these functions, at least)
%   
%   current_version_number = 1.1  

    
clear all; clc

% load configuration
% ks_problemZeroes, 
configurationName = 'ks_problemZeroes';

run(fullfile('configurations', configurationName));

% 
data.write_dir = fullfile(write_dir, data.combination_mode);
data.unwrapping_method = unwrapping_method_after_combination;
%data.mcpc3di_unwrapping_method = unwrapping_method_for_combination;

% run ASPIRE
tic;
aspire_startup;
aspire(data);
disp(['Whole calculation takes: ' secs2hms(toc)]);
disp(['Files written to: ' write_dir]);
