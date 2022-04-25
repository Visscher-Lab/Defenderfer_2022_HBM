# This function collates the CSV files for each individual vision ROI for each
# subject (PRL, URL, LPZ) into a single csv file. This also adds mean thickness
# for each subject and calculates normalized thickness for each vertex as well

# Load libraries
library(janitor)
library(tidyverse)

# read in the individual vision roi csv files and perform the same filtering as on the training data
csvpath <- "/data/user/mdefende/datasets/MDP-diff/noddi-csv-test"
df <- list.files(path = csvpath, pattern = "*.csv", full.names = TRUE) %>%
  map_dfr(read_csv) %>%
  select(-contains('16'))

# remove the vertex tag from LPZ, convert hemi designation to lowercase for
# matching, and rename the thickness column
df <- df %>%
  mutate(location = str_remove(location,'_100'),
         hemi = tolower(hemi)) %>%
  pivot_longer(starts_with('dir'), 
               names_pattern = "(dir9[89])_diff_11_(ficvf|odi)",
               names_to = c('direction','.value')) %>%
  group_by(subject,hemi,vertex) %>%
  summarize(ficvf = mean(ficvf),
            odi = mean(odi)) %>%
  ungroup()

# write to an output csv
write_csv(df, file = 'data/vertexwise/noddi-vision-rois.csv')

