% add image to surface to the path for ROI conversion
addpath(genpath('/data/user/mdefende/image-to-surface'))
addpath(genpath('/share/apps/rc/software/FreeSurfer/6.0.0-centos6_x86_64/matlab/'))

subdir = '/data/user/mdefende/datasets/MDP/subs';
setenv('SUBJECTS_DIR',subdir)

% set project directory
projdir = '/data/user/mdefende/Projects/prl-struct';

% read in demographics with list of participants
demo = readtable(fullfile(projdir,'data','demographics.csv'));

% get only the MD participants
md = demo(strcmp(demo.Dx,'MD'),:);

% start parfor
p = gcp('nocreate');
if isempty(p)
    numcores = feature('numcores');
    if numcores > 1
        parpool(numcores)
    end
end

% some ROI transfer settings
region = 'V1';
outdir = 'MKD_labels';
max_ecc = 70;
dpp = 0.0356;
inRetinalSpace = true;
binary = true;
force = false;

% minimum number of vertices in a PRL or URL ROI
minvert = 50;

% number of vertices per hemisphere for LPZ
lpznum = 100;

for ii = 1:height(md)
    subj = md.Subject{ii};
    
    %% transfer their PRL and URL ROIs from image space to cortical space
    % get the list of images to transfer
    ims = dir(fullfile(projdir,'data','RL_images',subj,'*.png'));
    fov = ims(contains(lower({ims.name}),'fov')); fov = fullfile(fov.folder,fov.name);
    prl = ims(contains(lower({ims.name}),'prl')); prl = fullfile(prl.folder,prl.name);
    url = ims(contains(lower({ims.name}),'url')); url = fullfile(url.folder,url.name);
    
    prlLabelBase = [subj '-PRL-bin'];
    urlLabelBase = [subj '-URL-bin'];
    
    % PRL
    convertBinaryToSurface(fov, ...
                           prl, ...
                           subdir, ...
                           subj, ...
                           region, ...
                           prlLabelBase, ...
                           outdir, ...
                           max_ecc, ...
                           dpp, ...
                           inRetinalSpace, ...
                           binary, ...
                           force);
    % URL                   
    convertBinaryToSurface(fov, ...
                           url, ...
                           subdir, ...
                           subj, ...
                           region, ...
                           urlLabelBase, ...
                           outdir, ...
                           max_ecc, ...
                           dpp, ...
                           inRetinalSpace, ...
                           binary, ...
                           force);
                       
    %% dilate the ROIs, if necessary
    check_dilate_RL_labels(subdir,subj,outdir,minvert,region,prlLabelBase);
    check_dilate_RL_labels(subdir,subj,outdir,minvert,region,urlLabelBase);

    %% transfer the PRL and URL labels to the matched controls
    if ~strcmp(md.Match{ii},'')
        transfer_prl_url(subdir,subj,outdir,md.Match{ii},'lh',prlLabelBase,region)
        transfer_prl_url(subdir,subj,outdir,md.Match{ii},'rh',prlLabelBase,region)
        transfer_prl_url(subdir,subj,outdir,md.Match{ii},'lh',urlLabelBase,region)
        transfer_prl_url(subdir,subj,outdir,md.Match{ii},'rh',urlLabelBase,region)
    end
end

