projdir = '/data/user/mdefende/datasets/MDP';

% subject's directory
fsdir = fullfile(projdir,'subs');
surfdir = fullfile(fsdir,'fsaverage','surf','MKD_surfs','mdp-thickness');

% load the demographics file to loop through participants kept in the study
demo = readtable('/data/user/mdefende/Projects/prl-struct/data/demographics.csv');
subs = demo.Subject;

% set output directory for the csv files
outdir = fullfile(projdir,'SurfaceCSV_full_V1-test');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

% get label file names defining left and right V1 on fsaverage
lhV1 = read_label('fsaverage','MKD_labels/lh.V1_eccen');
rhV1 = read_label('fsaverage','MKD_labels/rh.V1_eccen');

for ii = 1:length(subs)
    % left hemisphere
    lhsurfname = ['lh.' subs{ii} '.thickness'];
    lhthick = read_curv(fullfile(surfdir,surfname));
    lh_V1_thick = lhthick(lhV1(:,1)+1);
    lh_c = [lhV1(:,1), lhV1(:,5), lh_V1_thick];
    
    
    % right hemisphere
    rhsurfname = ['rh.' subs{ii} '.thickness'];
    rhthick = read_curv(fullfile(surfdir,surfname));
    rh_V1_thick = rhthick(rhV1(:,1)+1);
    rh_c = [rhV1(:,1), rhV1(:,5), rh_V1_thick];
    
    % combine
    h_c = num2cell([lh_c;rh_c]);
    
    subj = cell(length(h_c),1); subj(:) = subs(ii);
    hemi = cell(length(h_c),1); hemi(1:length(lhV1)) = {'LH'}; hemi(length(lhV1)+1:end) = {'RH'};
    
    full_c = [subj,hemi,h_c];
    
    T = cell2table(full_c,'VariableNames',{'Subject','Hemi','Vertex','Ecc','Thick'});
    
    writetable(T,fullfile(outdir,[subs{ii} '_full-V1.csv']));
end