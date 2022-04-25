# This function collates the CSV files for each individual vision ROI for each
# subject (PRL, URL, LPZ) into a single csv file. This also adds mean thickness
# for each subject and calculates normalized thickness for each vertex as well

# Load libraries
library(janitor)
library(tidyverse)

# read in the individual vision roi csv files and perform the same filtering as on the training data
csvpath <- "/data/user/mdefende/datasets/MDP/SurfaceCSV-test/"
df <- list.files(path = csvpath, pattern = "*.csv", full.names = TRUE) %>%
  map_dfr(read_csv) %>%
  clean_names()

# remove the vertex tag from LPZ, convert hemi designation to lowercase for
# matching, and rename the thickness column
df <- df %>%
  mutate(location = str_remove(location,'_100'),
         hemi = tolower(hemi)) %>%
  rename(thick = thick0)

avg_thick <- read_csv('data/mean_hemi_thick.csv') %>%
  clean_names()

# merge with average hemispheric thickness value and calculate the normalized
# thickness
df_m <- left_join(df,avg_thick) %>%
  mutate(norm_thick = thick/avg_thick) %>%
  select(-avg_thick)

# write to an output csv
write_csv(df_m, file = 'data/vertexwise/thickness-vision-rois.csv')

