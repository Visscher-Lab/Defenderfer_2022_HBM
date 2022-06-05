c.theme <- function(){
  theme_tufte() + 
    theme(text = element_text(family = 'sans', color = 'black'),
          plot.title = element_text(hjust = 0.5, size = 18),
          axis.text = element_text(size = 13, color = 'black'),
          axis.title = element_text(size = 16),
          legend.text = element_text(size = 12),
          legend.title = element_text(size = 14),
          axis.ticks.length = unit(0.25, "cm"),
          plot.background = element_rect(fill = 'white', colour = 'white'))
}