library(tidyverse)

# Data from Honours project
resprouting_seeding <- readRDS("data/resprouting_seeding.rds")

mean_fires <- read_csv("outputs/mean_fires_df_with_poisson_glm.csv", guess_max = 10000) |>
  left_join(resprouting_seeding, by = c("taxon_name")) |>
  filter(is.na(warnings), is.na(error), is.na(messages)) |>
  select(-warnings, -messages, -error) |>
  filter(num_pixels >= 10) |> # Eliminate species with less than 10 pixels
  # Convert to mean number of fires in 100 years, instead of mean number of fires in the sampling period
  mutate(
    mean_fires_per_century = mean_fires / 22.17 * 100,
    genus = word(taxon_name, 1)
  ) |>
  mutate(across(c("resprouting_binomial", "seeding_binomial", "woody_or_herb"), as.factor)) |>
  select(c(
    "taxon_name", "genus", "num_unburnt_pixels", "num_pixels", "taxon_rank",
    "mean_fires_per_century", "resprouting", "post_fire_seeding", "data_on_both",
    "woody_or_herb", "resprouting_binomial", "seeding_binomial"
  ))

# Genera of interest
genera_of_interest <- c(
  "Triodia", "Sorghum", "Cryptandra", "Blackallia", "Papistylus", "Polianthion",
  "Pomaderris", "Serichonus", "Siegfriedia", "Spyridium", "Stenanthemum", "Trymalium"
)

# Find data for Cryptandra, other genera in Pomaderreae, Triodia, Sorghum
data_of_interest <- mean_fires |>
  filter(genus %in% genera_of_interest)

# Clean data to give to Lamont
data_of_interest |> write_csv("mean_fires_for_lamont.csv")

# Plot mean fires for each genus
ggplot(data_of_interest, aes(x = mean_fires_per_century)) +
  geom_histogram() +
  facet_wrap(~genus) +
  labs(
    x = "Mean fires per century",
    y = "Count"
  ) +
  theme_light() +
  theme(
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 14),
    strip.text = element_text(size = 16, face = "bold")
  )

ggsave("histograms_for_lamont.png", width = 10, height = 10)
