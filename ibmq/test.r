library("tidyverse")
library("highcharter")
Moisture_kurokawa <- read_csv("./Moisture kurokawa.csv") %>%
  na.omit() %>%
  mutate(timestamp = lubridate::mdy_hms(sprintf("%s %s", Date, Time)))

hc <- highchart(type="stock")
for (k in names(Moisture_kurokawa)[3:7]) {
  hc <- hc_add_series_times_values(hc=hc, dates=Moisture_kurokawa$timestamp, 
                                   values=pull(Moisture_kurokawa, k), name = k)
}
hc