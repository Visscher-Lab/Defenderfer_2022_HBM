#!/bin/bash
#SBATCH --partition=medium
#SBATCH --time=24:00:00
#SBATCH --ntasks=5
#SBATCH --mem-per-cpu=8G
#SBATCH --output=/data/user/mdefende/datasets/MDP-diff/jobs/sub-MDP001-dwi-FSL-preproc.txt

module load FSL/6.0.3

# Extract b0 images from AP and PA scans for both dir98 and dir99. Save in FSL directory
fslroi /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir98/sub-MDP001_acq-98_dir-AP_run-01_dwi.nii.gz /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/AP_b0 0 1

fslroi /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir98/sub-MDP001_acq-98_dir-PA_run-01_dwi.nii.gz /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/PA_b0 0 1

fslmerge -t /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/both_b0 /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/AP_b0 /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/PA_b0


fslroi /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir99/sub-MDP001_acq-99_dir-AP_run-01_dwi.nii.gz /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/AP_b0 0 1

fslroi /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir99/sub-MDP001_acq-99_dir-PA_run-01_dwi.nii.gz /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/PA_b0 0 1

fslmerge -t /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/both_b0 /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/AP_b0 /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/PA_b0

# Create the acqparams.txt files 
printf "0 -1 0 0.112 \n0 1 0 0.112" > /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/acqparams.txt
printf "0 -1 0 0.112 \n0 1 0 0.112" > /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/acqparams.txt

# run topup for both dir98 and dir99
topup --imain=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/both_b0 --datain=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/acqparams.txt --config=b02b0.cnf  --out=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/topup_AP_PA_b0 --iout=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/unwarp_b0  --fout=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/fout

topup --imain=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/both_b0 --datain=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/acqparams.txt --config=b02b0.cnf  --out=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/topup_AP_PA_b0 --iout=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/unwarp_b0  --fout=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/fout

# Perform brain extraction for both dir98 and dir99
fslmaths /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/unwarp_b0 -Tmean /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/unwarp_b0
bet /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/unwarp_b0 /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/unwarp_b0_brain -m

fslmaths /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/unwarp_b0 -Tmean /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/unwarp_b0
bet /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/unwarp_b0 /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/unwarp_b0_brain -m

# Merge raw PA to raw AP
fslmerge -t /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/sub-MDP001-AP_PA_dir98_raw /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir98/sub-MDP001_acq-98_dir-AP_run-01_dwi.nii.gz /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir98/sub-MDP001_acq-98_dir-PA_run-01_dwi.nii.gz
fslmerge -t /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/sub-MDP001-AP_PA_dir99_raw /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir99/sub-MDP001_acq-99_dir-AP_run-01_dwi.nii.gz /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir99/sub-MDP001_acq-99_dir-PA_run-01_dwi.nii.gz

# Merge AP and PA bvals files
paste -d ' ' /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir98/sub-MDP001_acq-98_dir-AP_run-01_dwi.bval /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir98/sub-MDP001_acq-98_dir-PA_run-01_dwi.bval > /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/AP_PA_dir98.bval

paste -d ' ' /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir99/sub-MDP001_acq-99_dir-AP_run-01_dwi.bval /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir99/sub-MDP001_acq-99_dir-PA_run-01_dwi.bval > /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/AP_PA_dir99.bval

# Merge AP and PA bvecs files
paste -d ' ' /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir98/sub-MDP001_acq-98_dir-AP_run-01_dwi.bvec /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir98/sub-MDP001_acq-98_dir-PA_run-01_dwi.bvec > /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/AP_PA_dir98.bvec

paste -d ' ' /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir99/sub-MDP001_acq-99_dir-AP_run-01_dwi.bvec /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/raw/dir99/sub-MDP001_acq-99_dir-PA_run-01_dwi.bvec > /data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/AP_PA_dir99.bvec

# Run eddy on dir98 and dir99 scans
eddy_openmp --imain=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/sub-MDP001-AP_PA_dir98_raw --mask=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/unwarp_b0_brain_mask --acqp=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/acqparams.txt --index=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/index.txt --bvecs=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/AP_PA_dir98.bvec --bvals=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/AP_PA_dir98.bval --topup=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/topup_AP_PA_b0 --out=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir98/sub-MDP001-AP_PA_dir98_raw --flm=quadratic

eddy_openmp --imain=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/sub-MDP001-AP_PA_dir99_raw --mask=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/unwarp_b0_brain_mask --acqp=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/acqparams.txt --index=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/index.txt --bvecs=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/AP_PA_dir99.bvec --bvals=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/AP_PA_dir99.bval --topup=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/topup_AP_PA_b0 --out=/data/user/mdefende/datasets/MDP-diff/subs/sub-MDP001/FSL/dir99/sub-MDP001-AP_PA_dir99_raw --flm=quadratic

