
library(data.table)
library(curl)
library(zip)
library(tidyverse)
library(CoordinateCleaner)


aus_gbif <- fread("data/gbif/0004407-230530130749713.csv", quote = "")

# Modified from: https://data-blog.gbif.org/post/gbif-filtering-guide/
intermediate_check <- data.frame(aus_gbif) %>%
  setNames(tolower(names(.))) %>% # Set lowercase column names to work with CoordinateCleaner
  filter(!is.na(decimallongitude)) %>%
  filter(!is.na(decimallatitude)) %>%
  filter(basisofrecord %in% c("HUMAN_OBSERVATION", "PRESERVED_SPECIMEN")) %>%
  filter(year >= 1900) %>%
  filter(coordinateprecision < 0.05 | is.na(coordinateprecision)) %>%
  filter(coordinateuncertaintyinmeters < 10000 | is.na(coordinateuncertaintyinmeters)) %>%
  filter(!coordinateuncertaintyinmeters %in% c(301, 3036, 999, 9999)) %>% # Known inaccurate default values
  filter(!decimallatitude == 0 | !decimallongitude == 0)

# Adding some additional filters
i2 <- intermediate_check %>%
  filter(
    !grepl("COUNTRY_COORDINATE_MISMATCH", intermediate_check$issue),
    !grepl("RECORDED_DATE_UNLIKELY", intermediate_check$issue)
    )

aus_filt <- i2 %>%
  cc_sea(ref = buffland) %>%
  cc_val() %>%
  cc_equ() %>%
  cc_gbif() %>%
  cc_cen(buffer = 2000) %>% # Remove country centroid within 2 km
  cc_cap(buffer = 2000) %>% # Remove capital centroid within 2 km
  cc_inst(buffer = 2000) %>% # Remove zoo and herbaria within 2 km
  distinct(decimallongitude, decimallatitude, specieskey, datasetkey, .keep_all = TRUE)

aus_filt %>%
  select(
    species,
    decimalLongitude = decimallongitude,
    decimalLatitude = decimallatitude,
    scientificname,
    verbatimscientificname
  ) %>%
  write_csv("data/filtered_aus_obs.csv")
