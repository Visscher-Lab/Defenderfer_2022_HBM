%{
This script transfers thickness outputs from freesurfer to fsaverage space
for whole V1 analysis.
%}

% set subjects directory
subdir = '/data/user/mdefende/datasets/MDP/subs';
setenv('SUBJECTS_DIR',subdir)

% load the demographics file to loop through participants kept in the study
demo = readtable('/data/user/mdefende/Projects/prl-struct/data/demographics.csv');
subs = demo.Subject;
hemi = {'lh','rh'};

for ii = 1:length(subs)
    for jj = 1:length(hemi)
        
        infile = fullfile(subdir,subs{ii},'surf',[hemi{jj} '.thickness']);
        
        outfile = fullfile(subdir,'fsaverage','surf','MKD_surfs','mdp-thickness',[hemi{jj} '.' subs{ii} '.thickness']);
        system(['mri_surf2surf --srcsubject ' subs{ii} ...
            ' --sval ' infile ...
            ' --trgsubject fsaverage ' ...
            ' --tval ' outfile ...
            ' --hemi ' hemi{jj} ...
            ' --src_type curv' ...
            ' --trg_type curv']);
    end
end