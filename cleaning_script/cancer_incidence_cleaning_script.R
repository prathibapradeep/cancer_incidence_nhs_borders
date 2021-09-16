library(tidyverse)
library(here)
library(janitor)
library(RColorBrewer)

cancer_incidence_all <- read_csv(here("data/opendata_inc9519_hb.csv")) %>% clean_names()
cancer_incidence_summary <- read_csv(here("data/opendata_inc1519comb_hb.csv")) %>% clean_names()
geography_hb_lookup <- read_csv(here("data/geography_codes_and_labels_hb2014_01042019.csv")) %>% clean_names()


cancer_incidence_borders <- cancer_incidence_all %>% 
  semi_join(geography_hb_lookup, by = "hb") %>% 
  filter (hb == "S08000016") 


cancer_incidence_summary_borders <- cancer_incidence_summary %>% 
  semi_join(geography_hb_lookup, by = "hb") %>% 
  filter (hb == "S08000016") 

cancer_incidence_borders <- cancer_incidence_borders %>% 
  rename ("cr_lower_ci" = "crude_rate_lower95pc_confidence_interval",
          "cr_upper_ci" = "crude_rate_upper95pc_confidence_interval",
          "easr_lower_ci" = "easr_lower95pc_confidence_interval",
          "easr_upper_ci" = "easr_upper95pc_confidence_interval",
          "wasr_lower_ci" = "wasr_lower95pc_confidence_interval",
          "wasr_upper_ci" = "wasr_upper95pc_confidence_interval",
          "sir_lower_ci" = "sir_lower95pc_confidence_interval",
          "sir_upper_ci" = "sir_upper95pc_confidence_interval",
  )

color_theme <- function() {
  theme(
    #hjust is used to align the title
    #text = element_text(size = 12),
    #title = element_text(size = 14),
    
    plot.background = element_rect(fill ="white"),
    plot.title = element_text(size = rel(2)),
    plot.title.position = "plot",
    
    panel.border = element_rect(colour = "blue", fill = NA, linetype = 1),
    panel.background = element_rect(fill = "white"),
    panel.grid =  element_line(colour = "grey85", linetype = 1, size = 0.5),
    
    axis.text = element_text(colour = "steelblue", face = "italic", size = 10 ),
    axis.title = element_text(colour = "brown" , face = "bold", size = 12),
    axis.ticks = element_line(colour = "steelblue"),
    
    legend.box.background = element_rect(),
    legend.box.margin = margin(6, 6, 6, 6)
    
  )
}

myColours <- brewer.pal(6,"Paired")

my.settings <- list(
  superpose.polygon=list(col=myColours[2:5], border="transparent"),
  strip.background=list(col=myColours[6]),
  strip.border=list(col="black")
)


cancer_incidence_summary_borders <- cancer_incidence_summary_borders %>% 
  pivot_longer(cols = incidences_age_under5:incidences_age85and_over,
               names_to = "age_category",
               values_to = "num_of_incidences") %>% 
  pivot_longer(cols = incidence_rate_age_under5:incidence_rate_age85and_over,
               names_to = "incidences_rate_category",
               values_to = "rate_of_incidences")  %>% 
  mutate(age_category = str_replace(age_category,"incidences_age_","" ),
         age_category = str_replace(age_category,"incidences_age","" ),
         incidences_rate_category = str_replace(incidences_rate_category,"incidence_rate_age_",""),
         incidences_rate_category = str_replace(incidences_rate_category,"incidence_rate_age","")) %>% 
  filter(age_category == incidences_rate_category) %>% 
  select (- incidences_rate_category)

cancer_incidence_summary_borders <- cancer_incidence_summary_borders %>%
  mutate (age_category = recode (age_category, "under5" = "Under 5",
                                 "85and_over" = "85 and Over"),
          age_category = str_replace (age_category, "to" , " - "))

cancer_incidence_summary_borders <- cancer_incidence_summary_borders %>% 
  mutate (age_category = as_factor(age_category)) %>% 
  mutate(age_category = fct_relevel(age_category, c("Under 5",
                                                    "5 - 9",
                                                    "10 - 14",
                                                    "15 - 19",
                                                    "20 - 24",
                                                    "25 - 29",
                                                    "30 - 34",
                                                    "35 - 39",
                                                    "40 - 44",
                                                    "45 - 49",
                                                    "50 - 54",
                                                    "55 - 59",
                                                    "60 - 64",
                                                    "65 - 69",
                                                    "70 - 74",
                                                    "75 - 79",
                                                    "80 - 84",
                                                    "85 and Over")))


cancer_incidence_summary_borders <- cancer_incidence_summary_borders %>% 
  filter (cancer_site != "Basal cell carcinoma of the skin",
          cancer_site != "Non-melanoma skin cancer")

cancer_incidence_borders <- cancer_incidence_borders %>% 
  filter (cancer_site != "Basal cell carcinoma of the skin",
          cancer_site != "Non-melanoma skin cancer")