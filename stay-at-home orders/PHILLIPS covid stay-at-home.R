library(tidyverse)
library(ggplot2)
library(dplyr)
library(lubridate)
library(httr)
library(zoo)
library(cowplot)


# Get latest OxCGRT dataset

data <- GET("https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/OxCGRT_latest.csv")

national <- read.csv(textConnection(rawToChar(data$content))) %>%
  mutate(Date = ymd(Date)) %>%
  filter(Date < "2021-04-01") %>%    # filter out data added after March 2021, when this was written
  mutate(Date = as.Date(Date, format = "%Y-%m-%d")) %>%
  filter(Jurisdiction == "NAT_TOTAL") %>%    # remove subnational data
  group_by(Date)


################
##  FIGURE 1  ##
################

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



################
##  FIGURE 2  ##
################

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
  select(CountryCode, Date, StringencyIndex, StringencyIndexForDisplay, C6_Stay.at.home.requirements, ave7day_newcases, stay_home) %>%
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
  filter(Date > "2020-07-31") %>%
  group_by(CountryCode) %>%
  summarise(avecases = mean(ave7day_newcases)) %>%
  filter(avecases > 100) %>%
  select(CountryCode) %>%
  as_vector()

# lsit countries that averaged under 100 cases per day between April 2020 - March 2021
under100 <- national %>%
  filter(Date > "2020-07-31") %>%
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

fig_2_data <- national %>%
  filter(CountryCode %in% c(first_C6_10_cases_or_more),
         CountryCode %in% c(C6_more_than_once)) %>%
  mutate(over_100 = CountryCode %in% c(over100),
         under_100 = CountryCode %in% c(under100)) %>%
  filter(start_date_bool == TRUE) %>%
  group_by(CountryCode) %>%
  mutate(relative_cases = start_cases / start_cases[1])

# produce fig 2a
PHL_stay_home_periods <- stay_home_periods %>%
  filter(CountryCode == "PHL")
fig2a <- national %>%
  filter(CountryCode == "PHL") %>%
  ggplot(aes(x = Date, y = ave7day_newcases, group = CountryCode, color = CountryCode)) +
  annotate(geom = "rect", xmin = PHL_stay_home_periods$start_date, xmax = PHL_stay_home_periods$end_date, ymin = 0, ymax = Inf, fill = "red", alpha = 0.4) +
  geom_line(color = "black") +
  geom_point(aes(x = Date, y = start_cases), color = "dodgerblue", size = 3) +
  annotate(geom = "segment", x = as.Date("2020-01-01", format = "%Y-%m-%d"), xend = PHL_stay_home_periods$start_date, y = PHL_stay_home_periods$start_cases, yend = PHL_stay_home_periods$start_cases, color = "dodgerblue", linetype = "dashed", size = 0.8) +
#  scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
  scale_y_log10(labels = c("1", "10", "100", "1000", "10000", "100000"), breaks = c(1, 10, 100, 1000, 10000, 100000), limits = c(1, 100000)) +
  labs(title = "(a) Philippines",
       y = "New cases per day \n(7-day rolling average)") +
  theme_bw() +
  theme(plot.title = element_text(size=10))


# produce fig 2b
GBR_stay_home_periods <- stay_home_periods %>%
  filter(CountryCode == "GBR")
fig2b <- national %>%
  filter(CountryCode == "GBR") %>%
  ggplot(aes(x = Date, y = ave7day_newcases, group = CountryCode, color = CountryCode)) +
  annotate(geom = "rect", xmin = GBR_stay_home_periods$start_date, xmax = GBR_stay_home_periods$end_date, ymin = 0, ymax = Inf, fill = "red", alpha = 0.4) +
  geom_line(color = "black") +
  geom_point(aes(x = Date, y = start_cases), color = "dodgerblue", size = 3) +
  annotate(geom = "segment", x = as.Date("2020-01-01", format = "%Y-%m-%d"), xend = GBR_stay_home_periods$start_date, y = GBR_stay_home_periods$start_cases, yend = GBR_stay_home_periods$start_cases, color = "dodgerblue", linetype = "dashed", size = 0.8) +
#  scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
  scale_y_log10(labels = c("1", "10", "100", "1000", "10000", "100000"), breaks = c(1, 10, 100, 1000, 10000, 100000), limits = c(1, 100000)) +
  labs(title = "(b) United Kingdom",
       y = "New cases per day \n(7-day rolling average)") +
  ylab(NULL) +
  theme_bw() +
  theme(plot.title = element_text(size=10))

# produce fig 2c
AUS_stay_home_periods <- stay_home_periods %>%
  filter(CountryCode == "AUS")
fig2c <- national %>%
  filter(CountryCode == "AUS") %>%
  ggplot(aes(x = Date, y = ave7day_newcases, group = CountryCode, color = CountryCode)) +
    annotate(geom = "rect", xmin = AUS_stay_home_periods$start_date, xmax = AUS_stay_home_periods$end_date, ymin = 0, ymax = Inf, fill = "red", alpha = 0.4) +
    geom_line(color = "black") +
    geom_point(aes(x = Date, y = start_cases), color = "dodgerblue", size = 3) +
    annotate(geom = "segment", x = as.Date("2020-01-01", format = "%Y-%m-%d"), xend = AUS_stay_home_periods$start_date, y = AUS_stay_home_periods$start_cases, yend = AUS_stay_home_periods$start_cases, color = "dodgerblue", linetype = "dashed", size = 0.8) +
#    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    scale_y_log10(labels = c("1", "10", "100", "1000", "10000"), breaks = c(1, 10, 100, 1000, 10000), limits = c(1, 10000)) +
    labs(title = "(c) Australia",
       y = "New cases per day \n(7-day rolling average)") +
    theme(legend.position = "none") +
    theme_bw() +
    theme(plot.title = element_text(size=10))


# produce fig 2d
CHN_stay_home_periods <- stay_home_periods %>%
  filter(CountryCode == "CHN")
fig2d <- national %>%
  filter(CountryCode == "CHN") %>%
  ggplot(aes(x = Date, y = ave7day_newcases, group = CountryCode, color = CountryCode)) +
  annotate(geom = "rect", xmin = CHN_stay_home_periods$start_date, xmax = CHN_stay_home_periods$end_date, ymin = 0, ymax = Inf, fill = "red", alpha = 0.4) +
  geom_line(color = "black") +
  geom_point(aes(x = Date, y = start_cases), color = "dodgerblue", size = 3) +
  annotate(geom = "segment", x = as.Date("2020-01-01", format = "%Y-%m-%d"), xend = CHN_stay_home_periods$start_date, y = CHN_stay_home_periods$start_cases, yend = CHN_stay_home_periods$start_cases, color = "dodgerblue", linetype = "dashed", size = 0.8) +
#  scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
  scale_y_log10(labels = c("1", "10", "100", "1000", "10000"), breaks = c(1, 10, 100, 1000, 10000), limits = c(1, 10000)) +
  labs(title = "(d) China",
       y = "New cases per day \n(7-day rolling average)") +
  theme(legend.position = "none") +
  ylab(NULL) +
  theme_bw() +
  theme(plot.title = element_text(size=10))

plot_grid(fig2a, fig2b, fig2c, fig2d, labels = "", label_size = 10, rel_widths = c(1.1, 1))



################
##  FIGURE 3  ##
################

# produce fig 3a
fig3a <- ggplot(data = filter(fig_2_data, over_100==TRUE), mapping = aes(x = Date, y = relative_cases, color = under_100)) +
  geom_point(show.legend=FALSE) +
  scale_y_log10(labels = c("0.01", "0.1", "1", "10", "100", "1000"), breaks = c(0.01, 0.1, 1, 10, 100, 1000), limits = c(0.0035, 800)) +
  geom_text(data = filter(fig_2_data, over_100==TRUE, Date == last(Date)), aes(label=CountryCode),hjust=0, vjust=1, show.legend=FALSE, nudge_x = -25, nudge_y = 0.2, check_overlap = TRUE) +
  geom_line(aes(group = CountryCode, linetype = over_100), alpha = 0.4, size = 0.8, show.legend=FALSE) +
  labs(
    #    title = "(a)",
    #    color = "Average daily cases since April 2020",
    y = "Cases-per-day, relative to \ncases-per-day at first stay-at-home order") +
  scale_colour_manual(name = "Average daily \ncases April 2020 \nto March 2021", values = c("FALSE" = "orangered3", "TRUE" = "dodgerblue"), labels = c("more than 100", "100 or less")) +
  scale_linetype_manual(name = "Average daily \ncases April 2020 \nto March 2021", values = c("FALSE" = "dashed", "TRUE" = "solid"), labels = c("more than 100", "100 or less")) +
  theme_bw()

# produce fig 3b
fig3b <- ggplot(data = filter(fig_2_data, under_100==TRUE), mapping = aes(x = Date, y = relative_cases, color = under_100)) +
  geom_point(show.legend=FALSE) +
  scale_y_log10(labels = c("0.01", "0.1", "1", "10", "100", "1000"), breaks = c(0.01, 0.1, 1, 10, 100, 1000), limits = c(0.0035, 800)) +
  geom_text(data = filter(fig_2_data, under_100==TRUE, Date == last(Date)), aes(label=CountryCode),hjust=0, vjust=1, show.legend=FALSE, nudge_x = -25, nudge_y = 0.2) +
  geom_line(aes(group = CountryCode, linetype = under_100), alpha = 0.4, size = 0.8, show.legend=FALSE) +
  #  labs(title = "(b)",
  #       y = "Cases-per-day, relative to \ncases-per-day at first stay-at-home order",
  #       color = "Average daily cases since April 2020") +
  ylab(NULL) +
  scale_colour_manual(name = "Average daily \ncases April 2020 \nto March 2021", values = c("FALSE" = "orangered3", "TRUE" = "dodgerblue"), labels = c("more than 100", "100 or less")) +
  scale_linetype_manual(name = "Average daily \ncases April 2020 \nto March 2021", values = c("FALSE" = "dashed", "TRUE" = "solid"), labels = c("more than 100", "100 or less")) +
  theme_bw()

plot_grid(fig3a, fig3b, labels = c("(a)", "(b)"), label_size = 10, rel_widths = c(1.1, 1))
