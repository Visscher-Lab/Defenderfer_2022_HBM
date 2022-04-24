subdir = '/data/user/mdefende/datasets/MDP/subs';

% load the demographics file to loop through participants kept in the study
demo = readtable('/data/user/mdefende/Projects/prl-struct/data/demographics.csv');
subs = demo.Subject;
hemi = {'lh','rh'};

thick = cell(length(subs)*2,3);
counter = 1;

for ii = 1:length(subs)
    for jj = 1:length(hemi)
    hthick = read_curv(fullfile(subdir,subj,'surf',[hemi{jj} '.thickness']));
    hthick(hthick == 0) = [];
    
    thick{counter,1} = subs{ii};
    thick{counter,2} = hemi{jj};
    thick{counter,3} = mean(hthick);
    counter = counter+1;
    end
end

T = cell2table(thick,'VariableNames',{'Subject','Hemi','Avg_Thick'});
writetable(T,'/data/user/mdefende/Projects/prl-struct/data/mean_hemi_thick.csv')