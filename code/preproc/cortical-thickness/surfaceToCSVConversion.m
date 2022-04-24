function surfaceToCSVConversion(subj,subdir,label_file,surfs,fwhm,outdir)
%{
This function is designed to convert surface data for a subject to an 
easily read csv file. The user inputs various information about the subject
and the surfaces to convert

Inputs:
    subj: subject name as a string
    subdir: directory where the subject's FreeSurfer folder is located
    label_file: path to the given label for the subject
    surfs: cell array of surface file stems such as 'thickness', 'sulc',
           etc.
    fwhm: array of fwhms to include
    demo_path: full path to demographics file, typically getting
        information such as age.
    outdir: where the resulting csv file will be stored.
    csvbase: string that will be added to the subject name when writing to
        a csv file. So csv files will have the form <subject><csvbase>.csv


Written by: Matt Defenderfer
Date: 11/20/2019
Updated: 3/5/20
%}

setenv('SUBJECTS_DIR',subdir)

% read in the label and get hemisphere information from the label name
x = regexp(label_file,'(?<=/label/)(.*)','match'); x = x{1};
label = read_label(subj,strrep(x,'.label',''));
h = regexp(x,'[lr]h','match'); h = h{1};
o = regexp(x,'sub-MDP[0-9]{3}','match'); 

if ~isempty(o)
    o = o{1};
else
    o = subj;
end

% First step: read in ecc, pol, and areas
disp([subj ' has begun'])
ecc = squeeze(load_mgh(fullfile(subdir,subj,'surf',[h '.benson14_eccen.mgz'])));
pol = squeeze(load_mgh(fullfile(subdir,subj,'surf',[h '.benson14_angle.mgz'])));

% get the vertex numbers. can use this to assign predictions back to the
% specific vertex down the line.
vertex = [1:length(ecc)]'-1;

ind = label(:,1) + 1;

% create subject name, age, gender, and hemi vectors and add to the
% subCell variable

if contains(label_file,'lpz')
    l = regexp(label_file,'_([0-9]*).label','tokens'); l = ['LPZ_' l{1}{1}];
    d = 'No';
elseif contains(label_file,'full')
    l = 'full-V1';
    d = 'No';
elseif contains(label_file,'cortex')
    l = 'cortex';
    d = 'No';
else
    l = regexp(label_file,'[PU]RL','match'); l = l{1};
    if contains(label_file,'dilated')
        d = 'Yes';
    else
        d = 'No';
    end
end

subjname = cell(length(ecc),1); subjname(:) = {subj};
hemi     = cell(length(ecc),1); hemi(:) = {upper(h)};
loc      = cell(length(ecc),1); loc(:) = {l};

subCell = [subjname,loc,num2cell(vertex),hemi,num2cell(ecc),num2cell(pol)]; 
varnames = {'Subject','Location','Vertex','Hemi','Ecc','Pol'};

counter = size(subCell,2) + 1;

subCell(:,end+1:end+(length(surfs)*length(fwhm))) = {NaN};
varnames(end+1:end+(length(surfs)*length(fwhm))) = {[]};

for surfind = 1:length(surfs)
    for fwhmind = 1:length(fwhm)
        disp([surfs{surfind} ' ' num2str(fwhm(fwhmind))])
        % Determine the file name and location based on fwhm
        if fwhm(fwhmind) == 0
            surfFile = fullfile(subdir,subj,'surf',[h '.' surfs{surfind}]);
        else
            surfFile = fullfile(subdir,subj,'surf','MKD_surfs',[h '.' surfs{surfind} '.fwhm' num2str(fwhm(fwhmind))]);
        end

        % Determine if the file exists and load if so. Replace with
        % NaN if does not exist
        if exist(surfFile,'file')
            surf = read_curv(surfFile);
        else
            surf = nan(length(ecc),1);
        end
               
        % stick the result in the next available column
        subCell(:,counter) = num2cell(surf);
        
        % change the name based on the surface
        if strcmp(surfs{surfind},'thickness')
            varnames{counter} = ['Thick' num2str(fwhm(fwhmind))];
        elseif strcmp(surfs{surfind},'curv.K')
            varnames{counter} = ['CurvK' num2str(fwhm(fwhmind))];
        elseif strcmp(surfs{surfind},'curv.H')
            varnames{counter} = ['CurvH' num2str(fwhm(fwhmind))];
        elseif strcmp(surfs{surfind},'curv.pial.K')
            varnames{counter} = ['PialCurvK' num2str(fwhm(fwhmind))];
        elseif strcmp(surfs{surfind},'curv.pial.H')
            varnames{counter} = ['PialCurvH' num2str(fwhm(fwhmind))];
        elseif strcmp(surfs{surfind},'area')
            varnames{counter} = ['Area' num2str(fwhm(fwhmind))];
        elseif strcmp(surfs{surfind},'area.mid')
            varnames{counter} = ['MidArea' num2str(fwhm(fwhmind))];
        elseif strcmp(surfs{surfind},'area.pial')
            varnames{counter} = ['PialArea' num2str(fwhm(fwhmind))];
        elseif strcmp(surfs{surfind},'pial_lgi')
            varnames{counter} = ['LGI' num2str(fwhm(fwhmind))];
        elseif strcmp(surfs{surfind},'sulc')
            varnames{counter} = ['Sulc' num2str(fwhm(fwhmind))];
        end
        
        counter = counter + 1;
    end
end

subCell = subCell(ind,:);

T = cell2table(subCell,'VariableNames',varnames);

if contains(label_file,'dilated')
    outname = [subj '_' h '_' l '_src_' o '_dilated.csv'];
else
    outname = [subj '_' h '_' l '_src_' o '.csv'];
end

writetable(T,fullfile(outdir,outname));
end