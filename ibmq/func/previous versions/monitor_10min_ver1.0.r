rm(list = setdiff(ls(), lsf.str()))

options(shiny.sanitize.errors = FALSE)

if (dir.exists("/opt/anaconda/")) {
  reticulate::use_python("/opt/anaconda/bin/python", required = TRUE)
  reticulate::py_config()
  dir <- "/srv/shiny-server/ibmq/"
} else {
  reticulate::use_python("C:\\ProgramData\\Anaconda3\\python.exe", required = TRUE)
  reticulate::py_config()
  dir <- "C:\\Users\\agalda\\Google Drive\\quantumgate.xyz\\shiny-server\\ibmq\\"
}
reticulate::source_python(paste0(dir, "qiskit_monitor.py"))
reticulate::source_python(paste0(dir, "backend_overview.py"))

for (backend.name in get_unique_backends()) {
  #backend.name <- as.character(get_unique_backends()[[8]])
  backend.name <- as.character(backend.name)
  provider     <- get_provider()
  backend      <- get_backend(provider, backend.name)
  time.now     <- Sys.time()
  attributes(time.now)$tzone <- "UTC"
  timestamp    <- as.character(time.now)
  
  ###
  
  file.monitor.10min <- paste0(dir, backend.name, "/", backend.name, "_10min.csv")
  if (!dir.exists(dirname(file.monitor.10min))) {
    dir.create(dirname(file.monitor.10min))
  }
  
  # 10min ---
  pending.jobs <- backend_pending_jobs(backend)
  if(!file.exists(file.monitor.10min)) {
    device.info.10min <- data.frame(timestamp = character(0),       #1
                                    pending_jobs = numeric(0),      #2
                                    stringsAsFactors = FALSE)
    write.csv(device.info.10min, file = file.monitor.10min, row.names = FALSE, quote = FALSE)
  }
  device.info.10min <- read.csv(file.monitor.10min, skip = 0, header = TRUE, stringsAsFactors = FALSE)
  if (length(device.info.10min$timestamp) == 0) {
    device.info.10min[1,] <- c(timestamp,        #1
                               pending.jobs)     #2
  } else {
    device.info.10min <- rbind(device.info.10min, c(timestamp,      #1
                                                    pending.jobs))  #2
  }
  write.csv(device.info.10min, file = file.monitor.10min, row.names = FALSE, quote = FALSE)
}

####
gc()
