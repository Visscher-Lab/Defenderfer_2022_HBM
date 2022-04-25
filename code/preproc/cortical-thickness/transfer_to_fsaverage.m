subdir = '/data/user/mdefende/datasets/MDP/subs';
setenv('SUBJECTS_DIR',subdir)

surfs = dir(fullfile(subdir,'**','surf','*.thickness'));

surfs(contains({surfs.folder},'fsaverage')) = [];

parfor ii = 1:length(surfs)
    hemi = regexp(surfs(ii).name,'[lr]h','match'); hemi = hemi{1};
    subj = regexp(surfs(ii).folder,'sub-MDP[0-9]{3}','match'); subj = subj{1};
    
    outname = fullfile(subdir,'fsaverage','surf','MKD_surfs',strrep(surfs(ii).name,'h.',['h.' subj '.']));
    system(['mri_surf2surf --srcsubject ' subj ...
        ' --sval ' fullfile(surfs(ii).folder,surfs(ii).name) ...
        ' --trgsubject fsaverage ' ...
        ' --tval ' outname ...
        ' --hemi ' hemi ...
        ' --src_type curv' ...
        ' --trg_type curv']);
end