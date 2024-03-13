
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

taxonomic_resources <- load_taxonomic_resources()

# https://github.com/traitecoevo/APCalign/blob/multicore/R/multicore.R
split_vector <- function(v, N = parallel::detectCores() - 1) {
  # Check for edge cases
  if (N <= 0)
    stop("N should be greater than 0")
  if (length(v) == 0)
    return(vector("list", N))

  # Calculate chunk size
  chunk_size <- floor(length(v) / N)

  # Compute number of chunks that get an extra element
  extras <- length(v) %% N

  chunks <- vector("list", N)
  start_idx <- 1

  for (i in 1:N) {
    end_idx <- start_idx + chunk_size - 1
    # Assign extra elements to the first few chunks
    if (i <= extras) {
      end_idx <- end_idx + 1
    }
    chunks[[i]] <- v[start_idx:end_idx]
    start_idx <- end_idx + 1
  }

  return(chunks)
}

multicore_tax_update <-
  function(
    data_vec,
    cores = parallel::detectCores() - 1,
    resources = taxonomic_resources,
    taxonomic_splits = "most_likely_species"
  ) {

    # Split the vector into a list of individual elements
    data_list <- split_vector(data_vec, N = cores)

    results <-
      parallel::mclapply(
        data_list,
        function(x) create_taxonomic_update_lookup(x, resources = resources, taxonomic_splits = taxonomic_splits),
        mc.cores = cores
      )

    # Bind all results together into a single dataframe
    result_df <- do.call(rbind, results)

    return(result_df)

  }

lookup_table <- multicore_tax_update(tt$tip.label[120001:356305])

# Save
write_csv(lookup_table, "outputs/lookup_table_GBIF_356305.csv")
