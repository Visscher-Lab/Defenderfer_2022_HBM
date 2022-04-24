function transfer_prl_url(subdir,subj,outdir,match,hemi,labelbase,vr)

lab = dir(fullfile(subdir, subj,'label',outdir,['*' hemi '*' vr '*' labelbase '*']));

if any(contains({lab.name},'dilated'))
    lab(~contains({lab.name},'dilated')) = [];
end

if ~isempty(lab)
    if ~exist(strrep(lab(1).folder,subj,match),'dir')
        mkdir(strrep(lab(1).folder,subj,match))
    end
    
    for labnum = 1:length(lab)
        system(['mri_label2label --srcsubject ' subj ' --trgsubject ' match ...
            ' --srclabel ' fullfile(lab(labnum).folder,lab(labnum).name) ...
            ' --trglabel ' fullfile(strrep(lab(labnum).folder,subj,match),lab(labnum).name) ...
            ' --regmethod surface --hemi ' hemi])
    end
end
end
