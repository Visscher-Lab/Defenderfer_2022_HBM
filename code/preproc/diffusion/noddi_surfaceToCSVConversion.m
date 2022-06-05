function noddi_surfaceToCSVConversion(subj,fsdir,subdir,label_file,outdir)
%{
This function is designed to convert surface data for a subject to an 
easily read csv file. The user inputs various information about the subject
and the surfaces to convert

Inputs:
    subj: subject name as a string
    fsdir: directory where the subject's FreeSurfer folder is located
    subdir: directory where the subject's NODDI data are located
    label_file: path to the PRL/URL label for the subject
    outdir: where the resulting csv file will be stored.

Written by: Matt Defenderfer
Date: 11/20/2019
Updated: 3/5/20
%}

setenv('SUBJECTS_DIR',fsdir)

% read in the label and get hemisphere information from the label name
label = read_label(subj,strrep(label_file,'.label',''));
h = regexp(label_file,'[lr]h','match'); h = h{1};

% get the list of noddi output surface files
surfs = dir(fullfile(subdir,subj,[h '*.mgz']));

if isempty(surfs)
    return
end

% read in first surf to get number of vertices
s1 = load_mgh(fullfile(surfs(1).folder,surfs(1).name));

% get the vertex numbers. can use this to assign predictions back to the
% specific vertex down the line.
vertex = [1:length(s1)]'-1;

ind = label(:,1) + 1;

% create subject name and hemi vectors and add to the subCell variable

if contains(label_file,'lpz')
    l = regexp(label_file,'_([0-9]*).label','tokens'); l = ['LPZ_' l{1}{1}];
    d = 'No';
elseif contains(label_file,'full-area')
    l = 'full-V1';
    d = 'No';
else
    l = regexp(label_file,'[PU]RL','match'); l = l{1};
    if contains(label_file,'dilated')
        d = 'Yes';
    else
        d = 'No';
    end
end

subjname = cell(length(s1),1); subjname(:) = {subj};
hemi     = cell(length(s1),1); hemi(:) = {upper(h)};
loc      = cell(length(s1),1); loc(:) = {l};

subCell = [subjname,loc,num2cell(vertex),hemi]; 
varnames = {'Subject','Location','Vertex','Hemi'};

counter = size(subCell,2) + 1;

subCell(:,end+1:end+(length(surfs))) = {NaN};
varnames(end+1:end+(length(surfs))) = {[]};

for surfind = 1:length(surfs)
    surfFile = fullfile(surfs(surfind).folder,surfs(surfind).name);
    
    % Determine if the file exists and load if so. Replace with
    % NaN if does not exist
    if exist(surfFile,'file')
        surf = load_mgh(surfFile);
    else
        surf = nan(length(ecc),1);
    end
    
    % stick the result in the next available column
    subCell(:,counter) = num2cell(surf);
    
    name = regexp(surfs(surfind).name,[subj '_(.*).mgz'],'tokens'); name = name{1}{1};
    name = strrep(name,'e-9','');
    name = strrep(name,'.','');
    varnames{counter} = name;
    
    counter = counter + 1;
end

subCell = subCell(ind,:);

T = cell2table(subCell,'VariableNames',varnames);

if contains(label_file,'dilated')
    outname = [subj '_' h '_' l '_dilated.csv'];
else
    outname = [subj '_' h '_' l '.csv'];
end

writetable(T,fullfile(outdir,outname));
end