# This script takes the fsaverage space noddi surfaces for each participant,
# extracts LH and RH V1 according to the Benson retinotopic atlas, and collates
# ficvf and odi measures together. It also filters out diffusivity values,
# keeping 1.1e-9, and averages ficvf and odi values across dir98 and dir99
# scans. The output is written to a csv file

library(freesurferformats)
library(tidyverse)

read_noddi_V1 <- function(filename){
  hemi <- str_extract(filename, '[lr]h')
  subj <- str_extract(filename, 'sub-MDP[0-9]{3}')
  dir <- str_extract(filename, 'dir9[89]')
  diffusivity <- str_extract(filename, '1.[16]e-9')
  measure <- str_extract(filename,'ficvf|odi')
  
  V1_label <- read.fs.label(paste0('data/fsavg_labels/',hemi,'.V1_eccen.label'), return_one_based_indices = FALSE, full = TRUE)
  V1_label <- V1_label$vertexdata
  
  surf <- read.fs.mgh(filename)
  surf <- surf[V1_label$vertex_index+1]
  
  df <- data.frame(subject = subj,
                   hemi = hemi,
                   dir = dir,
                   diffusivity = diffusivity,
                   measure = measure,
                   vertex = V1_label$vertex_index,
                   ecc = V1_label$value,
                   value = surf
                   )
  
  
}

noddi <- list.files('/data/user/mdefende/datasets/MDP/subs/fsaverage/surf/MKD_surfs/noddi',pattern = '*.mgz', full.names = TRUE) %>%
  map_df(.f = ~read_noddi_V1(.x)) %>%
  pivot_wider(names_from = measure, values_from = value) %>%
  filter(diffusivity == '1.1e-9') %>%
  select(-diffusivity)  %>%
  group_by(subject,hemi,vertex) %>%
  summarize(vertex = unique(vertex),
            ecc = unique(ecc),
            ficvf = mean(ficvf),
            odi = mean(odi)) %>%
  ungroup()

write_csv(x = noddi, file = 'data/vertexwise/noddi-full-V1.csv')
