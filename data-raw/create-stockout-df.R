# estimate past stockout rates
#MV Evans Nov 2022

#' This creates the data needed for the stockout module.
#'

# Load Packages and Data ##############################

library(tidyr)
library(lubridate)
library(here)

library(dplyr)

stock <- readRDS(here("data/raw/stockout.rds"))

csb.preds <- readRDS(here("data/csb-cases/preds-backcalculate.Rds"))

# Set Date of Interest #############################

current.month <- as.Date("2020-12-01")
month.label.order <- month.abb[((month(current.month)-9):(month(current.month)+2)) %% 12 +1]

#month period is next three months
month.period <- (month(current.month)+1):(month(current.month)+3) %% 12
#date period
date.period <- current.month %m+% months(1:3)

## Historical stockouts and rates of treatment ############

stock.historical <- stock %>%
  filter(date < current.month) %>%
  filter(month %in% month.period) %>%
  group_by(csb, year) %>%
  summarise(sum_fever = sum(num_case_fever),
            sum_rdt_pos = sum(rdt_tests_pos),
            sum_act = sum(pos_treat_act)) %>%
  mutate(CSB = toupper(gsub("CSB2 ", "", csb))) %>%
  mutate(CSB = ifelse(CSB == "ATSINDRA", "ANTSINDRA", CSB)) %>%
  ungroup()

## Predicted Cases #################################
pred.cases <- csb.preds %>%
  filter(date %in% date.period) %>%
  mutate(year = year(date)) %>%
  select(-date) %>%
  #calcualte sum of cases for the period
  group_by(CSB, year) %>%
  summarise_all(sum) %>%
  #only keep CSBs in stockout data
  filter(CSB %in% stock.historical$CSB) %>%
  mutate(metric = "predicted") %>%
  rename(med = median)

## Combine into data to plot ###########################

#need a full grid to keep spacing equal
full.grid <- expand.grid(year = 2018:2020,
                         CSB = unique(stock.historical$CSB))

plot.data <- stock.historical %>%
  #also maybe drop 2017 to save space
  filter(year > 2017) %>%
  right_join(full.grid, by = c("CSB", 'year')) %>%
  mutate(rdt_non = sum_rdt_pos - sum_act) %>%
  select(-csb, -sum_fever, -sum_rdt_pos) %>%
  pivot_longer(cols = c("rdt_non", "sum_act"), names_to = "metric", values_to = "med") %>%
  #fill in zero for missing data
  mutate(med = ifelse(is.na(med), 0, med)) %>%
  mutate(lowCI = NA,
         uppCI = NA) %>%
  bind_rows(pred.cases) %>%
  mutate(fill_label = case_when(
    metric == "rdt_non" ~ "Cas Total",
    metric == "sum_act" ~ "Traité avec ACT",
    metric == "predicted" ~ "Cas Prédit"
  )) %>%
  #arrange this way so the treated column goes on the bottom
  arrange(desc(fill_label))

## Save ###################

saveRDS(plot.data, "data/for-app/stockout-plot-data.rds")
