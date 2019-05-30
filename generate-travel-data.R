library(data.table)
library(ggplot2)

## create sample of travel behavior survey data that mimics transit travel purpose, by time of day and mode ####
# grids of survey responses are weighted to be sort of realistic, but need not be

purpose_grid <- data.table(purpose = c('home', 'work', 'school', 'shopping', 'airport', 'social/recreational'),
                         weights = c(0.5, 0.27, 0.12, .05, .01, .05))

hr_grid <- data.table(hr = as.ITime(4:22*60*60), # ITime is in seconds past midnight, here 4am to 10pm
                      weights = c(0.01, 0.01, 0.01, 0.05, 0.07, 0.07, 0.05, 0.05, 0.07,
                                      0.05, 0.05, 0.07, 0.15, 0.13, 0.07, 0.05, 0.02, 0.01, 0.01))

mode_grid <- data.table(transit_mode = c('local bus', 'express bus', 'light rail'),
                        weights = c(0.67, 0.1, 0.23))

## random draws are taken of each variable independently, and comined into one dataset ####
# use set.seed function if you wish to have the same results as example dataset
set.seed(22)
survey_sim <- data.table(trip_purpose = factor(sample(purpose_grid$purpose, 1000, replace = T, prob = purpose_grid$weights),
                                               levels = c('home', 'work', 'school', 'shopping',
                                                            'airport', 'social/recreational'), ordered = T),
                                                  hr_surveyed = sample(hr_grid$hr, 1000, replace = T, prob = hr_grid$weights),
                         mode_surveyed = factor(sample(mode_grid$transit_mode, 1000, replace = T, prob = mode_grid$weights),
                                                levels = c('local bus', 'express bus', 'light rail'), ordered = T))