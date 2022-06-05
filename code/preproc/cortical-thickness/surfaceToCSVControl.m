projdir = '/data/user/mdefende/datasets/MDP';

% subject's directory
subdir = fullfile(projdir,'subs');

% load the demographics file to loop through participants kept in the study
demo = readtable('/data/user/mdefende/Projects/prl-struct/data/demographics.csv');
subs = demo.Subject;

% list of surfaces to put into the csv
surfs = {'thickness'};

% fwhm values to include
fwhm = 0;

% set output directory for the csv files
outdir = fullfile(projdir,'SurfaceCSV-test');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

% strings that are part of the label name to match on, made from the prl
% and url labelbase variables from the general preprocessing

label_strings = {'RL-bin','lpz'};
region = 'V1';

for ii = 1:length(subs)
    
    labs = dir(fullfile(subdir,subs{ii},'label','MKD_labels','*.label'));
    labs(~contains({labs.name},label_strings)) = [];
    labs(~contains({labs.name},region)) = [];
    
    % remove pre-dilated forms of dilated labels
    dil = labs(contains({labs.name},'dilated'));
    
    for jj = 1:length(dil)
        labs(strcmp({labs.name},strrep(dil(jj).name,'-dilated',''))) = [];
    end
    
    for labnum = 1:length(labs)
        label_file = fullfile(labs(labnum).folder,labs(labnum).name);
        surfaceToCSVConversion(subs{ii},subdir,label_file,surfs,fwhm,outdir)
    end
end