# This function collates the CSV files for each individual vision ROI for each
# subject (PRL, URL, LPZ) into a single csv file. This also adds mean thickness
# for each subject and calculates normalized thickness for each vertex as well

# Load libraries
library(magrittr)
library(DescTools)
library(freesurfer)
library(tidyverse)

# read in the individual vision roi csv files and perform the same filtering as on the training data
csvpath <- "/data/user/mdefende/datasets/MDP/SurfaceCSV/"
df <- list.files(path = csvpath, pattern = "*.csv", full.names = TRUE) %>%
  map_dfr(read_csv) %>%
  filter_at(vars(contains("Thick")), all_vars(between(.,0.3,5))) %>%  # Thickness bound is 0.3-5
  filter_at(vars(contains("Curv")), all_vars(between(.,-3,3))) %>% # Curv bound from -3,3
  filter_at(vars(contains("Area")), all_vars(between(.,0.01,3))) %>%
  filter(!is.na(LGI0)) %>%
  filter_at(vars(contains("LGI")), all_vars(between(.,0,5.5)))

# write function to extract average thickness values for individual subjects' hemispheres
get_avg_thick <- function(subj) {
  lh0.mean <- freesurfer::freesurfer_read_curv(file.path(subj,'surf/lh.thickness')) %>%
    subset(. != 0) %>%
    mean()
  
  rh0.mean <- freesurfer::freesurfer_read_curv(file.path(subj,'surf/rh.thickness')) %>%
    subset(. != 0) %>%
    mean()
  
  lh2.mean <- freesurfer::freesurfer_read_curv(file.path(subj,'surf/MKD_surfs/lh.thickness.fwhm2')) %>%
    subset(. != 0) %>%
    mean()
  
  rh2.mean <- freesurfer::freesurfer_read_curv(file.path(subj,'surf/MKD_surfs/rh.thickness.fwhm2')) %>%
    subset(. != 0) %>%
    mean()
  
  subname <- SplitPath(subj)$filename
  
  tmp.df <- tibble(Subject = subname,
                   MeanLHThick0 = lh0.mean,
                   MeanRHThick0 = rh0.mean,
                   MeanLHThick2 = lh2.mean,
                   MeanRHThick2 = rh2.mean)
  
  return(tmp.df)
}

# Calculate average hemisphere thickness for each subject
mean.thick <- list.files('/data/user/mdefende/datasets/MDP/subs',pattern = 'sub-*', full.names = TRUE) %>%
  map(get_avg_thick) %>%
  bind_rows()

# pivot the table and rename the variables 
mean.thick %<>%
  pivot_longer(cols = MeanLHThick0:MeanRHThick2,
               names_to = c('Hemi','.value'),
               names_pattern = "Mean([LR]H)(Thick[02])") %>%
  rename(MeanThick0 = Thick0,
         MeanThick2 = Thick2)

# join the two tables and calculate the normalized thickness for each vertex
df <- left_join(df,mean.thick, by = c('Subject','Hemi')) %>%
  mutate(NormThick0 = Thick0/MeanThick0,
         NormThick2 = Thick2/MeanThick2)

# move the columns around
df %<>%
  relocate(contains('Thick'), .after = Pol)

# write to an output csv
write_csv(df, path = '/data/user/mdefende/Projects/prl-thickness/data/input/MDP-vision-rois.csv')

