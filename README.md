# Fire response strategies and fire frequency in Australia

This repository contains code and data used for the article in review:

Continental-scale empirical evidence for relationships between fire response strategies and fire frequency
Sophie Yang, Mark K. J. Ooi, Daniel S. Falster, Will K. Cornwell

Preprint is available here: https://doi.org/10.32942/X29K89

Note that some data are too large to be uploaded to GitHub. Please contact me for more details on obtaining this data.

**License:** CC BY 4.0
You can share, copy and modify this dataset so long as you give appropriate credit, provide a link to the CC BY license, and indicate if changes were made, but you may not do so in a way that suggests the rights holder has endorsed you or your use of the dataset. Note that further permission may be required for any content within the dataset that is identified as belonging to a third party.


## Folder: `scripts`

`fire_response_data.Rmd`
- Explore and plot fire response data from AusTraits database

`fire_response_strategies_and_fire_frequency.Rmd`
- Explore relationships between fire response strategies and fire frequency

`fire_response_strategies_and_leaf_traits.Rmd`
- Explore relationships between fire response strategies and leaf traits

`gbif_process.R`
- Clean GBIF data

`make_aus_native_species_list.r`
- Create native species list with Australian Plant Census data and {APCalign}

`mean_fires_poisson_method_for_linux.R`
- Calculate mean fire frequency per species with GLM and Poisson distribution using parallelisation (compatible with Linux)

`mean_fires_poisson_method_for_windows.Rmd`
- Calculate mean fire frequency per species with GLM and Poisson distribution (parallelisation does not seem to be working)

`median_fri_survival_analysis_method.R`
- Calculate median FRI per species with survival analysis, adapted from Simpson et al. (2021)

`methods_figure.Rmd`
- Plotting Fig. 1 (schematic illustrating how the mean fire frequency (per century) for a species is calculated, for three example species with contrasting distributions)

`phylogeny_figure.Rmd`
- Plotting Fig. 2 (frequency distribution of mean fire frequencies in Australia and fire and leaf traits of Australian families)


## References:

Simpson KJ, Jardine EC, Archibald S, Forrestel EJ, Lehmann CER, Thomas GH, Osborne CP. 2021. Resprouting grasses are associated with less frequent fire than seeders. New Phytologist 230: 832–844.
