function create_full_V1_labels(subdir,subj,outdir)
%{
This function creates individual labels for area V1 according to the Benson
retinotopic atlas.

Inputs:
    subdir: string for subject's directory
    subj: name of the subject in subdir
    region: area of interest (e.g. 'V1','V2', or 'V3')
%}

% set subjects dir
setenv('SUBJECTS_DIR',subdir)

lharea = squeeze(load_mgh(fullfile(subdir,subj,'surf','lh.benson14_varea.mgz')));
rharea = squeeze(load_mgh(fullfile(subdir,subj,'surf','rh.benson14_varea.mgz')));

lhvert = find(lharea == 1) - 1;
rhvert = find(rharea == 1) - 1;

% read the cortex labels
lhcortex = read_label(subj,'lh.cortex');
rhcortex = read_label(subj,'rh.cortex');

lhlabel = lhcortex(ismember(lhcortex(:,1),lhvert),:);
rhlabel = rhcortex(ismember(rhcortex(:,1),rhvert),:);

if ~exist(fullfile(subdir,subj,'label',outdir),'dir') && ~isempty(outdir)
    mkdir(fullfile(subdir,subj,'label',outdir))
end

if ~isempty(outdir)
    lhoutname = fullfile(subdir,subj,'label',outdir, ['lh.V1.' subj '_full-area.label']);
    rhoutname = fullfile(subdir,subj,'label',outdir, ['rh.V1.' subj '_full-area.label']);
else
    lhoutname = fullfile(subdir,subj,'label', ['lh.V1.' subj '_full-area.label']);
    rhoutname = fullfile(subdir,subj,'label', ['rh.V1.' subj '_full-area.label']);
end

write_label(lhlabel(:,1),lhlabel(:,2:4),lhlabel(:,5), lhoutname)
write_label(rhlabel(:,1),rhlabel(:,2:4),rhlabel(:,5), rhoutname)
end