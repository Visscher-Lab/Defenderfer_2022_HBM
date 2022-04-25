#!/bin/bash
#SBATCH --partition=express
#SBATCH --time=2:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --output=/data/user/mdefende/datasets/MDP-diff/jobs/register/sub-MDP001-reg.txt

module load FreeSurfer/6.0.0-centos6_x86_64
SUBJECTS_DIR=/data/user/mdefende/datasets/MDP/subs

% register clean b0 to structural data for both dir98 and dir99 scans
bbregister --s sub-MDP001 --mov /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/unwarp_b0.nii.gz --dti --reg /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/register/dir98_reg.dat --init-fsl

bbregister --s sub-MDP001 --mov /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/unwarp_b0.nii.gz --dti --reg /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/register/dir99_reg.dat --init-fsl

% convert ficvf andf odi volumes from diffusion space to surface space
mri_vol2surf --src /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/NODDI/dir98/sub-MDP001_diff_1.1e-9_odi.nii --out /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/lh.sub-MDP001_dir98_diff_1.1e-9_odi.mgz --srcreg /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/register/dir98_reg.dat --hemi lh

mri_vol2surf --src /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/NODDI/dir98/sub-MDP001_diff_1.1e-9_odi.nii --out /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/rh.sub-MDP001_dir98_diff_1.1e-9_odi.mgz --srcreg /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/register/dir98_reg.dat --hemi rh

mri_vol2surf --src /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/NODDI/dir99/sub-MDP001_diff_1.1e-9_odi.nii --out /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/lh.sub-MDP001_dir99_diff_1.1e-9_odi.mgz --srcreg /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/register/dir99_reg.dat --hemi lh

mri_vol2surf --src /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/NODDI/dir99/sub-MDP001_diff_1.1e-9_odi.nii --out /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/rh.sub-MDP001_dir99_diff_1.1e-9_odi.mgz --srcreg /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/register/dir99_reg.dat --hemi rh

mri_vol2surf --src /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/NODDI/dir98/sub-MDP001_diff_1.1e-9_ficvf.nii --out /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/lh.sub-MDP001_dir98_diff_1.1e-9_ficvf.mgz --srcreg /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/register/dir98_reg.dat --hemi lh

mri_vol2surf --src /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/NODDI/dir98/sub-MDP001_diff_1.1e-9_ficvf.nii --out /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/rh.sub-MDP001_dir98_diff_1.1e-9_ficvf.mgz --srcreg /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/register/dir98_reg.dat --hemi rh

mri_vol2surf --src /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/NODDI/dir99/sub-MDP001_diff_1.1e-9_ficvf.nii --out /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/lh.sub-MDP001_dir99_diff_1.1e-9_ficvf.mgz --srcreg /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/register/dir99_reg.dat --hemi lh

mri_vol2surf --src /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/NODDI/dir99/sub-MDP001_diff_1.1e-9_ficvf.nii --out /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/rh.sub-MDP001_dir99_diff_1.1e-9_ficvf.mgz --srcreg /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/register/dir99_reg.dat --hemi rh
