# Duplicate application IDs
source("scripts/00_load-packages.R")
source("scripts/00_functions.R")

exporter <- fst::read_fst("/Volumes/research_data/nihexporter/projects/nih_exporter_projects.fst") %>% 
  as_tibble()

exporter %<>% mutate(row = row_number())

exporter_dups = exporter %>%
  group_by(application_id) %>% 
  filter(n() > 1) %>% 
  ungroup()

# view(exporter_dups)
dup_appids = unique(exporter_dups$application_id)
assertthat::assert_that(
  (length(dup_appids) == 1) & (dup_appids == 7916889), 
  msg = "Duplicate for application ID 7916889 is the only one we expect"
)

# One entry is in FY2011 and one in FY 2016
# The only entry remaining in RePORTER is from FY 2011
# https://reporter.nih.gov/search/ebrZWFRJ8ECO64lGe0C0iA/project-details/7916889

# Which rows to remove from ExPORTER
exporter_dups_leaveout = exporter_dups %>% 
  filter((dup_appids == 7916889 & fy == 2016))

k = nrow(exporter)
exporter = exporter %>% anti_join(exporter_dups_leaveout, by = "row")
assertthat::assert_that(k - 1 == nrow(exporter), 
                        msg = "Fewer rows in ExPORTER remaining than expected after
                        eliminating duplicates")

# exporter %>% filter(application_id == 7916889) %>% select(fy)
fst::write_fst(exporter, "/Volumes/research_data/nihexporter/projects/nih_exporter_projects.fst")