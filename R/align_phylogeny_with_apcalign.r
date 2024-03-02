
# Load libraries
library(dplyr)
library(readr)
library(forcats)
library(stringr)
library(ggplot2)
library(tibble)
library(lubridate)
library(tidyr)
library(purrr)
library(APCalign)
library(ape)

# Align names in tree with APCalign
tt <- read.tree("data/v0.1-big-seed-plant-trees/ALLMB.tre")
tt$tip.label <- gsub("_", " ", tt$tip.label)

resources <- load_taxonomic_resources()

lookup_table <- create_taxonomic_update_lookup(
  taxa = tt$tip.label,
  resources = resources
)

out <- drop.tip(tt, tt$tip.label[is.na(lookup_table$accepted_name)])

# Save
write_csv(lookup_table, "lookup_table_GBIF.csv")
write.tree(out, "ALLMB_APC_updated.tre")
