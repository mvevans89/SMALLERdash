#this is the script for saving data we need to the repo
#must be run on Michelle's IRD computer until I hook it up to a github

library(sf)
library(ggplot2)

library(dplyr)

# Fokontany Outlines ####################

fkt.poly <- st_read("/home/evansm/Dropbox/PIVOT/projet-smaller/malaria-geostat-ifd/data/spatial-admin/ifd_fokontany.gpkg") %>%
  mutate(comm_fkt = paste(old_commune, fokontany, sep = "_")) %>%
  select(commune = old_commune, fokontany, comm_fkt)
#
# ggplot(fkt.poly) +
#   geom_sf(aes(fill = commune))

#save
saveRDS(fkt.poly, "data/ifd_fokontany_poly.rds")

# Commune Outlines #######################

comm.poly <- st_read("/home/evansm/Dropbox/PIVOT/projet-smaller/malaria-geostat-ifd/data/spatial-admin/ifd_commune.gpkg")

#save
saveRDS(comm.poly, "data/ifd_commune_poly.rds")

# Malaria Predictions #####################
#these are predictions from the full model

mal.preds <- read.csv("/home/evansm/Dropbox/PIVOT/projet-smaller/malaria-geostat-ifd/results/dashboard/full-preds.csv") %>%
  select(-sd, -mode, -mean) %>%
  mutate(date = as.Date(date))

#subset to prior 3 years of date of prediction
#ex if predicting 2021, only want 2017-2020
#for now we will predict jan - march 2021
this.date <- as.Date("2021-01-01")

mal.preds <- filter(mal.preds, date>=as.Date("2017-01-01"), date<=as.Date("2021-03-01"))

saveRDS(mal.preds, "data/raw/malaria-data.rds")

## Create Malaria Predictions with Popups for maps ##############################

fkt.poly <-  readRDS("data/ifd_fokontany_poly.rds") %>%
  st_transform(4326)

mal.preds <- readRDS("data/raw/malaria-data.rds")

# we want a value for each month x fokontany (even if NA)
full.grid <- expand.grid(comm_fkt = unique(fkt.poly$comm_fkt),
                         date = unique(mal.preds$date))

mal_map_popup <- mal.preds %>%
  right_join(full.grid,by = c("comm_fkt", "date")) %>%
  tidyr::separate(comm_fkt, into = c("commune", "fokontany"), remove = F, sep = "_") %>%
  #create pop-up (should also be done before the fact)
  mutate(popup = paste0("<b>Fokontany:</b> ", stringr::str_to_title(fokontany), "<br>",
                        "<b>Mois:</b> ", date, "<br>",
                        "<b>Taux Prédit (per 1000):</b> ", round(median), "<br>",
                        "<b>Éventail:</b> ", round(lowCI), " - ", round(uppCI))) %>%
  #fix NA popups
  mutate(popup = ifelse(is.na(popup),
                        paste0("<b>Fokontany:</b> ", stringr::str_to_title(fokontany), "<br>",
                               "<b>Mois:</b> ", date, "<br>",
                               "<b>Taux Prédit (per 1000):</b> Inconnu <br>",
                               "<b>Éventail:</b> Inconnu"), popup)) %>%
  right_join(fkt.poly) %>% st_as_sf()

#save
saveRDS(mal_map_popup, "data/for-app/inc_map_popup.rds")

## Create centroids for automatic zoom ##################

fkt.centroids <- readRDS("data/ifd_fokontany_poly.rds") %>%
  st_transform(crs = 4326)  %>%
  tidyr::separate(comm_fkt, into = c("commune", "fokontany"), remove = F, sep = "_") %>%
  st_centroid() %>%
  mutate(lat = as.numeric(st_coordinates(.)[,2]),
         lon = as.numeric(st_coordinates(.)[,1])) %>%
  st_drop_geometry()

#save
saveRDS(fkt.centroids, "data/for-app/fkt-cent.rds")


# HCUI ####################################
#' this is used to back-transform incidence to cases

hcui <- readRDS("/home/evansm/Dropbox/PIVOT/ifd-incidence-adj/results/adjusted/adjusted-ages.RData")
#save it all for now in case we need it
saveRDS(hcui, "data/raw/hcui-full.rds")


# Stockout Information ###################

stockout <- read.csv("/home/evansm/Dropbox/PIVOT/projet-smaller/malaria-geostat-ifd/data/clean/health-system/rdt_stockout_2017-2021.csv") %>%
  mutate(date = as.Date(paste(year, month, "01", sep = "-")))

#save
saveRDS(stockout, "data/raw/stockout.rds")

# Population Data #########################

pop <- read.csv("/home/evansm/Dropbox/PIVOT/ifd-incidence-adj/data/clean/for-model/population-age-year.csv")
#add in a population for 2022 so we can interpolate
pop.2022 <- pop %>%
  filter(year ==2021) %>%
  mutate(pop_2022 = round(pop*1.028)) %>%
  select(-pop, -year) %>%
  mutate(year = 2022) %>%
  rename(pop = pop_2022)
pop <- bind_rows(pop, pop.2022)

#interpolate for months for each age class
date.range <- expand.grid(year = 2016:2022,
                          month = 1:12,
                          comm_fkt = unique(pop$comm_fkt),
                          age_class = unique(pop$age_class)) %>%
  mutate(date = as.Date(paste(year, month, "01", sep = "-")))

pop.month <- pop %>%
  mutate(date = as.Date(paste(year, "01-01", sep = "-"))) %>%
  select(-year) %>%
  right_join(date.range, by = c("date", "comm_fkt", "age_class"), all.x = "TRUE") %>%
  #interpolate missing using linear interpolation
  group_by(comm_fkt, age_class) %>%
  arrange(date) %>%
  mutate(pop_month = zoo::na.approx(pop, na.rm = F)) %>%
  ungroup() %>%
  #drop 2022 for now
  filter(date<= as.Date("2021-12-01"))

#visually check
pop.month %>%
  filter(comm_fkt %in% sample(unique(pop.month$comm_fkt), 4)) %>%
  ggplot(aes(x = date, color = age_class)) +
  geom_point(aes(y = pop)) +
  geom_line(aes(y = pop_month)) +
  facet_wrap(~comm_fkt)

#save monthly population
pop.clean <- pop.month %>%
  select(-pop, -year, -month) %>%
  mutate(pop_month = as.integer(pop_month)) %>%
  arrange(comm_fkt, age_class, date)

saveRDS(pop.clean, "data/pop_fkt.rds")
