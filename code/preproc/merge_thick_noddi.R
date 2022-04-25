# Combine the thickness and noddi information into single dataframes. for the
# vision ROIs, average data within each ROI. for full-V1, add the grouping for
# the bar ROIs. add demographic information such as diagnosis, disease onset,
# etc. and save to new files for analysis

library(janitor)
library(tidyverse)

# demographics
demo <- read_csv('data/demographics.csv')

# Vision ROIs

vr_thick <- read_csv('data/vertexwise/thickness-vision-rois.csv')
vr_noddi <- read_csv('data/vertexwise/noddi-vision-rois.csv')

vr_comb <- demo %>%
  clean_names() %>%
  select(subject, dx, onset) %>%
  right_join(vr_thick, by = 'subject') %>%
  right_join(vr_noddi, by = c('subject','vertex','hemi')) %>%
  group_by(subject,dx,onset,location) %>%
  summarize(across(c(ecc,norm_thick:odi), mean, .names = '{.col}')) %>%
  ungroup() %>%
  mutate(across(subject:location, factor))

save(vr_comb,file = 'data/vision_rois_master.RData')

# full V1

f_thick <- read_csv('data/vertexwise/thickness-full-V1.csv')
f_noddi <- read_csv('data/vertexwise/noddi-full-V1.csv')


demo %>%
  clean_names() %>%
  select(subject, dx, onset) %>%
  right_join(f_thick, by = 'subject') %>%
  right_join(f_noddi, by = c('subject','vertex','hemi'))
