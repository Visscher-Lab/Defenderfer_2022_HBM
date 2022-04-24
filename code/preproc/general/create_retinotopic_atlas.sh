#!/bin/bash
#
#SBATCH --job-name=retatlas-%a
#SBATCH --output=retatlas-%A-%a.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=amd-hdr100
#SBATCH --time=30:00
#SBATCH --mem-per-cpu=8G

# set the path to the dataset directory
export SUBJECTS_DIR=/data/user/mdefende/datasets/MDP/subs

# set the path to the demographics file, and get the participant id from it based on the slurm array index
export demo_path=/data/user/mdefende/Projects/prl-struct/data
export pid=$(awk "NR==$(($SLURM_ARRAY_TASK_ID+2)){print;exit}" ${demo_path}/demographics.csv | cut -d ',' -f 1)

module load Anaconda3/2020.11

conda activate RetAtlas
PATH=$PATH:~/.local/bin

# uses neuropythy tool for transferring Benson retinotopic atlas
python -m neuropythy atlas ${pid} --verbose
