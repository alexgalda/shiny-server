rm(list = setdiff(ls(), lsf.str()))

options(shiny.sanitize.errors = FALSE)

do.pulse.library <- FALSE

if (dir.exists("/opt/anaconda/")) {
  reticulate::use_python("/opt/anaconda/bin/python", required = TRUE)
  reticulate::py_config()
  dir <- "/srv/shiny-server/ibmq/"
} else {
  reticulate::use_python("C:\\ProgramData\\Anaconda3\\python.exe", required = TRUE)
  #reticulate::use_python("C:\\users\\agalda\\appdata\\roaming\\python\\python.exe", required = TRUE)
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
  
  file.monitor.1hr   <- paste0(dir, backend.name, "/", backend.name, "_1hr.csv")
  file.pulse_library <- paste0(dir, backend.name, "/pulse_library/", backend.name, "_", gsub(":", "_", timestamp), ".txt")
  file.qubits        <- paste0(dir, backend.name, "/qubits/", backend.name, "_", gsub(":", "_", timestamp), ".csv")
  file.gates_err     <- paste0(dir, backend.name, "/gates_err/", backend.name, "_", gsub(":", "_", timestamp), ".csv")
  file.gates_dur     <- paste0(dir, backend.name, "/gates_dur/", backend.name, "_", gsub(":", "_", timestamp), ".csv")
  if (!dir.exists(dirname(file.monitor.1hr))) {
    dir.create(dirname(file.monitor.1hr))
  }
  if (!dir.exists(dirname(file.pulse_library))) {
    dir.create(dirname(file.pulse_library))
  }
  if (!dir.exists(dirname(file.qubits))) {
    dir.create(dirname(file.qubits))
  }
  if (!dir.exists(dirname(file.gates_err))) {
    dir.create(dirname(file.gates_err))
  }
  if (!dir.exists(dirname(file.gates_dur))) {
    dir.create(dirname(file.gates_dur))
  }
  
  find_latest_file <- function(dir) {
    #dir = dirname(file.pulse_library)
    all.files      <- list.files(dir)
    all.timestamps <- substr(all.files, nchar(all.files) - 22, nchar(all.files) - 4)
    max.timestamp  <- which.max(as.POSIXct(strptime(all.timestamps, "%Y-%m-%d %H_%M_%S")))
    return(list.files(dir, full.names = TRUE)[max.timestamp])
  }
  
  # 1hr -------------------------------------------------------------------------------------------
  pending.jobs     <- backend_pending_jobs(backend)
  operational      <- backend_operational(backend)
  status_msg       <- backend_status_msg(backend)
  meas_freq_est    <- backend_meas_freq_est(backend)
  qubit_freq_est   <- backend_qubit_freq_est(backend)
  last_update_date <- backend_last_update_date(backend)
  attributes(last_update_date)$tzone <- "UTC"
  last_update_date <- as.character(last_update_date)
  
  if(!file.exists(file.monitor.1hr)) {
    device.info.1hr <- data.frame(timestamp        = character(0),    #1
                                  pending_jobs     = numeric(0),      #2 
                                  operational      = character(0),    #3
                                  status_msg       = character(0),    #4
                                  meas_freq_est    = numeric(0),      #5
                                  qubit_freq_est   = numeric(0),      #6
                                  last_update_date = character(0),    #7
                                  stringsAsFactors = FALSE)
    write.csv(device.info.1hr, file = file.monitor.1hr, row.names = FALSE, quote = FALSE)
  }
  device.info.1hr <- read.csv(file.monitor.1hr, skip = 0, header = TRUE, stringsAsFactors = FALSE)
  if (length(device.info.1hr$timestamp) == 0) {
    device.info.1hr[1,] <- list(timestamp,                            #1
                                pending.jobs,                         #2
                                operational,                          #3
                                status_msg,                           #4
                                meas_freq_est,                        #5
                                qubit_freq_est,                       #6
                                last_update_date)                     #7
  } else {
    device.info.1hr <- rbind(device.info.1hr, list(timestamp,         #1
                                                   pending.jobs,      #2
                                                   operational,       #3
                                                   status_msg,        #4
                                                   meas_freq_est,     #5
                                                   qubit_freq_est,    #6
                                                   last_update_date)) #7
  }
  write.csv(device.info.1hr, file = file.monitor.1hr, row.names = FALSE, quote = FALSE)

  if (do.pulse.library) {
    # pulse_library  --------------------------------------------------------------------------------
    pulse_library    <- paste(as.character(backend_pulse_library(backend)), collapse = '\n')
    
    # check if pulse_library is an exact copy of previous file ----
    previous.file    <- find_latest_file(dirname(file.pulse_library))
    if (length(previous.file) > 0) {
      previous.pulse <- readChar(previous.file, file.info(previous.file)$size)
    } else {
      previous.pulse <- "\r\n"
    }
    # save this pulse_library ----
    write(pulse_library, file = file.pulse_library)
    this.pulse      <- readChar(file.pulse_library, file.info(previous.file)$size)
    if (identical(previous.pulse, this.pulse)) {
      file.remove(file.pulse_library)
    }
    
    backend.calibration.data <- backend_calibration(backend)
  }
  
  # qubits ----------------------------------------------------------------------------------------
  qubits    <- backend.calibration.data[[1]]
  dt.qubits <- as.data.frame(t(matrix(unlist(qubits), nrow = length(unlist(qubits[1])))))
  colnames(dt.qubits) <- c('Name', 'Freq', 'T1', 'T2', 'U1 err', 'U2 err', 'U3 err', 'Readout err')
  
  # check if qubits is an exact copy of previous file ----
  previous.file <- find_latest_file(dirname(file.qubits))
  if (length(previous.file) > 0) {
    previous.qubits <- read.csv(previous.file, skip = 0, header = TRUE, stringsAsFactors = FALSE)
  } else {
    previous.qubits <- ""
  }
  # save this qubits ----
  write.csv(dt.qubits, file = file.qubits, row.names = FALSE, quote = FALSE)
  this.qubits     <- read.csv(file.qubits, skip = 0, header = TRUE, stringsAsFactors = FALSE)
  if (identical(previous.qubits, this.qubits)) {
    file.remove(file.qubits)
  }
  
  # gates -----------------------------------------------------------------------------------------
  gates_err    <- backend.calibration.data[[2]]
  gates_dur    <- backend.calibration.data[[3]]
  dt.gates_err <- as.data.frame(t(matrix(unlist(gates_err), nrow = length(unlist(gates_err[1])))))
  dt.gates_dur <- as.data.frame(t(matrix(unlist(gates_dur), nrow = length(unlist(gates_dur[1])))))
  colnames(dt.gates_err) <- dt.qubits$Name
  colnames(dt.gates_dur) <- dt.qubits$Name
  rownames(dt.gates_err) <- dt.qubits$Name
  rownames(dt.gates_dur) <- dt.qubits$Name
  
  # check if gates_err is an exact copy of previous file ----
  previous.file <- find_latest_file(dirname(file.gates_err))
  if (length(previous.file) > 0) {
    previous.gates_err <- read.csv(previous.file, skip = 0, header = TRUE, stringsAsFactors = FALSE)
  } else {
    previous.gates_err <- ""
  }
  # save this gates_err ----
  write.csv(dt.gates_err, file = file.gates_err, row.names = FALSE, quote = FALSE)
  this.gates_err     <- read.csv(file.gates_err, skip = 0, header = TRUE, stringsAsFactors = FALSE)
  if (identical(previous.gates_err, this.gates_err)) {
    file.remove(file.gates_err)
  }
  
  # check if gates_dur is an exact copy of previous file ----
  previous.file <- find_latest_file(dirname(file.gates_dur))
  if (length(previous.file) > 0) {
    previous.gates_dur <- read.csv(previous.file, skip = 0, header = TRUE, stringsAsFactors = FALSE)
  } else {
    previous.gates_dur <- ""
  }
  # save this gates_dur ----
  write.csv(dt.gates_dur, file = file.gates_dur, row.names = FALSE, quote = FALSE)
  this.gates_dur     <- read.csv(file.gates_dur, skip = 0, header = TRUE, stringsAsFactors = FALSE)
  if (identical(previous.gates_dur, this.gates_dur)) {
    file.remove(file.gates_dur)
  }
}

####
gc()
