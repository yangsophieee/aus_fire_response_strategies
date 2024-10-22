
library(data.table)
library(tidyverse)
library(CoordinateCleaner)
library(arrow)

aus_gbif <- fread("data/gbif/0004407-230530130749713.csv", quote = "")

# Modified from: https://data-blog.gbif.org/post/gbif-filtering-guide/
intermediate_check <- aus_gbif |>
  # Already filtered the below on GBIF website
  filter(countryCode  == "AU") |>
  filter(occurrenceStatus  == "PRESENT")  |>
  filter(basisOfRecord %in% c("HUMAN_OBSERVATION", "LIVING_SPECIMEN", "PRESERVED_SPECIMEN")) |>
  filter(!is.na(decimalLongitude)) |>
  filter(!is.na(decimalLatitude)) |>
  filter(establishmentMeans %in% c("INTRODUCED", "INVASIVE", "NATURALISED", "")) |> # Exclude "MANAGED" or "Uncertain"
  filter(coordinatePrecision < 0.05 | is.na(coordinatePrecision)) |>
  filter(year >= 1900) |>
  filter(coordinateUncertaintyInMeters < 10000 | is.na(coordinateUncertaintyInMeters)) |>
  filter(!decimalLatitude == 0 | !decimalLongitude == 0) |>
  filter(
    !grepl("COUNTRY_COORDINATE_MISMATCH", issue) &
      !grepl("RECORDED_DATE_UNLIKELY", issue)
  )

aus_filt <- intermediate_check |>
  # cc_sea(ref = buffland) |> # Not working
  cc_val() |>
  cc_equ() |>
  cc_gbif() |>
  cc_cen(buffer = 2000) |> # Remove country centroid within 2 km
  cc_cap(buffer = 2000) |> # Remove capital centroid within 2 km
  cc_inst(buffer = 2000) |> # Remove zoo and herbaria within 2 km
  distinct(decimalLongitude, decimalLatitude, species, .keep_all = TRUE)

aus_filt |> write_parquet("data/filtered_aus_obs.parquet") # Cannot upload to GitHub repo due to size
