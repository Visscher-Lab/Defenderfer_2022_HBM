######################## Description and Setup #################################
# This script performs statistical analysis of normalized cortical thickness

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

# Normalized Thickness Across Location, Diagnosis, and Onset
norm_thick_vr_plot <- vr_comb %>%
  group_by(dx,onset,location) %>%
  summarize(m_group = mean(norm_thick), se_group = se(norm_thick), n = n()) %>%
  ggplot(aes(x = onset, 
             y = m_group, 
             color = dx)) +
  geom_point(size = 3, 
             position = position_dodge(width = 0.3)) +
  geom_point(data = vr_comb, 
             mapping = aes(y = norm_thick), 
             alpha = 0.5, 
             position = position_dodge(width = 0.3)) +
  geom_errorbar(aes(ymin = m_group-se_group, 
                    ymax = m_group+se_group), 
                width = 0.3, 
                position = position_dodge(width = 0.3)) +
  facet_wrap(~location) +
  labs(x = '', y = 'Normalized Thickness', title = 'Normalized Thickness in V1 Visual ROIs', color = 'Diagnosis') +
  scale_x_discrete(labels = c('Early\nOnset','Late\nOnset')) +
  c.theme() +
  theme(strip.text = element_text(size = 12))

ggsave('code/analysis/figures/figure_3.png', norm_thick_vr_plot)

# Three-way AN(C)OVA of Normalized Thickness Across Diagnosis, Location, and Onset at PRL and URL
vr_comb %>%
  filter(!str_detect(location, 'LPZ')) %>%
  mutate(location = fct_drop(location)) %>%
  anova_test(dv = norm_thick,
             wid = subject,
             within = location,
             between = c(dx,onset),
             #covariate = ecc, # can comment out this line for normal ANOVA
             type = 'III')

# Follow-up ANCOVA of Normalized Thickness Across Location and Onset at PRL and
# URL Only Within MD Groups Accounting for the Effect of Visual Acuity
vr_comb %>%
  filter(!str_detect(location, 'LPZ'), dx == 'MD')  %>%
  mutate(location = fct_drop(location)) %>%
  anova_test(dv = norm_thick,
             wid = subject,
             within = location,
             between = onset,
             covariate = c(age,acuity),
             type = 'III')

########################### Full V1 ROIs #######################################

# calculate average normalized thickness within each participant's rois first
f_comb_within_roi <- f_comb %>%
  group_by(subject,dx,onset,roi) %>% # groupiong by dx and onset keeps those in the data frame
  summarize(m_nt = mean(norm_thick)) %>%
  ungroup()

# calculate summary stats across subjects for plotting
f_comb_summ <- f_comb_within_roi %>%
  group_by(dx,onset,roi) %>%
  summarize(m_group = mean(m_nt), 
            se_group = se(m_nt)) %>%
  ungroup()

# Normalized Thickness Across V1 ROI, Diagnosis, and Onset
norm_thick_f_plot <- f_comb_summ %>%
  ggplot(aes(x = roi, 
             y = m_group, 
             color = interaction(dx,onset))) +
  geom_point(size = 3, 
             position = position_dodge(width = 0.3)) +
  geom_linerange(aes(ymin = m_group-se_group, 
                     ymax = m_group+se_group), 
                 position = position_dodge(width = 0.3)) +
  geom_line(aes(group = interaction(dx,onset)),position = position_dodge(0.3)) +
  labs(x = 'V1 ROI (° Eccentricity)', y = 'Normalized Thickness', title = 'V1 Normalized Thickness Across Visual Eccentricity', color = '') +
  scale_x_discrete(labels = c('0°','2.0°','4.3°','6.8°','9.3°','15.7°','26.7°','45.4°')) +
  scale_color_discrete(labels = c('Early HC','Early MD','Late HC','Late MD')) +
  c.theme() +
  theme(strip.text = element_text(size = 12))

ggsave('code/analysis/figures/figure_4.png', norm_thick_f_plot)

# Three-way ANOVA of Normalized Thickness Across Diagnosis, ROI, and Onset Across V1
f_comb_within_roi %>%
  anova_test(dv = m_nt,
             wid = subject,
             within = roi,
             between = c(dx,onset),
             type = 'III')
