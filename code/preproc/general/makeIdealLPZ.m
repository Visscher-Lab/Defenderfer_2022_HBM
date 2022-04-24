function makeIdealLPZ(subdir,subj,lpznum,region,outdir)
%{
This function creates new ROIs of what are idealized lesion projection
zones. The ROIs contain the X vertices with the lowest eccentricity values
according to the Benson atlas. The input number of vertices is applied to
both hemispheres, so the total number of vertices across both ROIs will be
lpznum*2

Inputs:
    subdir: string for subject's directory
    subj: name of the subject in subdir
    lpznum: number of vertices to include in each ROI
    region: area of interest (e.g. 'V1','V2', or 'V3')
%}

% set subjects dir
setenv('SUBJECTS_DIR',subdir)

switch region
    case 'V1'
        roiind = 1;
    case 'V2'
        roiind = 2;
    case 'V3'
        roiind = 3;
end

% read in eccentricity and areas atlases for the subject
lhecc = squeeze(load_mgh(fullfile(subdir,subj,'surf','lh.benson14_eccen.mgz')));
rhecc = squeeze(load_mgh(fullfile(subdir,subj,'surf','rh.benson14_eccen.mgz')));

lharea = squeeze(load_mgh(fullfile(subdir,subj,'surf','lh.benson14_varea.mgz')));
rharea = squeeze(load_mgh(fullfile(subdir,subj,'surf','rh.benson14_varea.mgz')));

[lhecc,lhind] = sort(lhecc(lharea == roiind));
[rhecc,rhind] = sort(rhecc(rharea == roiind));

lhvert = find(lharea == roiind) - 1; lhvert = lhvert(lhind);
rhvert = find(rharea == roiind) - 1; rhvert = rhvert(rhind);

% read the cortex labels
lhcortex = read_label(subj,'lh.cortex');
rhcortex = read_label(subj,'rh.cortex');

lhlabel = lhcortex(ismember(lhcortex(:,1),lhvert(1:lpznum)),:);
rhlabel = rhcortex(ismember(rhcortex(:,1),rhvert(1:lpznum)),:);

if ~exist(fullfile(subdir,subj,'label',outdir),'dir') && ~isempty(outdir)
    mkdir(fullfile(subdir,subj,'label',outdir))
end

if ~isempty(outdir)
    lhoutname = fullfile(subdir,subj,'label',outdir, ['lh.' region '.' subj '_lpz_' num2str(lpznum) '.label']);
    rhoutname = fullfile(subdir,subj,'label',outdir, ['rh.' region '.' subj '_lpz_' num2str(lpznum) '.label']);
else
    lhoutname = fullfile(subdir,subj,'label', ['lh.' subj '_lpz_' num2str(lpznum) '.label']);
    rhoutname = fullfile(subdir,subj,'label', ['rh.' subj '_lpz_' num2str(lpznum) '.label']);
end

write_label(lhlabel(:,1),lhlabel(:,2:4),lhlabel(:,5), lhoutname)
write_label(rhlabel(:,1),rhlabel(:,2:4),rhlabel(:,5), rhoutname)
end