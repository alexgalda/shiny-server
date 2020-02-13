users = reactiveValues(count = 0)

GHz <- 1.0e9
MHz <- 1.0e6

server <- function(input, output, session) {
  load_data()
  
  onSessionStart = isolate({
    users$count = users$count + 1
  })
  
  onSessionEnded(function() {
    isolate({
      users$count = users$count - 1
    })
  })
  
  if (dir.exists("/opt/anaconda/")) {
    reticulate::use_python("/opt/anaconda/bin/python", required = TRUE)
    reticulate::py_config()
    dir <- "/srv/shiny-server/ibmq/"
  } else {
    reticulate::use_python("C:\\ProgramData\\Anaconda3\\python.exe", required = TRUE)
    reticulate::py_config()
    dir <- "C:\\Users\\agalda\\Google Drive\\quantumgate.xyz\\shiny-server\\ibmq\\"
  }
  reticulate::source_python(paste0(dir, "python_functions.py"))
  
  backend.name     <- "ibmq_armonk"
  provider         <- get_provider()
  backend          <- get_backend(provider)
  backend.config   <- backend_config(backend)
  backend.defaults <- backend_defaults(backend)
  dt               <- device_dt(backend.config)
  
  # We will work with the following qubit.
  qubit <- 0
  center.frequency.Hz <- device_freq(backend.defaults, as.integer(qubit))
  
  #output$provider       <- renderText({paste0("provider: ", provider)})
  output$device.backend.title <- renderText({paste0("<b>", "Backend:", "</b>")})
  output$device.backend       <- renderText({paste0(backend)})
  output$device.dt.title      <- renderText({paste0("<b>", "Sampling time (dt):", "</b>")})
  output$device.dt            <- renderText({paste0("", dt, " ns")})
  output$device.freq.title    <- renderText({paste0("<b>", "Qubit [", qubit, "] estimated frequency:", "</b>")})
  output$device.freq          <- renderText({paste0(center.frequency.Hz/GHz, " GHz")})
  
  ########################
  
  channels <- collect_channels(as.integer(qubit))
  drive.chan <- channels[[1]]
  meas.chan  <- channels[[2]]
  acq.chan   <- channels[[3]]
  
  output$usercount <- reactive({paste0(users$count, " active session(s)")})
  
  
  if(!file.exists(paste0(dir, "armonk.csv"))) {
    device_info <- data.frame(timestamp = character(0), queue = numeric(0), stringsAsFactors = FALSE)
    write.csv(device_info, file = paste0(dir, "armonk.csv"), row.names = FALSE, quote = FALSE)
  }
  device_info <- read.csv(paste0(dir, "armonk.csv"), skip = 0, header = TRUE, stringsAsFactors = FALSE)
  device_info$timestamp <- datetime_to_timestamp(as.POSIXct(strptime(device_info$timestamp, "%Y-%m-%d %H:%M:%OS", tz = "UTC")))
  
  hc <- data.frame(time = device_info$timestamp, value = device_info$queue) %>% 
    hchart("line", hcaes(time, value)) %>% 
    hc_xAxis(type = "datetime") 
  
  hc$x$type <- "stock"
  
  output$infoplot <- renderHighchart(hc)
}
