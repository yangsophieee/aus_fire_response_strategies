library(APCalign)
resources <- load_taxonomic_resources()
apc <- resources$APC

apcs <-
  apc %>%
  filter(
    taxon_rank %in% c("species", "form", "variety", "subspecies"),
    taxonomic_status == "accepted"
  )

apcs$nat_count <- str_count(apcs$taxon_distribution, "naturalised")
apcs$comma_count <- str_count(apcs$taxon_distribution, ",")
plot(apcs$nat_count, apcs$comma_count)

apcs$native_somewhere_index <- apcs$nat_count <= apcs$comma_count

x <- which(apcs$nat_count <= apcs$comma_count)
apcs$taxon_distribution[x][1]
apcs$nat_count[x][1]
apcs$comma_count[x][1]

sum(apcs$native_somewhere_index, na.rm = TRUE)
dim(apcs)

apcs %>%
  mutate(
    aus_native = apcs$native_somewhere_index,
    aus_native = if_else(str_detect(taxon_distribution, "native"), TRUE, aus_native)) %>%
  select(canonical_name, aus_native) %>%
  distinct() %>%
  write_csv("data/aus_native_lookup.csv")
