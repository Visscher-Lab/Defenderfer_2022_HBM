fsdir = '/data/user/mdefende/datasets/MDP/subs';
subdir = '/data/user/mdefende/datasets/MDP-diff/subs';
jobdir = '/data/user/mdefende/datasets/MDP-diff/jobs/register';

subs = dir(fullfile(subdir,'sub-*'));

for ii = 1:length(subs)
    % get all the noddi files for the subject
    noddi = [dir(fullfile(subdir,subs(ii).name,'NODDI','**','*odi*')); dir(fullfile(subdir,subs(ii).name,'NODDI','**','*ficvf*'))];
    
    % make directory to hold all the registration files
    if ~exist(fullfile(subdir,subs(ii).name,'register'),'dir')
        mkdir(fullfile(subdir,subs(ii).name,'register'))
    end
    
    % open the sub's job file
    jobname = fullfile(jobdir,[subs(ii).name '-reg.sh']);
    fid = fopen(jobname,'w');
    
    % write sbatch options
    fprintf(fid,'#!/bin/bash\n');
    fprintf(fid,'#SBATCH --partition=express\n');
    fprintf(fid,'#SBATCH --time=2:00:00\n');
    fprintf(fid,'#SBATCH --ntasks=1\n');
    fprintf(fid,'#SBATCH --mem-per-cpu=8G\n');
    fprintf(fid,['#SBATCH --output=' strrep(jobname,'.sh','.txt') '\n\n']);
    
    % write FreeSurfer setup commands
    fprintf(fid,'module load FreeSurfer/6.0.0-centos6_x86_64\n');
    fprintf(fid,['SUBJECTS_DIR=' fsdir '\n\n']);
    
    % write the bbregister commands,if there are dir98 and dir99 scans
    if any(contains({noddi.folder},'dir98'))
        fprintf(fid,['bbregister --s ' subs(ii).name ' --mov ' fullfile(subdir,subs(ii).name,'FSL','dir98','unwarp_b0.nii.gz') ' --dti --reg ' fullfile(subdir,subs(ii).name,'register','dir98_reg.dat') ' --init-fsl\n']);
    end
    
    
    if any(contains({noddi.folder},'dir99'))
        fprintf(fid,['bbregister --s ' subs(ii).name ' --mov ' fullfile(subdir,subs(ii).name,'FSL','dir99','unwarp_b0.nii.gz') ' --dti --reg ' fullfile(subdir,subs(ii).name,'register','dir99_reg.dat') ' --init-fsl\n']);
    end
    
    fprintf(fid,'\n');
    
    for jj = 1:length(noddi)
        % get number of directions from folder name
        ndir = regexp(noddi(jj).folder,'dir9[89]','match'); ndir = ndir{1};
        
        % create the base output name for the surface files
        outname = strrep(noddi(jj).name,'.nii','.mgz');
        outname = strrep(outname,subs(ii).name,[subs(ii).name '_' ndir]);
        
        if contains(noddi(jj).folder,'dir98')
            fprintf(fid,['mri_vol2surf --src ' fullfile(noddi(jj).folder,noddi(jj).name) ...
                ' --out ' fullfile(subdir,subs(ii).name,['lh.' outname]) ...
                ' --srcreg ' fullfile(subdir,subs(ii).name,'register','dir98_reg.dat') ...
                ' --hemi lh\n']);
            
            fprintf(fid,['mri_vol2surf --src ' fullfile(noddi(jj).folder,noddi(jj).name) ...
                ' --out ' fullfile(subdir,subs(ii).name,['rh.' outname]) ...
                ' --srcreg ' fullfile(subdir,subs(ii).name,'register','dir98_reg.dat') ...
                ' --hemi rh\n']);
        elseif contains(noddi(jj).folder,'dir99')
            fprintf(fid,['mri_vol2surf --src ' fullfile(noddi(jj).folder,noddi(jj).name) ...
                ' --out ' fullfile(subdir,subs(ii).name,['lh.' outname]) ...
                ' --srcreg ' fullfile(subdir,subs(ii).name,'register','dir99_reg.dat') ...
                ' --hemi lh\n']);
            
            fprintf(fid,['mri_vol2surf --src ' fullfile(noddi(jj).folder,noddi(jj).name) ...
                ' --out ' fullfile(subdir,subs(ii).name,['rh.' outname]) ...
                ' --srcreg ' fullfile(subdir,subs(ii).name,'register','dir99_reg.dat') ...
                ' --hemi rh\n']);
        end
    end
    
    fclose(fid);
end