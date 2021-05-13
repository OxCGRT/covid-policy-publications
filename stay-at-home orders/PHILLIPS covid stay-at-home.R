library(tidyverse)
library(ggplot2)
library(dplyr)
library(httr)
library(zoo)


# Get latest OxCGRT dataset

data <- GET("https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/OxCGRT_latest.csv")

national <- read.csv(textConnection(rawToChar(data$content))) %>%
  mutate(Date = ymd(Date)) %>%
  filter(Date < "2021-03-01") %>%    # filter out data added after March 2021, when this was written
  mutate(Date = as.Date(Date, format = "%Y-%m-%d")) %>%
  filter(Jurisdiction == "NAT_TOTAL") %>%    # remove subnational data
  group_by(Date)


## FIG 1

americas <- c("AIA", "ATG", "ABW", "BHS", "BRB", "BES", "VGB", "CYM", "CUB", "CUW", "DMA", "DOM", "GRD", "GLP", "HTI", "JAM", "MTQ", "MSR", "PRI", "BLM", "KNA", "LCA", "MAF", "VCT", "SXM", "TTO", "TCA", "VIR", "BLZ", "CRI", "SLV", "GTM", "HND", "MEX", "NIC", "PAN", "ARG", "BOL", "BVT", "BRA", "CHL", "COL", "ECU", "FLK", "GUF", "GUY", "PRY", "PER", "SGS", "SUR", "URY", "VEN", "BMU", "CAN", "GRL", "SPM", "USA", "ATA")
europe <- c("BLR", "BGR", "CZE", "HUN", "POL", "MDA", "ROU", "RUS", "SVK", "UKR", "ALA", "GGY", "JEY", "DNK", "EST", "FRO", "FIN", "ISL", "IRL", "IMN", "LVA", "LTU", "NOR", "SJM", "SWE", "GBR", "ALB", "AND", "BIH", "HRV", "GIB", "GRC", "VAT", "ITA", "MLT", "MNE", "MKD", "PRT", "SMR", "SRB", "SVN", "ESP", "AUT", "BEL", "FRA", "DEU", "LIE", "LUX", "MCO", "NLD", "CHE", "RKS")
asia <- c("KAZ", "KGZ", "TJK", "TKM", "UZB", "CHN", "HKG", "MAC", "PRK", "JPN", "MNG", "KOR", "BRN", "KHM", "IDN", "LAO", "MYS", "MMR", "PHL", "SGP", "THA", "TLS", "VNM", "AFG", "BGD", "BTN", "IND", "IRN", "MDV", "NPL", "PAK", "LKA", "ARM", "AZE", "BHR", "CYP", "GEO", "IRQ", "ISR", "JOR", "KWT", "LBN", "OMN", "QAT", "SAU", "PSE", "SYR", "TUR", "ARE", "YEM", "TWN")
oceania <- c("AUS", "CXR", "CCK", "HMD", "NZL", "NFK", "FJI", "NCL", "PNG", "SLB", "VUT", "GUM", "KIR", "MHL", "FSM", "NRU", "MNP", "PLW", "UMI", "ASM", "COK", "PYF", "NIU", "PCN", "WSM", "TKL", "TON", "TUV", "WLF")
africa <- c("DZA", "EGY", "LBY", "MAR", "SDN", "TUN", "ESH", "IOT", "BDI", "COM", "DJI", "ERI", "ETH", "ATF", "KEN", "MDG", "MWI", "MUS", "MYT", "MOZ", "REU", "RWA", "SYC", "SOM", "SSD", "UGA", "TZA", "ZMB", "ZWE", "AGO", "CMR", "CAF", "TCD", "COG", "COD", "GNQ", "GAB", "STP", "BWA", "SWZ", "LSO", "NAM", "ZAF", "BEN", "BFA", "CPV", "CIV", "GMB", "GHA", "GIN", "GNB", "LBR", "MLI", "MRT", "NER", "NGA", "SHN", "SEN", "SLE", "TGO")

national %>%
  mutate(count_C6 = ifelse(C6_Stay.at.home.requirements >= 2, 1, 0)) %>%
  mutate(region = NA) %>%
  mutate(
    region = ifelse(CountryCode %in% americas, "Americas", region),
    region = ifelse(CountryCode %in% europe, "Europe", region),
    region = ifelse(CountryCode %in% asia, "Asia & Oceania", region),
    region = ifelse(CountryCode %in% oceania, "Asia & Oceania", region),
    region = ifelse(CountryCode %in% africa, "Africa", region)
  ) %>%
  group_by(region, Date) %>%
  summarise(pct_C6 = mean(count_C6, na.rm = TRUE)) %>%
  arrange(region, Date) %>%
  ggplot() +
    geom_line(aes(x = Date, y = pct_C6, color = region, linetype = region), size = 1) +
    theme(legend.position="bottom") +
    ylab("Percentage of countries with a stay-at-home order") +
    scale_linetype_manual(name = "Region", values = c("Africa" = "solid", "Americas" = "dotted", "Asia & Oceania" = "twodash", "Europe" = "solid")) +
    scale_color_manual(name = "Region", values = c("Africa" = "grey0", "Americas" = "grey24", "Asia & Oceania" = "grey54", "Europe" = "grey78")) +
    theme_bw()


## FIG 2

# add variables for 7-day average case counts, and marking the beggining and end of stay-at-home periods 
national <- national %>%
  group_by(CountryCode) %>%
  arrange(CountryCode, Date) %>%
  mutate(ave7day_confirmedcases = zoo::rollmean(ConfirmedCases, k = 7, fill = NA, na.rm = T, align = 'right'), 
         ave7day_confirmedcases = ifelse(is.nan(ave7day_confirmedcases), NA, ave7day_confirmedcases),
         lag_ave7day_cases = lag(ave7day_confirmedcases, order_by = Date), 
         ave7day_newcases = ifelse(ave7day_confirmedcases - lag_ave7day_cases > 0, ave7day_confirmedcases - lag_ave7day_cases, 0)) %>%
  select(-lag_ave7day_cases) %>%
  mutate(stay_home = C6_Stay.at.home.requirements >= 2) %>%
  ungroup() %>%
  arrange(CountryCode, Date) %>%
  select(CountryCode, Date, StringencyIndex, C6_Stay.at.home.requirements, ave7day_newcases, stay_home) %>%
  group_by(CountryCode) %>%
  mutate(start_date_bool = stay_home == TRUE & !lag(stay_home),
         end_date_bool = stay_home == TRUE & (!lead(stay_home, default = FALSE) | is.na(lead(stay_home)))) %>%
  mutate(start_cases = ifelse(start_date_bool, ave7day_newcases, NA),
         end_cases = ifelse(end_date_bool, ave7day_newcases, NA))

# create a data frame of periods of stay-at-home orders
stay_home_periods <- national %>%
  filter(start_date_bool == TRUE | end_date_bool == TRUE) %>%
  mutate(start_date = as.Date(Date, format = "%Y-%m-%d"),
         end_date = as.Date(lead(Date), format = "%Y-%m-%d")) %>%
  filter(start_date_bool) %>%
  ungroup() %>%
  select(CountryCode, start_date, end_date, start_cases)

# list countries that averaged over 100 cases per day between April 2020 - March 2021
over100 <- national %>%
  filter(Date > "2020-03-31") %>%
  group_by(CountryCode) %>%
  summarise(avecases = mean(ave7day_newcases)) %>%
  filter(avecases > 100) %>%
  select(CountryCode) %>%
  as_vector()

# lsit countries that averaged under 100 cases per day between April 2020 - March 2021
under100 <- national %>%
  filter(Date > "2020-03-31") %>%
  group_by(CountryCode) %>%
  summarise(avecases = mean(ave7day_newcases)) %>%
  filter(avecases <= 100) %>%
  select(CountryCode) %>%
  as_vector()

# list countries with more than 10 cases per day when first implementing stay-at-home order
first_C6_10_cases_or_more <- national %>%
  filter(stay_home == TRUE) %>%
  arrange(CountryCode, Date) %>%
  group_by(CountryCode) %>%
  filter(row_number() == 1 &
           ave7day_newcases > 10) %>%
  ungroup() %>%
  select(CountryCode) %>%
  as_vector()

# list countries that implemented more than one stay-at-home order
C6_more_than_once <- stay_home_periods %>%
  group_by(CountryCode) %>%
  filter(row_number() != 1) %>%
  filter(row_number() == 1) %>%
  ungroup() %>%
  select(CountryCode) %>%
  as_vector()

# produce fig 2a
fig_2_data <- national %>%
  filter(CountryCode %in% c(first_C6_10_cases_or_more),
         CountryCode %in% c(C6_more_than_once)) %>%
  mutate(over_100 = CountryCode %in% c(over100),
         under_100 = CountryCode %in% c(under100)) %>%
  filter(start_date_bool == TRUE) %>%
  group_by(CountryCode) %>%
  mutate(relative_cases = start_cases / start_cases[1])

ggplot(data = fig_2_data, mapping = aes(x = Date, y = relative_cases, color = under_100)) +
  geom_point(show.legend=FALSE) +
  scale_y_log10(labels = function(x) format(x, scientific = FALSE), n.breaks = 6) +
  geom_text(data = filter(fig_2_data, Date == last(Date)), aes(label=CountryCode),hjust=0, vjust=1, show.legend=FALSE) +
  geom_line(aes(group = CountryCode, linetype = under_100), alpha = 0.4, size = 0.8) +
  labs(title = "(a)",
       y = "Cases-per-day, relative to \ncases-per-day at first stay-at-home order" ,
       color = "Average daily cases since April 2020") +
  scale_colour_manual(name = "Average daily \ncases April 2020 \nto March 2021", values = c("FALSE" = "orangered3", "TRUE" = "dodgerblue"), labels = c("more than 100", "100 or less")) +
  scale_linetype_manual(name = "Average daily \ncases April 2020 \nto March 2021", values = c("FALSE" = "dashed", "TRUE" = "solid"), labels = c("more than 100", "100 or less")) +
  theme_bw()

# produce fig 2b
PHL_stay_home_periods <- stay_home_periods %>%
  filter(CountryCode == "PHL")
national %>%
  filter(CountryCode == "PHL") %>%
  ggplot(aes(x = Date, y = ave7day_newcases, group = CountryCode, color = CountryCode)) +
  annotate(geom = "rect", xmin = PHL_stay_home_periods$start_date, xmax = PHL_stay_home_periods$end_date, ymin = 0, ymax = Inf, fill = "red", alpha = 0.4) +
  geom_line(color = "black") +
  geom_point(aes(x = Date, y = start_cases), color = "dodgerblue", size = 3) +
  annotate(geom = "segment", x = as.Date("2020-01-01", format = "%Y-%m-%d"), xend = PHL_stay_home_periods$start_date, y = PHL_stay_home_periods$start_cases, yend = PHL_stay_home_periods$start_cases, color = "dodgerblue", linetype = "dashed", size = 0.8) +
  scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
  labs(title = "(b) stay-at-home orders in the Philippines",
       y = "New cases per day (7-day rolling average)") +
  theme_bw()

# produce fig 2c
AUS_stay_home_periods <- stay_home_periods %>%
  filter(CountryCode == "AUS")
national %>%
  filter(CountryCode == "AUS") %>%
  ggplot(aes(x = Date, y = ave7day_newcases, group = CountryCode, color = CountryCode)) +
    annotate(geom = "rect", xmin = AUS_stay_home_periods$start_date, xmax = AUS_stay_home_periods$end_date, ymin = 0, ymax = Inf, fill = "red", alpha = 0.4) +
    geom_line(color = "black") +
    geom_point(aes(x = Date, y = start_cases), color = "dodgerblue", size = 3) +
    annotate(geom = "segment", x = as.Date("2020-01-01", format = "%Y-%m-%d"), xend = AUS_stay_home_periods$start_date, y = AUS_stay_home_periods$start_cases, yend = AUS_stay_home_periods$start_cases, color = "dodgerblue", linetype = "dashed", size = 0.8) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    labs(title = "(c) stay-at-home orders in Australia",
       y = "New cases per day (7-day rolling average)") +
    theme(legend.position = "none") +
    theme_bw()
