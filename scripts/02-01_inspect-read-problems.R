# Some of the ExPORTER CSV files have parsing issues due to 
# unescaped quotes in PI names (e.g. JOHNSON, DWAYNE "THE ROCK")
# There aren't obvious solutions to this problem. Options tried include: 
# read_delim(..., escape_double = F) 
# https://stackoverflow.com/questions/53617979/readrread-csv-parsing-failure-with-nested-quotations
# but it leads to a different parsing problem of too many columns 
# reading in everything with readLines() and replacing problematic quotes etc then reading that as csv
# but I'm nervous about using regex in such a situation and not being able to detect errors
# https://stackoverflow.com/questions/6032296/how-to-read-quoted-text-containing-escaped-quotes
# This seems to suggest there isn't a super straightforward fix: 
# https://github.com/tidyverse/readr/issues/776

# data.table::fread seems set up to "fix" this issue automatically, but seems to 
# read in the PI names field the same as read_csv() anyway. 
# read_csv() is more transparent and verbose about where the problems are
# than data.table::fread, so decided to stay with it so that it's easier to pinpoint
# in the future if the parsing issue turns out to be a problem

# The script reads in the files with parsing issues and outputs the 
# rows with those issues as a view-able table. 
# Then you can look through and see if the problem row was parsed with any issues or not
# It also outputs other rows without parsing issues so that any mistakes
# stand out more easily. 
# On the last inspection on 2021-09-24, all the problem rows were checked by 
# Wei Yang Tham and looked fine. 


library(tidyverse)
library(magrittr)

# Function for reading in zipped ExPORTER CSV files
source("scripts/read_exporter_proj.R")

# Vector of fiscal years
file_fy = 2016:2019

# Assign each list item the FY as its name
allproj <- file_fy %>% purrr::set_names() %>% 
  purrr::map(~read_exporter_proj(fyr = .)) 

# Fiscal Year to focus on 
problemfy = 2019

# Extract data and problems() file for problemfy
problemfy_output = allproj[[as.character(problemfy)]]

# Row numbers of problem rows
problemrows = problemfy_output$problems %>% pull(row) %>% unique()

# Pull out "problem" rows and the row just after them for easy comparison to a row 
# without problems
problemfy_output$data %>% 
  mutate(problem = row_number() %in% problemrows) %>% 
  filter(row_number() %in% c(problemrows, problemrows + 1)) %>%
  select(problem, everything()) %>% 
  View()
