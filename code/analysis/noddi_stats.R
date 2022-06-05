######################## Description and Setup #################################
# This script performs statistical analysis of neurite orientation and dispersion 

# Load Libraries
library(sciplot)
library(rstatix)
library(ggthemes)
library(tidyverse)

# load preconfigured custom plot theme
source('code/analysis/paper_plot_theme.R')
load('data/vision_rois_struct_master.RData')
load('data/full_V1_struct_master.RData')

############################ Visual ROIs #######################################

vr_plot <- function(data, v){
  data %>%
    group_by(dx,onset,location) %>%
    summarize(m_group = mean({{ v }}), se_group = se({{ v }}), n = n()) %>%
    ggplot(aes(x = onset, 
               y = m_group, 
               color = dx)) +
    geom_point(size = 3, 
               position = position_dodge(width = 0.3)) +
    geom_point(data = data, 
               mapping = aes(y = {{ v }}), 
               alpha = 0.5, 
               position = position_dodge(width = 0.3)) +
    geom_errorbar(aes(ymin = m_group-se_group, 
                      ymax = m_group+se_group), 
                  width = 0.3, 
                  position = position_dodge(width = 0.3)) +
    facet_wrap(~location)
}

### FICVF VR

# FICVF Across Location, Diagnosis, and Onset
ficvf_vr_plot <- vr_comb %>%
  vr_plot(ficvf) +
  labs(x = '', y = 'Neurite Density', title = 'Neurite Density in V1 Visual ROIs', color = 'Diagnosis') +
  scale_x_discrete(labels = c('Early\nOnset','Late\nOnset')) +
  c.theme() +
  theme(strip.text = element_text(size = 12))

ggsave('code/analysis/figures/figure_5.png', ficvf_vr_plot)

# Three-way AN(C)OVA of FICVF Across Diagnosis, Location, and Onset at PRL and URL
vr_comb %>%
  filter(!str_detect(location, 'LPZ')) %>%
  mutate(location = fct_drop(location)) %>%
  anova_test(dv = ficvf,
             wid = subject,
             within = location,
             between = c(dx,onset),
             #covariate = ecc, # can comment out this line for normal ANOVA
             type = 'III')

# Two-way ANOVA of FICVF Across Diagnosis and Location at the LPZ
vr_comb %>%
  filter(location == 'LPZ') %>%
  mutate(location = fct_drop(location)) %>%
  anova_test(dv = ficvf,
             wid = subject,
             between = c(dx,onset),
             type = 'III')


### ODI VR

# ODI Across Location, Diagnosis, and Onset
odi_vr_plot <- vr_comb %>%
  vr_plot(odi) +
  labs(x = '', y = 'ODI', title = 'Orientation Dispersion Index in V1 Visual ROIs', color = 'Diagnosis') +
  scale_x_discrete(labels = c('Early\nOnset','Late\nOnset')) +
  c.theme() +
  theme(strip.text = element_text(size = 12))

ggsave('code/analysis/figures/figure_7.png', odi_vr_plot)

# Three-way AN(C)OVA of ODI Across Diagnosis, Location, and Onset at PRL and URL
vr_comb %>%
  filter(!str_detect(location, 'LPZ')) %>%
  mutate(location = fct_drop(location)) %>%
  anova_test(dv = odi,
             wid = subject,
             within = location,
             between = c(dx,onset),
             covariate = ecc, # can comment out this line for normal ANOVA
             type = 'III')

# Two-way ANOVA of FICVF Across Diagnosis and Location at the LPZ
vr_comb %>%
  filter(location == 'LPZ') %>%
  mutate(location = fct_drop(location)) %>%
  anova_test(dv = odi,
             wid = subject,
             between = c(dx,onset),
             type = 'III')

########################### Full V1 ROIs #######################################

### FICVF V1

# calculate average noddi values within each participant's rois first
f_comb_within_roi <- f_comb %>%
  group_by(subject,dx,onset,roi) %>% # grouping by dx and onset keeps those in the data frame
  summarize(across(c(ficvf,odi),.fns = mean)) %>%
  ungroup()

f_plot <- function(data, v){
  data %>%
    group_by(dx,onset,roi) %>%
    summarize(m_group = mean({{ v }}), 
              se_group = se({{ v }})) %>%
    ungroup() %>%
    ggplot(aes(x = roi, 
               y = m_group, 
               color = interaction(dx,onset))) +
    geom_point(size = 3, 
               position = position_dodge(width = 0.3)) +
    geom_linerange(aes(ymin = m_group-se_group, 
                       ymax = m_group+se_group), 
                   position = position_dodge(width = 0.3)) +
    geom_line(aes(group = interaction(dx,onset)),position = position_dodge(0.3)) +
    scale_x_discrete(labels = c('0°','2.0°','4.3°','6.8°','9.3°','15.7°','26.7°','45.4°')) +
    scale_color_discrete(labels = c('Early HC','Early MD','Late HC','Late MD'))
}

# FICVF Across V1 ROI, Diagnosis, and Onset
ficvf_f_plot <- f_comb_within_roi %>%
  f_plot(ficvf) +
  labs(x = 'V1 ROI (° Eccentricity)', 
       y = 'Intracellular Volume Fraction', 
       title = 'Neurite Density Across Visual Eccentricity', 
       color = '') +
  c.theme() +
  theme(strip.text = element_text(size = 12))

ggsave('code/analysis/figures/figure_6.png', norm_thick_f_plot)

# Three-way ANOVA of FICVF Across Diagnosis, ROI, and Onset Across V1
f_comb_within_roi %>%
  anova_test(dv = ficvf,
             wid = subject,
             within = roi,
             between = c(dx,onset),
             type = 'III')

### ODI V1

# ODI Across V1 ROI, Diagnosis, and Onset
odi_f_plot <- f_comb_within_roi %>%
  f_plot(odi) +
  labs(x = 'V1 ROI (° Eccentricity)', 
       y = 'Orientation Dispersion Index', 
       title = 'Orientation Dispersion Across Visual Eccentricity', 
       color = '') +
  c.theme() +
  theme(strip.text = element_text(size = 12))

ggsave('code/analysis/figures/figure_8.png', odi_f_plot)

# Three-way ANOVA of FICVF Across Diagnosis, ROI, and Onset Across V1
f_comb_within_roi %>%
  anova_test(dv = odi,
             wid = subject,
             within = roi,
             between = c(dx,onset),
             type = 'III')
