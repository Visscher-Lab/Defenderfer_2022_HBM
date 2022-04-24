library(tidyverse)

area <- 'V1'

camcan <- paste0("/data/user/mdefende/datasets/CamCAN/SurfaceCSV/",area) %>%
  list.files(pattern = "*.csv", full.names = TRUE) %>%
  map_dfr(read_csv, col_types = cols(Subject = 'c', Gender = 'c', Hemi = 'c', .default = 'd')) %>%
  filter_at(vars(contains("Thick")), all_vars(between(.,0.3,5))) %>%  # Thickness bound is 0.3-5
  filter_at(vars(contains("Curv")), all_vars(between(.,-3,3))) %>% # Curv bound from -3,3
  filter_at(vars(contains("Area")), all_vars(between(.,0.01,3))) %>%
  filter(!is.na(LGI0)) %>%
  filter_at(vars(contains("LGI")), all_vars(between(.,0,5.5))) %>%
  mutate(Gender = ifelse(Gender == 'MALE','M','F'))

hcpa <- paste0("/data/user/mdefende/datasets/HCPA/SurfaceCSV/",area) %>%
  list.files(pattern = "*.csv", full.names = TRUE) %>%
  map_dfr(read_csv, col_types = cols(Subject = 'c', Gender = 'c', Hemi = 'c', .default = 'd')) %>%
  filter_at(vars(contains("Thick")), all_vars(between(.,0.3,5))) %>%  # Thickness bound is 0.3-5
  filter_at(vars(contains("Curv")), all_vars(between(.,-3,3))) %>% # Curv bound from -3,3
  filter_at(vars(contains("Area")), all_vars(between(.,0.01,3))) %>%
  filter(!is.na(LGI0)) %>%
  filter_at(vars(contains("LGI")), all_vars(between(.,0,5.5)))

camcan %<>%
  mutate(Gender = ifelse(Gender == 'MALE','M','F'))

hcpa %>%
  select(-contains('10')) %>%
  bind_rows(camcan) %>%
  write_csv(path = '/data/user/mdefende/Projects/prl-thickness/data/V1-train.csv')
