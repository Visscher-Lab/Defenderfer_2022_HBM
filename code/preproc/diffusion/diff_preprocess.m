function diff_preprocess(subj,subdir,rawdir,jobdir)
%{
This function controls diffusion data preprocessing using FSL for MDP
subjects. Data transfer and directory setup is handled in MATLAB. These
general folders will be created:

subdir/subj/raw/dir9[89]
subdir/subj/FSL/dir9[89]

A bash script will be written and will perform both topup and eddy on each
pair of scans.
%}

% make the raw and FSL directories for the given subject. On
if ~exist(fullfile(subdir,subj,'raw','dir98'),'dir')
    mkdir(fullfile(subdir,subj,'raw','dir98'))
end

if ~exist(fullfile(subdir,subj,'raw','dir99'),'dir')
    mkdir(fullfile(subdir,subj,'raw','dir99'))
end

if ~exist(fullfile(subdir,subj,'FSL','dir98'),'dir')
    mkdir(fullfile(subdir,subj,'FSL','dir98'))
else
    rmdir(fullfile(subdir,subj,'FSL','dir98'))
end

if ~exist(fullfile(subdir,subj,'FSL','dir99'),'dir')
    mkdir(fullfile(subdir,subj,'FSL','dir99'))
end

if ~isempty(rawdir)
    % copy data from rawdir to subdir
    copyfile(fullfile(rawdir,'*98*'),fullfile(subdir,subj,'raw','dir98'))
    copyfile(fullfile(rawdir,'*99*'),fullfile(subdir,subj,'raw','dir99'))
end

% check if there are two scans in the raw 98 and raw 99 folders, one AP and
% one PA
scans98 = dir(fullfile(subdir,subj,'raw','dir98','*nii.gz'));
scans99 = dir(fullfile(subdir,subj,'raw','dir99','*nii.gz'));

bvals98 = dir(fullfile(subdir,subj,'raw','dir98','*bval'));
bvals99 = dir(fullfile(subdir,subj,'raw','dir99','*bval'));

bvecs98 = dir(fullfile(subdir,subj,'raw','dir98','*bvec'));
bvecs99 = dir(fullfile(subdir,subj,'raw','dir99','*bvec'));


if length(scans98) ~= 2
    disp(['The number of scans for subject ' subj ' is not 2 for dir98'])
    return
elseif sum(any(contains({scans98.name},'AP'))) ~= 1
    disp(['There is no dir98 AP scan for subject ' subj])
    return
elseif sum(any(contains({scans98.name},'PA'))) ~= 1
    disp(['There is no dir98 PA scan for subject ' subj])
    return
end

if length(scans99) ~= 2
    disp(['The number of scans for subject ' subj ' is not 2 for dir99'])
    return
elseif sum(any(contains({scans99.name},'AP'))) ~= 1
    disp(['There is no dir99 AP scan for subject ' subj])
    return
elseif sum(any(contains({scans99.name},'PA'))) ~= 1
    disp(['There is no dir99 PA scan for subject ' subj])
    return
end

% open the job file
fid = fopen(fullfile(jobdir,[subj '-dwi-FSL-preproc.sh']),'w');

% write sbatch options
fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'#SBATCH --partition=medium\n');
fprintf(fid,'#SBATCH --time=24:00:00\n');
fprintf(fid,'#SBATCH --ntasks=5\n');
fprintf(fid,'#SBATCH --mem-per-cpu=8G\n');
fprintf(fid,['#SBATCH --output=' fullfile(jobdir,[subj '-dwi-FSL-preproc.txt\n\n'])]);

fprintf(fid,'module load FSL/6.0.3\n\n');

% extract b0 images from AP and PA images, save in corresponding FSL
% directory
fprintf(fid,'# Extract b0 images from AP and PA scans for both dir98 and dir99. Save in FSL directory\n');

outdir98 = strrep(scans98(1).folder,'raw','FSL');
fprintf(fid,['#fslroi ' fullfile(scans98(1).folder,scans98(1).name) ' ' fullfile(outdir98,'AP_b0') ' 0 1\n']);
fprintf(fid,['#fslroi ' fullfile(scans98(2).folder,scans98(2).name) ' ' fullfile(outdir98,'PA_b0') ' 0 1\n']);
fprintf(fid,['#fslmerge -t ' fullfile(outdir98,'both_b0') ' ' fullfile(outdir98,'AP_b0') ' ' fullfile(outdir98,'PA_b0\n\n')]);

outdir99 = strrep(scans99(1).folder,'raw','FSL');
fprintf(fid,['#fslroi ' fullfile(scans99(1).folder,scans99(1).name) ' ' fullfile(outdir99,'AP_b0') ' 0 1\n']);
fprintf(fid,['#fslroi ' fullfile(scans99(2).folder,scans99(2).name) ' ' fullfile(outdir99,'PA_b0') ' 0 1\n']);
fprintf(fid,['#fslmerge -t ' fullfile(outdir99,'both_b0') ' ' fullfile(outdir99,'AP_b0') ' ' fullfile(outdir99,'PA_b0\n\n')]);

% create acqparams.txt files
fprintf(fid,'# Create the acqparams.txt files \n');
fprintf(fid,['#printf "0 -1 0 0.112 \\n0 1 0 0.112" > ' fullfile(outdir98,'acqparams.txt') '\n']);
fprintf(fid,['#printf "0 -1 0 0.112 \\n0 1 0 0.112" > ' fullfile(outdir99,'acqparams.txt') '\n\n']);

% create topup commands
fprintf(fid,'# run topup for both dir98 and dir99\n');
topup98 = ['#topup --imain=' fullfile(outdir98,'both_b0') ...
                ' --datain=' fullfile(outdir98,'acqparams.txt') ...
                ' --config=b02b0.cnf ' ...
                ' --out=' fullfile(outdir98,'topup_AP_PA_b0') ...
                ' --iout=' fullfile(outdir98,'unwarp_b0 ') ...
                ' --fout=' fullfile(outdir98,'fout') '\n\n'];

topup99 = ['#topup --imain=' fullfile(outdir99,'both_b0') ...
                ' --datain=' fullfile(outdir99,'acqparams.txt') ...
                ' --config=b02b0.cnf ' ...
                ' --out=' fullfile(outdir99,'topup_AP_PA_b0') ...
                ' --iout=' fullfile(outdir99,'unwarp_b0 ') ...
                ' --fout=' fullfile(outdir99,'fout') '\n\n'];
            
fprintf(fid,topup98);
fprintf(fid,topup99);

% write commands for brain extraction
fprintf(fid,'# Perform brain extraction for both dir98 and dir99\n');
fprintf(fid,['#fslmaths ' fullfile(outdir98,'unwarp_b0') ' -Tmean ' fullfile(outdir98,'unwarp_b0') '\n']);
fprintf(fid,['bet ' fullfile(outdir98,'unwarp_b0') ' ' fullfile(outdir98,'unwarp_b0_brain') ' -m -f 0.1\n\n']);

fprintf(fid,['#fslmaths ' fullfile(outdir99,'unwarp_b0') ' -Tmean ' fullfile(outdir99,'unwarp_b0') '\n']);
fprintf(fid,['bet ' fullfile(outdir99,'unwarp_b0') ' ' fullfile(outdir99,'unwarp_b0_brain') ' -m -f 0.1\n\n']);

% merge PA to AP
fprintf(fid,'# Merge raw PA to raw AP\n');
fprintf(fid,['fslmerge -t ' fullfile(subdir,subj,'FSL','dir98',[subj '-AP_PA_dir98_raw']) ' ' ...
    fullfile(scans98(1).folder,scans98(1).name) ' ' ...
    fullfile(scans98(2).folder,scans98(2).name) '\n']);

fprintf(fid,['fslmerge -t ' fullfile(subdir,subj,'FSL','dir99',[subj '-AP_PA_dir99_raw']) ' ' ...
    fullfile(scans99(1).folder,scans99(1).name) ' ' ...
    fullfile(scans99(2).folder,scans99(2).name) '\n\n']);

% merge bvals files
fprintf(fid,'# Merge AP and PA bvals files\n');
fprintf(fid,['#paste -d '' '' ' fullfile(bvals98(1).folder, bvals98(1).name) ' ' ...
    fullfile(bvals98(2).folder, bvals98(2).name) ' > ' ...
    fullfile(subdir,subj,'FSL','dir98','AP_PA_dir98.bval') '\n']);

fprintf(fid,['#paste -d '' '' ' fullfile(bvals99(1).folder, bvals99(1).name) ' ' ...
    fullfile(bvals99(2).folder, bvals99(2).name) ' > ' ...
    fullfile(subdir,subj,'FSL','dir99','AP_PA_dir99.bval') '\n\n']);

% merge bvecs files
fprintf(fid,'# Merge AP and PA bvecs files\n');
fprintf(fid,['#paste -d '' '' ' fullfile(bvecs98(1).folder, bvecs98(1).name) ' ' ...
    fullfile(bvecs98(2).folder, bvecs98(2).name) ' > ' ...
    fullfile(subdir,subj,'FSL','dir98','AP_PA_dir98.bvec') '\n']);

fprintf(fid,['#paste -d '' '' ' fullfile(bvecs99(1).folder, bvecs99(1).name) ' ' ...
    fullfile(bvecs99(2).folder, bvecs99(2).name) ' > ' ...
    fullfile(subdir,subj,'FSL','dir99','AP_PA_dir99.bvec') '\n\n']);
    

% write eddy commands
fprintf(fid,'# Run eddy on dir98 and dir99 scans\n');
imain98 = fullfile(subdir,subj,'FSL','dir98',[subj '-AP_PA_dir98_raw']);
eddy98 = ['eddy_openmp --imain=' imain98 ...
                       ' --mask=' fullfile(outdir98,'unwarp_b0_brain_mask') ...
                       ' --acqp=' fullfile(outdir98,'acqparams.txt') ...
                       ' --index=' fullfile(outdir98,'index.txt') ...
                       ' --bvecs=' fullfile(subdir,subj,'FSL','dir98','AP_PA_dir98.bvec') ...
                       ' --bvals=' fullfile(subdir,subj,'FSL','dir98','AP_PA_dir98.bval') ...
                       ' --topup=' fullfile(outdir98,'topup_AP_PA_b0') ...
                       ' --out=' strrep(imain98,'raw','eddy') ...
                       ' --flm=quadratic\n\n'];

imain99 = fullfile(subdir,subj,'FSL','dir99',[subj '-AP_PA_dir99_raw']);
eddy99 = ['eddy_openmp --imain='  imain99 ...
                       ' --mask=' fullfile(outdir99,'unwarp_b0_brain_mask') ...
                       ' --acqp=' fullfile(outdir99,'acqparams.txt') ...
                       ' --index=' fullfile(outdir99,'index.txt') ...
                       ' --bvecs=' fullfile(subdir,subj,'FSL','dir99','AP_PA_dir99.bvec') ...
                       ' --bvals=' fullfile(subdir,subj,'FSL','dir99','AP_PA_dir99.bval') ...
                       ' --topup=' fullfile(outdir99,'topup_AP_PA_b0') ...
                       ' --out=' strrep(imain99,'raw','eddy') ...
                       ' --flm=quadratic\n\n'];

fprintf(fid,eddy98);
fprintf(fid,eddy99);
fclose(fid);

% create the index files for each scan
for ii = 1:length(scans98)
    s = load_nifti(fullfile(scans98(ii).folder,scans98(ii).name));
    s_size = size(s.vol);
    
    file = fullfile(strrep(scans98(ii).folder,'raw','FSL'),'index.txt');
    
    fid = fopen(file,'a');
    for jj = 1:s_size(4)
        if contains(scans98(ii).name,'AP')
            fprintf(fid,'1\n');
        else
            fprintf(fid,'2\n');
        end
    end
    fclose(fid);
end

for ii = 1:length(scans99)
    s = load_nifti(fullfile(scans99(ii).folder,scans99(ii).name));
    s_size = size(s.vol);
    
    file = fullfile(strrep(scans99(ii).folder,'raw','FSL'),'index.txt');
    
    fid = fopen(file,'a');
    for jj = 1:s_size(4)
        if contains(scans99(ii).name,'AP')
            fprintf(fid,'1\n');
        else
            fprintf(fid,'2\n');
        end
    end
    fclose(fid);
end

end
