subdir = '/data/user/mdefende/datasets/MDP-diff/subs';
jobdir = '/data/user/mdefende/datasets/MDP-diff/jobs/noddi';
scans = dir(fullfile(subdir,'sub-*','FSL','**','*eddy.nii.gz'));

intdiff = '1.1e-9';

for ii = 1:length(scans)
    % extract subject name and directions
    pat = '(?<subj>sub-MDP[0-9]{3})-AP_PA_(?<dir>dir[89]{2})';
    v = regexp(scans(ii).name,pat,'names');
    
    filename = fullfile(jobdir,[v.subj '_' v.dir '_' intdiff '.sh']);
    
    fid = fopen(filename,'w');
    fprintf(fid,'#!/bin/bash\n');
    fprintf(fid,'#SBATCH --partition=long\n');
    fprintf(fid,'#SBATCH --time=72:00:00\n');
    fprintf(fid,'#SBATCH --ntasks=1\n');
    fprintf(fid,'#SBATCH --cpus-per-task=8\n');
    fprintf(fid,'#SBATCH --mem-per-cpu=8G\n');
    fprintf(fid,['#SBATCH --output=' strrep(filename,'sh','txt') '\n\n']);
    
    fprintf(fid,'module load rc/matlab/R2019a\n');
    fprintf(fid,'module load FreeSurfer/6.0.0-centos6_x86_64\n\n');
    
    % convert dwi and mask to nifti1 with mri_convert
    dwifile = fullfile(scans(ii).folder,scans(ii).name);
    maskfile = fullfile(scans(ii).folder,'unwarp_b0_brain_mask.nii.gz');
    fprintf(fid,['mri_convert ' dwifile ' ' strrep(dwifile,'.nii.gz','') ' -ot nifti1\n']);
    fprintf(fid,['mri_convert ' maskfile ' ' strrep(maskfile,'.nii.gz','') ' -ot nifti1\n']);
    
    % start the matlab command
    command = 'matlab -nodisplay -r "addpath(genpath(''/data/user/mdefende/Projects/prl-noddi/code''));';
    
    % Write command for CreateROI
    dwihdr = strrep(dwifile,'.nii.gz','.hdr');
    maskhdr = strrep(maskfile,'.nii.gz','.hdr');
    outroi = fullfile(scans(ii).folder,strrep(scans(ii).name,'.nii.gz','_NODDI_roi.mat'));
    command = [command 'CreateROI(''' dwihdr ''',''' maskhdr ''',''' outroi ''');'];
    
    % Write command for FSL2protocol, changing bvecs and bvals
    bvecs = fullfile(scans(ii).folder,strrep(scans(ii).name,'nii.gz','eddy_rotated_bvecs'));
    bvals = fullfile(scans(ii).folder,['AP_PA_' v.dir '.bval']);
    b0threshold = '5';
    command = [command 'protocol = FSL2Protocol(''' bvals ''',''' bvecs ''',' b0threshold ');'];
    
    % Write NODDI command
    command = [command 'noddi = MakeModel(''WatsonSHStickTortIsoV_B0'',' intdiff ');'];
    
    % Write batch_fitting command
    outfile = fullfile(scans(ii).folder,['NODDI_fitted_params_diff_' intdiff '.mat']);
    command = [command ' batch_fitting(''' outroi ''',protocol,noddi,''' outfile ''',8);"'];
        
    fprintf(fid,command);
    
    fclose(fid);
end