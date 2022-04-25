function combine_b0(scans,bvals,outfile)

combnii = [];
for ii = 1:length(scans)
    nii = load_nifti(scans{ii});
    fid = fopen(bvals{ii},'r');
    b = cell2mat(textscan(fid,'%f','Delimiter',' '));
    ind = b ~= 5;
    nii.vol(:,:,:,ind) = [];
    if isempty(combnii)
        combnii = nii.vol;
    else
        combnii = cat(4,combnii,nii.vol);
    end
end

niftiwrite(combnii,outfile)
end