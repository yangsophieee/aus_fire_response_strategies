# Using UNSW HPC Katana
# This research includes computations using the computational cluster Katana supported by
# Research Technology Services at UNSW Sydney.

library(dplyr)
library(readr)
library(forcats)
library(stringr)
library(ggplot2)
library(tibble)
library(lubridate)
library(tidyr)
library(purrr)

num_of_fires <- terra::rast("data/num_fires_map.tif")
joined_fire_data <- readRDS("data/joined_fire_data.rds")

safely_n_quietly <- function(.f, otherwise = NULL) {
  retfun <- quietly(safely(.f, otherwise = otherwise, quiet = FALSE))
  function(...) {
    ret <- retfun(...)
    list(
      result = ret$result$result,
      output = ret$output,
      messages = ret$messages,
      warnings = ret$warnings,
      error = ret$result$error
    )
  }
}

calculate_mean_fires_with_glm <- function(
    taxon,
    gbif_data = joined_fire_data,
    num_of_fires_raster = num_of_fires,
    sampling_period = 22.17) {
  # Subset data to taxon
  species_subset <-
    gbif_data %>%
    filter(taxon_name == taxon) %>%
    select(decimalLongitude, decimalLatitude)

  # Round species_subset to resolution of 0.005 decimal degrees so that any coordinates
  # that are approximately within the same MODIS pixel can be removed
  multiple <- 0.005
  species_subset <- species_subset %>%
    mutate(
      decimalLongitude = multiple * round(decimalLongitude / multiple),
      decimalLatitude = multiple * round(decimalLatitude / multiple)
    ) %>%
    distinct(.keep_all = TRUE) # Remove duplicates

  # Convert to an sf object
  sf <- species_subset %>% sf::st_as_sf(coords = c("decimalLongitude", "decimalLatitude"))

  # Extract intersecting pixels
  intersecting_pixels <-
    num_of_fires_raster %>%
    terra::extract(sf, bind = TRUE)

  # Convert to data frame
  df <-
    intersecting_pixels %>%
    terra::as.data.frame() %>%
    filter(!is.na(.data$num_of_fires)) # Filter out NAs

  # Run GLM model
  safe_quiet_glm <- safely_n_quietly(glm)
  model <- safe_quiet_glm(num_of_fires ~ 1, data = df, family = poisson(link = "identity"))

  if (length(model$error) < 1) {
    # Get summary
    summary <- summary(model$result)

    # Calculate predicted fire return interval
    predicted_fri <- sampling_period / predict(model$result, type = "link")[[1]]

    # Calculate mean number of fires in 20 years
    mean_fires_in_sampling_period <- model$result$coefficients[[1]]

    # Lower confidence interval bound
    lwr <- predict(model$result, type = "link")[[1]] - summary$coefficients[[2]] * 1.96

    # Upper confidence interval bound
    upr <- predict(model$result, type = "link")[[1]] + summary$coefficients[[2]] * 1.96

    # Dispersion test
    dispersion_test <- performance::check_overdispersion(model$result)

    # Return outputs
    output_df <- data.frame(
      taxon_name = taxon,
      mean_fri = predicted_fri,
      mean_fires = mean_fires_in_sampling_period,
      lwr_conf_int = lwr,
      upr_conf_int = upr,
      dispersion_ratio = dispersion_test$dispersion_ratio,
      dispersion_p_value = dispersion_test$p_value,
      num_unburnt_pixels = df %>% filter(.data$num_of_fires == 0) %>% nrow(),
      num_pixels = nrow(df),
      warnings = ifelse(
        length(model$warnings) >= 1,
        paste(model$warnings, collapse = ", "), NA
      ),
      messages = ifelse(
        length(model$messages) >= 1,
        paste(model$messages, collapse = ", "), NA
      ),
      error = NA
    )
  } else {
    # Return outputs
    output_df <- data.frame(
      taxon_name = taxon,
      mean_fri = NA,
      mean_fires = NA,
      lwr_confint = NA,
      upr_confint = NA,
      dispersion_ratio = NA,
      dispersion_p_value = NA,
      num_unburnt_pixels = df %>% filter(.data$num_of_fires == 0) %>% nrow(),
      num_pixels = nrow(df),
      warnings = ifelse(
        length(model$warnings) >= 1,
        paste(model$warnings, collapse = ", "), NA
      ),
      messages = ifelse(
        length(model$messages) >= 1,
        paste(model$messages, collapse = ", "), NA
      ),
      error = paste(model$error, collapse = ", ")
    )
  }

  return(output_df)
}

list_of_taxa <- joined_fire_data$taxon_name %>% unique()

num_cores <- parallel::detectCores()

mean_fires_list <- parallel::mclapply(list_of_taxa, calculate_mean_fires_with_glm, mc.cores = num_cores)

mean_fires_df <- mean_fires_list %>% bind_rows()

write_csv(mean_fires_df, "outputs/mean_fires_df_with_poisson_glm.csv")
