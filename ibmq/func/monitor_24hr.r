# NOT FINISHED, MOSTLY CODE from monitor_1hr

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

source(paste0(dir, "func/file_exists.r"))

for (backend.name in get_unique_backends()) {
  #backend.name <- as.character(get_unique_backends()[[1]])
  backend.name <- as.character(backend.name)
  provider     <- get_provider()
  backend      <- get_backend(provider, backend.name)
  backend.defaults <- backend_defaults(backend)
  time.now     <- Sys.time()
  attributes(time.now)$tzone <- "UTC"
  
  ###
  
  file.monitor.1hr <- paste0(dir, backend.name, "/", backend.name, "_1hr.csv")
  if (!dir.exists(dirname(file.monitor.1hr))) {
    dir.create(dirname(file.monitor.1hr))
  }
  
  # 1hr ---
  timestamp        <- as.character(time.now)
  pending.jobs     <- backend_pending_jobs(backend)
  operational      <- backend_operational(backend)
  status_msg       <- backend_status_msg(backend)
  meas_freq_est    <- backend_meas_freq_est(backend.defaults)
  qubit_freq_est   <- backend_qubit_freq_est(backend.defaults)
  last_update_date <- backend_last_update_date(backend)
  attributes(last_update_date)$tzone <- "UTC"
  last_update_date <- as.character(last_update_date)
  # TO UPDATE: pulse_library, qubits and gates 
  
  file_exists(file.monitor.1hr, C("timestamp",                        #1
                                  "pending_jobs",                     #2
                                  "operational",                      #3
                                  "status_msg",                       #4
                                  "meas_freq_est",                    #5
                                  "qubit_freq_est",                   #6
                                  "last_update_date"))                #7
  
  device.info.1hr <- read.csv(file.monitor.1hr, skip = 0, header = TRUE, stringsAsFactors = FALSE)
  if (length(device.info.1hr$timestamp) == 0) {
    device.info.1hr[1,] <- list(timestamp,                            #1
                                pending_jobs,                         #2
                                operational,                          #3
                                status_msg,                           #4
                                meas_freq_est,                        #5
                                qubit_freq_est,                       #6
                                last_update_date)                     #7
  } else {
    device.info.1hr <- rbind(device.info.1hr, list(timestamp,         #1
                                                   pending_jobs,      #2
                                                   operational,       #3
                                                   status_msg,        #4
                                                   meas_freq_est,     #5
                                                   qubit_freq_est,    #6
                                                   last_update_date)) #7
  }
}


file.monitor.24hr  <- paste0(dir, backend.name, "/", backend.name, "_24hr.csv")
if (!dir.exists(dirname(file.monitor.24hr))) {
  dir.create(dirname(file.monitor.24hr))
}



# 24hr ---
n_qubits        <- backend_n_qubits(backend)
max_shots       <- backend_max_shots(backend)
max_experiments <- backend_max_experiments(backend)
basis_gates     <- backend_basis_gates(backend)
coupling_map    <- backend_coupling_map(backend)
memory          <- backend_memory(backend)
if(!file.exists(file.monitor.24hr)) {
  device.info.24hr <- data.frame(timestamp = character(0),        #1
                                 n_qubits = character(0),         #2
                                 stringsAsFactors = FALSE)
  write.csv(device.info.24hr, file = file.monitor.24hr, row.names = FALSE, quote = FALSE)
}
device.info.24hr <- read.csv(file.monitor.24hr, skip = 0, header = TRUE, stringsAsFactors = FALSE)
if (length(device.info.24hr$timestamp) == 0) {
  device.info.24hr[1,] <- c(timestamp,         #1
                            n_qubits)          #2
} else {
  device.info.24hr <- rbind(device.info.24hr, c(timestamp,        #1
                                                n_qubits))        #2
}

write.csv(device.info.10min, file = file.monitor.10min, row.names = FALSE, quote = FALSE)
write.csv(device.info.1hr,   file = file.monitor.1hr,   row.names = FALSE, quote = FALSE)
write.csv(device.info.24hr,  file = file.monitor.24hr,  row.names = FALSE, quote = FALSE)
####
gc()
