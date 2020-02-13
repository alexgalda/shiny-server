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
reticulate::source_python(paste0(dir, "python_functions.py"))

backend.name     <- "ibmq_armonk"
provider         <- get_provider()
backend          <- get_backend(provider)
backend.config   <- backend_config(backend)
backend.defaults <- backend_defaults(backend)
pending.jobs     <- pending_jobs(backend)
time.now <- Sys.time()
attributes(time.now)$tzone <- "UTC"
timestamp <- as.character(time.now)

if(!file.exists(paste0(dir, "armonk.csv"))) {
  device_info <- data.frame(timestamp = character(0), queue = numeric(0), stringsAsFactors = FALSE)
  write.csv(device_info, file = paste0(dir, "armonk.csv"), row.names = FALSE, quote = FALSE)
}
device_info <- read.csv(paste0(dir, "armonk.csv"), skip = 0, header = TRUE, stringsAsFactors = FALSE)
if (length(device_info$timestamp) == 0) {
  device_info[1,] <- c(timestamp, pending.jobs)
} else {
  device_info <- rbind(device_info, c(timestamp, pending.jobs))
}

write.csv(device_info, file = paste0(dir, "armonk.csv"), row.names = FALSE, quote = FALSE)
####
gc()
