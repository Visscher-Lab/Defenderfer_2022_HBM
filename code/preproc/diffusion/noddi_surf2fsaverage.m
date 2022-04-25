subdir = '/data/user/mdefende/datasets/MDP/subs';
setenv('SUBJECTS_DIR',subdir)

noddi = dir('/data/user/mdefende/datasets/MDP-diff/subs/**/*.mgz');

outdir = fullfile(subdir,'fsaverage','surf','MKD_surfs','noddi');

if ~exist(outdir,'dir')
    mkdir(outdir)
end

parfor ii = 1:length(noddi)
    hemi = regexp(noddi(ii).name,'[lr]h','match'); hemi = hemi{1};
    subj = regexp(noddi(ii).folder,'sub-MDP[0-9]{3}','match'); subj = subj{1};
    
    outname = fullfile(outdir,noddi(ii).name);
    system(['mri_surf2surf --srcsubject ' subj ...
        ' --sval ' fullfile(noddi(ii).folder,noddi(ii).name) ...
        ' --trgsubject fsaverage ' ...
        ' --tval ' outname ...
        ' --hemi ' hemi]);
end