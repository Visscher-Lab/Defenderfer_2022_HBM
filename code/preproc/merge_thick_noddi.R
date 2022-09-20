# Combine the thickness and noddi information into single dataframes. for the
# vision ROIs, average data within each ROI. for full-V1, add the grouping for
# the bar ROIs. add demographic information such as diagnosis, disease onset,
# etc. and save to new files for analysis

library(janitor)
library(tidyverse)

# demographics
demo <- read_csv('data/demographics.csv')

############################### Vision ROIs ####################################

vr_thick <- read_csv('data/vertexwise/thickness-vision-rois.csv')
vr_noddi <- read_csv('data/vertexwise/noddi-vision-rois.csv')

# clean variable names from demographics and join with thickness and noddi
# dataframes, then convert group variables to factors
vr_comb <- demo %>%
  clean_names() %>%
  select(subject, dx, onset, age, acuity) %>%
  right_join(vr_thick, by = 'subject') %>%
  right_join(vr_noddi, by = c('subject','vertex','hemi')) %>%
  mutate(across(c(subject,dx,onset,location), factor))

# compute average thickness, normalized thickness, ficvf, odi, and eccentricity
# of each ROI
vr_comb <- vr_comb %>%
  group_by(subject,dx,onset,location) %>%
  summarize(across(c(age,acuity,ecc,norm_thick:odi), mean, .names = '{.col}')) %>%
  ungroup()

# calculate average eccentricity of PRL and URL ROIs and assign back to them.
# This fixes an error of trying to compute a repeated measures covariate in the
# later ANCOVAs by converting it to a constant value for each participant
rl_ecc <- vr_comb %>%
  filter(location != 'LPZ') %>%
  select(subject, ecc) %>%
  group_by(subject) %>%
  summarize(mean_ecc = mean(ecc))

# crudely combine back with vr_comb and edit the relevant cells
vr_comb <- vr_comb %>%
  left_join(rl_ecc) %>%
  mutate(ecc = if_else(location != 'LPZ',mean_ecc,ecc)) %>%
  select(-mean_ecc)

save(vr_comb,file = 'data/vision_rois_struct_master.RData')

############################### Full V1 (fsaverage) ############################

f_thick <- read_csv('data/vertexwise/thickness-full-V1.csv')
f_noddi <- read_csv('data/vertexwise/noddi-full-V1.csv')

f_comb <- demo %>%
  clean_names() %>%
  select(subject, dx, onset) %>%
  inner_join(f_thick, by = 'subject') %>% #inner_join removes some participants with structural data but who were not included in the analysis
  left_join(f_noddi, by = c('subject','vertex','hemi','ecc')) %>%
  mutate(across(subject:hemi,as.factor))

# sort vertices into equally sized bins by their eccentricity and reassign the
# bins back to the f_comb dataframe

ecc <- f_comb %>% 
  select(hemi,vertex,ecc) %>%
  distinct() %>%
  mutate(roi = factor(cut_number(ecc, n = 8, labels = FALSE)))

f_comb <- f_comb %>%
  left_join(ecc, by = c('hemi','vertex','ecc')) %>%
  relocate(roi, .after = vertex)

save(f_comb,file = 'data/full_V1_struct_master.RData')
