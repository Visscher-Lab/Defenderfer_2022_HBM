% Need to convert all of the NODDI fitted params from .mat files to nifti. Also store
% the currently calculated params as using diffusivity value of 1.1e-9

addpath(genpath('/data/user/mdefende/Projects/prl-noddi/code'))

subdir = '/data/user/mdefende/datasets/MDP-diff/subs';

intdiff = 'diff_1.1e-9';
mats = dir(fullfile(subdir,'**','FSL','**',['NODDI_fitted_params_' intdiff '.mat']));

mats(~contains({mats.folder},{'MDP044'})) = [];

for ii = 1:length(mats)
    % make the output directory
    outdir = strrep(mats(ii).folder,'FSL','NODDI');
    if ~exist(outdir,'dir')
        mkdir(outdir)
    end
    
    % copy the existing NODDI fitted params to the new directory, adding
    % the intrinsic diffusivity value to the name of the file
    copyfile(fullfile(mats(ii).folder,mats(ii).name),fullfile(outdir,mats(ii).name));
    
    % set variables for SaveParamsAsNIfTI
    paramsfile = fullfile(outdir,mats(ii).name);
    
    % find the NODDI_roi.mat file 
    v = dir(fullfile(mats(ii).folder,'*NODDI_roi.mat'));
    roifile = fullfile(v.folder,v.name);
    
    % set targetfile
    targetfile = fullfile(mats(ii).folder,'unwarp_b0_brain_mask.hdr');
    
    % set the tag
    subj = regexp(outdir,'sub-MDP[0-9]{3}','match');
    tag = [subj{1} '_' intdiff];
    
    % change directory to where we want to sive the files to.....
    cd(outdir)
    
    SaveParamsAsNIfTI(paramsfile,roifile,targetfile,tag);
end
