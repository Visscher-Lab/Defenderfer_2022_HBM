# This function collates csv files containing cortical thickness values of each
# vertex in V1 for each participant into a single csv file. This also adds mean
# thickness for each subject and calculates normalized thickness for each vertex
# as well

# Load libraries
library(janitor)
library(freesurferformats)
library(tidyverse)

# read in thickness files and extract fsaverage V1
read_thickness_V1 <- function(filename){
  hemi <- str_extract(filename, '[lr]h')
  subj <- str_extract(filename, 'sub-MDP[0-9]{3}')
  
  V1_label <- read.fs.label(paste0('data/fsavg_labels/',hemi,'.V1_eccen.label'), return_one_based_indices = FALSE, full = TRUE)
  V1_label <- V1_label$vertexdata
  
  curv <- read.fs.curv(filename)
  curv <- curv[V1_label$vertex_index+1]
  
  df <- data.frame(subject = subj,
                   hemi = hemi,
                   vertex = V1_label$vertex_index,
                   ecc = V1_label$value,
                   thick = curv
  )
  
  
}

thickness <- list.files('/data/user/mdefende/datasets/MDP/subs/fsaverage/surf/MKD_surfs/mdp-thickness',pattern = '*thickness', full.names = TRUE) %>%
  map_df(.f = ~read_thickness_V1(.x))

# read in mean cortical thickness values for each subject, and normalize raw thickness
mean_thick <- read_csv('data/mean_hemi_thick.csv') %>%
  clean_names()

thickness <- thickness %>%
  left_join(mean_thick, by = c('subject','hemi')) %>%
  mutate(norm_thick = thick/avg_thick) %>%
  select(-avg_thick)

# write to an output csv
write_csv(thickness, file = 'data/vertexwise/thickness-full-V1.csv')

