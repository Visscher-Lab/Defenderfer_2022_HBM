#!/bin/bash
#SBATCH --partition=long
#SBATCH --time=72:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8G
#SBATCH --output=/data/user/mdefende/datasets/MDP-diff/jobs/noddi/sub-MDP001_dir98_1.1e-9.txt

module load rc/matlab/R2019a
module load FreeSurfer/6.0.0-centos6_x86_64

mri_convert /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/sub-MDP001-AP_PA_dir98_eddy.nii.gz /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/sub-MDP001-AP_PA_dir98_eddy -ot nifti1

mri_convert /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/unwarp_b0_brain_mask.nii.gz /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/unwarp_b0_brain_mask -ot nifti1

matlab -nodisplay -r "addpath(genpath('/data/user/mdefende/Projects/prl-noddi/code'));CreateROI('/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/sub-MDP001-AP_PA_dir98_eddy.hdr','/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/unwarp_b0_brain_mask.hdr','/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/sub-MDP001-AP_PA_dir98_eddy_NODDI_roi.mat');protocol = FSL2Protocol('/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/AP_PA_dir98.bval','/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/sub-MDP001-AP_PA_dir98_eddy.eddy_rotated_bvecs',5);noddi = MakeModel('WatsonSHStickTortIsoV_B0',1.1e-9); batch_fitting('/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/sub-MDP001-AP_PA_dir98_eddy_NODDI_roi.mat',protocol,noddi,'/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/NODDI_fitted_params_diff_1.1e-9.mat',8);"
