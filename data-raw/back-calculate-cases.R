#back-calculate cases for dashboard
#MV Evans Nov 2022

#' This script back-calculates cases from the incidence data
#' using the HCUI. Details exploring the method and how well it works
#' are in `vignettes/timeseries-apps/backcalculate-incience-cases.qmd`.
#'
#'

# Load Packages & Data #########################

options(stringsAsFactors = F, scipen = 999)

library(ggplot2); theme_set(theme_bw())
library(tidyr)
library(lubridate)
library(sf)

#should set wd to project directory
library(here)

library(dplyr)

#proportion consults at each CSB from all consultations
consult.catchment <- read.csv(here("data/consults_by_csb_2018-2019.csv"))
#population values
pop <- readRDS(here("data/pop_fkt.rds"))
#hcui, also info on imputation and stockout correction
hcui <- readRDS(here("data/raw/hcui-full.rds"))
#stockout data includes data on how many cases were at the CSB
stock <- readRDS(here("data/raw/stockout.rds"))

# True Historical Data ###################

#incidence to cases by fokontany
mal.case <- readRDS(here("data/raw/malaria-data.rds")) %>%
  select(comm_fkt, date, true_y) %>%
  left_join(filter(pop, age_class == "all")) %>%
  mutate(mal_case = true_y /1000 * pop_month)

#rscale by hcui
#this is using an approximated hcui for now because it is all ages
hcui.mean <- select(hcui, comm_fkt, date, age_class, scale_hcui, palu_rate_raw) %>%
  left_join(pop) %>%
  #calculate population weighted hcui and total cases
  mutate(mal_case = palu_rate_raw / 1000 * pop_month) %>%
  group_by(comm_fkt, date) %>%
  summarise(hcui = weighted.mean(scale_hcui, w = pop_month)) %>%
  ungroup()

case.seek <- select(mal.case, comm_fkt, date, mal_case, pop = pop_month) %>%
  left_join(hcui.mean) %>%
  mutate(mal_case_seek = mal_case*hcui)

# aggregate to CSB level
mal.csb.true <- case.seek %>%
  left_join(consult.catchment, by = "comm_fkt") %>%
  mutate(mal_case_csb = mal_case_seek * perc_consult) %>%
  group_by(CSB, date) %>%
  summarise(mal_case_csb = sum(mal_case_csb, na.rm = T)) %>%
  ungroup()

# Predictions #############################

#incidence to cases by fokontany
mal.case.preds <- readRDS(here("data/raw/malaria-data.rds")) %>%
  select(comm_fkt, date, lowCI, median, uppCI) %>%
  left_join(filter(pop, age_class == "all")) %>%
  mutate_at(.vars = c("lowCI", "median", "uppCI"),
            ~(.x / pop_month * 1000))

#rscale by hcui
#this is using an approximated hcui for now because it is all ages
hcui.mean <- select(hcui, comm_fkt, date, age_class, scale_hcui, palu_rate_raw) %>%
  left_join(pop) %>%
  group_by(comm_fkt, date) %>%
  summarise(hcui = weighted.mean(scale_hcui, w = pop_month)) %>%
  ungroup()

case.seek.preds <- mal.case.preds %>%
  left_join(hcui.mean) %>%
  mutate_at(.vars = c("lowCI", "median", "uppCI"),
            ~(.x * hcui))

# aggregate to CSB level
mal.csb.preds <- case.seek.preds %>%
  left_join(consult.catchment, by = "comm_fkt") %>%
  mutate_at(.vars = c("lowCI", "median", "uppCI"),
            ~(.x * perc_consult)) %>%
  group_by(CSB, date) %>%
  summarise_at(.vars = c("lowCI", "median", "uppCI"), sum) %>%
  ungroup()

# Save just in case ########################

saveRDS(mal.csb.true, "data/csb-cases/true-backcalculate.Rds")
saveRDS(mal.csb.preds, "data/csb-cases/preds-backcalculate.Rds")

# Create data for timeseries ###################
# big difference is that historical is true and future is predicted

#this manually sets the date of prediction
current.month <- as.Date("2020-12-01")
#order for plotting so last three months are predictions
month.label.order <- month.abb[((month(current.month)-9):(month(current.month)+2)) %% 12 +1]

plot.data.csb <- mal.csb.true %>%
  #first get historical in proper form
  filter(date<= current.month) %>%
  #create new columns to line up
  mutate(lowCI = mal_case_csb,
         uppCI = mal_case_csb,
         median = mal_case_csb) %>%
  bind_rows(filter(mal.csb.preds, date>current.month)) %>%
  #categorize into season and labels
  mutate(season = case_when(
    date > current.month %m-% months(9)  ~ "Present",
    date > current.month %m-% months(9+ 12) ~ " 2019/2020",
    date > current.month %m-% months(9+ (12*2)) ~ " 2018/2019",
    date > current.month %m-% months(9+ (12*3)) ~ " 2017/2018",
    TRUE ~ "drop")
  ) %>%
  filter(season != "drop") %>%
  mutate(month_lab = month.abb[month(date)]) %>%
  #change to ordered factor
  mutate(month_lab = factor(month_lab, levels = month.label.order)) %>%
  select(-mal_case_csb)

## Create district level ######################

plot.data.district <- plot.data.csb %>%
  select(-CSB) %>%
  group_by(season, date, month_lab) %>%
  summarise_all(sum)

## Save ###################################

saveRDS(plot.data.csb, "data/for-app/cases-csb.rds")
saveRDS(plot.data.district, "data/for-app/cases-district.rds")

# Spatial Case Data ############################

#csb locations
csb.pts <- readRDS(here("data/csb_points.rds")) %>%
  st_transform(4326)

csb.preds <- readRDS(here("data/csb-cases/preds-backcalculate.Rds")) %>%
  mutate(highlight_wt = FALSE) %>%
  #add spatial lat and lon
  left_join(csb.pts, by = c("CSB" = 'name')) %>%
  st_as_sf() %>%
  mutate(lat = st_coordinates(.)[,2],
         lon = st_coordinates(.)[,1]) %>%
  #drop geometry to save space
  st_drop_geometry() %>%
  #add popup
  mutate(popup = paste0("<b>CSB: </b> ", stringr::str_to_title(CSB), " ",
                        type, "<br>",
                        "<b>Mois: </b> ", date, "<br>",
                        "<b>Cas Prédit: </b> ", round(median), "<br>",
                        "<b>Éventail: </b> ", round(lowCI), " - ", round(uppCI))) %>%
  #fix NA for when data is missing
  mutate(popup = ifelse(is.na(popup),
                        paste0("<b>CSB: </b> ", stringr::str_to_title(CSB), " ",
                               type, "<br>",
                               "<b>Mois: </b> ", date, "<br>",
                               "<b>Cas Prédit: </b> Inconnu <br>",
                               "<b>Éventail: </b> Inconu"),
                        popup))

#coordinates for zooming
zoom.coords <- csb.pts %>%
  mutate(lat = as.numeric(st_coordinates(.)[,2]),
         lon = as.numeric(st_coordinates(.)[,1])) %>%
  st_drop_geometry() %>%
  select(CSB = name, lat, lon)

## Save #################

saveRDS(zoom.coords, "data/for-app/csb-cent.rds")
saveRDS(csb.preds, "data/for-app/cases-csb-sp.rds")
