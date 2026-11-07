# Descriptive distributions for the frozen quarterly panel; no models are fitted.
# Complete exposure is a locality selection rule, not evidence of zero deployment
# in the ten excluded candidate areas. Retain their coverage in the summary CSV.
.libPaths(c('.local_library', .libPaths()))
library(dplyr)
library(tidyr)
library(ggplot2)
all_panel <- readRDS('outputs/quarterly_pilot/panel/quarterly_panel_all_localities.rds')
panel <- readRDS('outputs/quarterly_pilot/panel/quarterly_panel_complete_exposure.rds')
stopifnot(nrow(all_panel) == 608L, n_distinct(all_panel$locality_id) == 19L,
  nrow(panel) == 288L, n_distinct(panel$locality_id) == 9L,
  !anyDuplicated(panel[c('locality_id', 'time_index')]), all(panel$core_sample))
summary <- all_panel |> arrange(locality_id, time_index) |>
  group_by(locality_id, locality) |> summarise(candidate_quarters = n(),
    retained_quarters = sum(core_sample),
    known_lagged_strength_quarters = sum(!is.na(strength_lag)),
    outcome_total = sum(recorded_events), zero_event_quarters = sum(recorded_events == 0),
    median_events = median(recorded_events), max_events = max(recorded_events),
    .groups = 'drop')
# Summarize strength only for the retained analysis sample. Missing or partial
# exposure among excluded localities is not filled with zero or summarized as absence.
strength_summary <- panel |> arrange(locality_id, time_index) |>
  group_by(locality_id) |> summarise(strength_min = min(strength_lag),
    strength_median = median(strength_lag), strength_max = max(strength_lag),
    strength_sd = sd(strength_lag),
    consecutive_quarter_strength_changes = sum(abs(diff(strength_lag)) > 1e-10), .groups='drop')
summary <- left_join(summary, strength_summary, by='locality_id') |> arrange(locality)
dir.create('portfolio/figures', recursive=TRUE, showWarnings=FALSE)
write.csv(summary, 'portfolio/figures/descriptive_panel_summary.csv', row.names=FALSE)

# Histograms would conceal locality differences. Boxplots show the median and
# interquartile range, whiskers to 1.5 IQR and all more extreme quarter values.
# No jittered locality-quarter records are published in the aggregate CSV.
plot_data <- panel |> select(locality, recorded_events, strength_lag) |>
  pivot_longer(c(recorded_events, strength_lag), names_to='measure', values_to='value') |>
  mutate(locality = factor(paste0(locality, ' (32)'),
    levels=rev(paste0(sort(unique(panel$locality)), ' (32)'))),
    measure=factor(measure, levels=c('recorded_events','strength_lag'),
      labels=c('Recorded events per quarter', 'Prior-quarter strength (1,000)')))
p <- ggplot(plot_data, aes(value, locality)) +
  geom_boxplot(fill='#326681', alpha=.45, colour='#244A5D', outlier.size=1.3,
    orientation='y', width=.55) +
  facet_grid(. ~ measure, scales='free_x') +
  labs(title='Outcome dispersion and deployment variation in the retained panel',
    subtitle='Nine of 19 candidate localities; 2016-2023; usable quarters in parentheses',
    x=NULL, y=NULL,
    caption=paste0('Boxes: median and middle 50%; whiskers: 1.5 IQR; dots: more extreme quarters.\n',
      'Strength is prior-quarter mean listed military personnel / 1,000, excluding FPU.\n',
      'Repeated carried-forward source maps contribute to stocks; changes are not independent map observations.')) +
  theme_minimal(base_size=10, base_family='sans') +
  theme(panel.grid.minor=element_blank(), strip.text=element_text(face='bold'),
    plot.title=element_text(face='bold'), plot.caption=element_text(hjust=0, size=8.5),
    plot.title.position='plot', plot.caption.position='plot',
    panel.spacing.x=grid::unit(.5,'cm'), plot.margin=margin(8,10,8,8))
ggsave('portfolio/figures/descriptive_panel_distributions.png', p, width=8, height=5.6,
  dpi=300, bg='white', device=grDevices::png, type='cairo-png')
ggsave('portfolio/figures/descriptive_panel_distributions.pdf', p, width=8, height=5.6,
  bg='white', device=grDevices::cairo_pdf)
print(summary)
cat('Retained zero-event quarters:',sum(panel$recorded_events==0),'of',nrow(panel),'\n')
cat('Retained events:',sum(panel$recorded_events),'; range:',range(panel$recorded_events),'\n')
# This supplement has a separate manifest so the previously versioned core
# portfolio and optional human-review packet keep their original scope.
paths <- paste0('portfolio/figures/descriptive_panel_',
  c('distributions.png','distributions.pdf'))
manifest <- data.frame(file=paths, sha256=vapply(paths,function(path)
  digest::digest(readBin(path,'raw',file.info(path)$size),algo='sha256',serialize=FALSE),character(1)))
write.csv(manifest,'portfolio/figures/descriptive_panel_manifest.csv',row.names=FALSE)
