# UPDATED included variable altitudes (2500-1500, ironman, etc.)
# abs.top, abs.bottom are unused so far 

highstock <- function(device.info.10min) { 
  export <- list(
    list(text = "PNG image",
         onclick = JS("function () { 
                    this.exportChart({ type: 'image/png' }); }")),
    list(text = "JPEG image",
         onclick = JS("function () { 
                    this.exportChart({ type: 'image/jpeg' }); }")),
    list(text = "SVG vector image",
         onclick = JS("function () { 
                    this.exportChart({ type: 'image/svg+xml' }); }")),
    list(text = "PDF document",
         onclick = JS("function () { 
                    this.exportChart({ type: 'application/pdf' }); }"))
  )
  
  device.info.10min$timestamp <- datetime_to_timestamp(as.POSIXct(strptime(device.info.10min$timestamp, "%Y-%m-%dT%H:%M:%OS+00:00", tz = "UTC")))
  
  plot <- data.frame(time = device.info.10min$timestamp, jobs = device.info.10min$pending_jobs) %>%
    hchart("line", hcaes(time, jobs), name = c("jobs"), units = c("")) %>% 
    hc_xAxis(type = "datetime") %>%
    hc_yAxis(labels = list(format = "{value:.0f}")) %>%
    hc_subtitle(text = "Job queue history") %>% 
    hc_tooltip(crosshairs = TRUE,
               shared = TRUE,
               valueDecimals = 0,
               followTouchMove = FALSE,
               pointFormat = '<b>Queue:</b> {point.y} jobs<br/>') %>%
    hc_exporting(enabled = TRUE,
                 formAttributes = list(target = "_blank"),
                 buttons = list(contextButton = list(
                   text = "Export", theme = list(fill = "transparent"),
                   menuItems = export)))# %>%
    #hc_add_theme(hc_theme_google())
  plot$x$type <- "stock"
  return(plot)
}
