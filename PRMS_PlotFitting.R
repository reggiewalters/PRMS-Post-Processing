# Plot Handling
library(tidyverse)
library(ggsci)
library(reshape2)

Q_HH <- tibble(Date = index(QMOD_ALL_PP), QHH = as.vector(QMOD_ALL$QHH), QHH_PP = as.vector(QMOD_ALL_PP$QHH))
Q_HH_melt <- melt(Q_HH, id.vars = 'Date', measure.vars = c('QHH', 'QHH_PP'))

ggplot(Q_HH_melt, aes(x = Date, y = value, color = variable)) + geom_line() + scale_color_d3()

# Plotting CPI
ggplot(CPIndex, aes(x = time, y = ci)) +
  geom_line() +
  labs(x = 'Date', 
       y = 'CPI',
       title = 'Current precipitation Index',
       subtitle = 'Over time') +
  theme_light()

TSSIndex <- tibble(Date = EP, TSS = TSS)
ggplot(TSSIndex, aes(x = Date, y = TSS)) +
  geom_line() +
  labs(x = 'Date', 
       y = 'tIndex',
       title = '15-Day Trailing Sum of Temperature Index') +
  theme_light()
