function check_dilate_RL_labels(subdir,subj,labeldir,cutoff,region,labelbase)
%{
This function reads in ?RL labels for a given subject, calculates
the number of vertices in each, and if the number of vertices is less than
a cutoff, dilates those labels. This process is applied to the PRL and URL
labels individually. 

For *RL labels that cross the vertical meridian and are located on both
hemispheres, the total number of vertices from the labels on both hemispheres
is compared to the cutoff. If that total number is less, both labels are
dilated until the cutoff is met.

If dilation is needed, vertices in the dilated label will be compared to a
list of vertices in the V* region the label comes from. Any vertices
falling outside of this region will be removed before the calculation of
the total number of vertices.

Inputs:
    subdir: subjects directory
    subj: name of the subject in subdir
    labeldir: folder inside <subj>/label to read from and write labels to
    cutoff: number of vertices needed in combined ?RL labels to stop
        dilation
    region: 'V1', 'V2', or 'V3'
    RL: 'PRL' or 'URL'
%}

%% general setup
% set subdir
setenv('SUBJECTS_DIR',subdir)

% load in the areas files for the subject and get the vertex numbers for
% the given region in both hemispheres
lharea = squeeze(load_mgh(fullfile(subdir,subj,'surf','lh.benson14_varea.mgz')));
rharea = squeeze(load_mgh(fullfile(subdir,subj,'surf','rh.benson14_varea.mgz')));

lhvert = find(lharea == str2double(region(2))) - 1;
rhvert = find(rharea == str2double(region(2))) - 1;

%% perform the thing on the prl labels
rl = dir(fullfile(subdir,subj,'label',labeldir,['*' region '*' labelbase '*']));

% remove any already dilated labels
rl(contains({rl.name},'dilated')) = [];

% get the number of vertices from each label with RL in the name
rlvert = [];
for rlnum = 1:length(rl)
    rlvert(rlnum) = length(read_label(subj,[labeldir '/' strrep(rl(rlnum).name,'.label','')])); %#ok<AGROW>
end

% if the sum of the number of vertices is less than cutoff
dilsteps = 0;
while sum(rlvert) < cutoff    
    
    % dilate each label by an increasing number of steps
    dilsteps = dilsteps + 1;
    for rlnum = 1:length(rl)
        % get the name of the label, if it doesn't contain 'dilated', add it
        if contains(rl(rlnum).name,'dilated')
            outname = rl(rlnum).name;
        else
            outname = strrep(rl(rlnum).name,labelbase,[labelbase '-dilated']);
        end
        
        % get the hemisphere from the labelname
        hemi = rl(rlnum).name(1:2);
        
        command = ['mri_label2label --s ' subj ...
            ' --srclabel ' fullfile(rl(rlnum).folder, rl(rlnum).name) ...
            ' --trglabel ' fullfile(rl(rlnum).folder, outname) ...
            ' --dilate ' num2str(dilsteps) ...
            ' --hemi ' hemi ' --regmethod surface'];
        
        system(command)
        
        % read back in the label, remove vertices outside the region, and
        % write back to the file
        parts = strsplit(fullfile(rl(rlnum).folder, outname),'label/');
        curlab = read_label(subj,strrep(parts{2},'.label',''));
        
        if strcmp(hemi,'lh')
            curlab(~ismember(curlab(:,1),lhvert),:) = [];
        elseif strcmp(hemi,'rh')
            curlab(~ismember(curlab(:,1),rhvert),:) = [];
        else
            error('Something went terribly wrong. The hemisphere was not properly deduced from the name of the label')
        end
        
        write_label(curlab(:,1),curlab(:,2:4),curlab(:,5),fullfile(rl(rlnum).folder, outname),subj)
    end
    
    rl = dir(fullfile(subdir,subj,'label',labeldir,['*' region '*' labelbase '-dilated*']));
    rlvert = [];
    for rlnum = 1:length(rl)
        rlvert(rlnum) = length(read_label(subj,[labeldir '/' strrep(rl(rlnum).name,'.label','')])); %#ok<AGROW>
    end
end

end