
#apc <- read_csv("raw_data/APC-taxon-2021-06-08-0734.csv")
apc <- read_csv("data/taxon_list.csv", guess_max = 42451)

apcs <- 
  apc %>% 
  filter(
    taxon_rank %in% c("Species", "Forma", "Varietas", "Subspecies"),
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

sum(apcs$native_somewhere_index, na.rm = T)
dim(apcs)

apcs %>%
  mutate(aus_native = apcs$native_somewhere_index,
         aus_native = if_else(str_detect(taxon_distribution, "native"), TRUE, aus_native)) %>%
  select(taxon_name, aus_native) %>%
  distinct() %>% 
  write_csv("data/aus_native_lookup.csv")

