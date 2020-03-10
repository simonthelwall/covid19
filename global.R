# global.R
library(dplyr)
library(ggplot2)
library(plotly)
library(cowplot)
library(RCurl)
library(lubridate)
library(stringr)
library(janitor)
library(tidyr)
library(plotly)

source("helpers.R")
# https://shiny.rstudio.com/tutorial/written-tutorial/lesson5/
country_selector <- readRDS("./data/country_selector.rds")

# get and process case data ####

# auto_invalidate <- invalidateLater(43200000)
# 
# reactive_data <- reactive({
#   auto_invalidate()
# 
# time_last_update <- Sys.time()

from <- getURL("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")
dat <-read.csv(text = from, stringsAsFactors = FALSE) %>%
  clean_names()

print(exists("integer_breaks"))
print(exists("dat"))

dat_long <- dat %>%
  select(-long, -lat, -province_state) %>%
  pivot_longer(names_to = "date", -country_region)

dat_long <- dat_long %>%
  mutate(date = str_replace(date, "x", ""),
         date = mdy(date),
         value = ifelse(country_region == "Japan" & date == dmy("06-02-2020"), value - 20, value)
         # value = ifelse(country_region == "Japan" & date == dmy("07-02-2020"), value - 20, value)
  )

dat_long <- dat_long %>%
  group_by(country_region, date) %>%
  summarise(value = sum(value)) %>%
  mutate(lag_val = lag(value, 1),
         on_cases = as.integer(value - lag_val)) %>% 
  ungroup() %>% 
  mutate(country_region = str_trim(country_region, "both"))

# get and process death data ####

from_death <- getURL("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")
dat_death <- read.csv(text = from_death, stringsAsFactors = FALSE) %>%
  clean_names()

dat_death_long <- dat_death %>%
  select(-long, -lat, -province_state) %>%
  pivot_longer(names_to = "date", -country_region)

dat_death_long <- dat_death_long %>%
  mutate(date = str_replace(date, "x", ""),
         date = mdy(date))

dat_death_long <- dat_death_long %>%
  group_by(country_region, date) %>%
  summarise(value = sum(value)) %>%
  mutate(lag_val = lag(value, 1),
         on_cases = as.integer(value - lag_val)) %>% 
  ungroup()

dat_death_long <- dat_death_long %>% 
  mutate(country_region = str_trim(country_region, "both")) %>% 
  select(country_region, date, deaths = value, on_deaths = on_cases)

# get and process recovery data ####

from_recov <- getURL("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")
dat_recov <- read.csv(text = from_recov, stringsAsFactors = FALSE) %>%
  clean_names()
dat_recov_long <- dat_recov %>%
  select(-long, -lat, -province_state) %>%
  pivot_longer(names_to = "date", -country_region)

dat_recov_long <- dat_recov_long %>%
  mutate(date = str_replace(date, "x", ""),
         date = mdy(date))

dat_recov_long <- dat_recov_long %>%
  group_by(country_region, date) %>%
  summarise(value = sum(value)) %>%
  mutate(lag_val = lag(value, 1),
         on_cases = as.integer(value - lag_val)) %>% 
  ungroup()

dat_recov_long <- dat_recov_long %>% 
  mutate(country_region = str_trim(country_region, "both")) %>% 
  select(country_region, date, recovs = value, on_recov = on_cases)

# current cases ####

dat_curre <- dat_long %>%
  select(country_region, date, value) %>% 
  left_join(., select(dat_recov_long, country_region, date, recovs)) %>% 
  left_join(., select(dat_death_long, country_region, date, deaths)) %>%
  mutate(current_cases = value - (deaths + recovs))


# calculate CFRs ####
tot_cases <- dat_long %>% 
  group_by(country_region) %>% 
  summarise(tot_n = sum(on_cases, na.rm = TRUE))

tot_death <- dat_death_long %>% 
  group_by(country_region) %>% 
  summarise(tot_d = sum(on_deaths, na.rm = TRUE))

tot_recov <- dat_recov_long %>% 
  group_by(country_region) %>% 
  summarise(tot_r = sum(on_recov, na.rm = TRUE))

all_summ <- tot_cases %>% 
  left_join(., tot_death) %>% 
  left_join(., tot_recov) %>% 
  mutate(cfr = (tot_d / tot_n) * 100) %>% 
  arrange((desc(cfr))) %>% 
  mutate(country_region = factor(country_region, levels = as.ordered(country_region)))

global <- all_summ %>% 
  summarise_at(vars(starts_with("tot")), .funs = "sum") %>% 
  mutate(country_region = "Global", cfr = (tot_d / tot_n) * 100) %>% 
  select(country_region, tot_n, tot_d, tot_r, cfr)

rm(tot_cases, tot_death, tot_recov)
# })
# end data collection and processing