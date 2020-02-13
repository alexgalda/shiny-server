rm(list = setdiff(ls(), lsf.str()))

options(shiny.sanitize.errors = FALSE)

do.pulse.library <- FALSE

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
  #backend.name <- as.character(get_unique_backends()[[8]])
  backend.name <- as.character(backend.name)
  provider     <- get_provider()
  backend      <- get_backend(provider, backend.name)
  time.now     <- Sys.time()
  attributes(time.now)$tzone <- "UTC"
  
  file.monitor.1hr <- paste0(dir, "/backends/", backend.name, "/", backend.name, "_1hr.csv")
  file_exists(file.monitor.1hr, c("timestamp",                        #1
                                  "pending_jobs",                     #2
                                  "operational",                      #3
                                  "status_msg",                       #4
                                  "meas_freq_est",                    #5
                                  "qubit_freq_est",                   #6
                                  "last_update_date"))                #7
  
  # 1hr -------------------------------------------------------------------------------------------
  timestamp.file   <- gsub(":", "_", as.character(time.now))
  timestampUTC     <- paste0(format(time.now,'%Y-%m-%dT%H:%M:%S'), "+00:00")
  pending.jobs     <- backend_pending_jobs(backend)
  operational      <- backend_operational(backend)
  status_msg       <- backend_status_msg(backend)
  meas_freq_est    <- backend_meas_freq_est(backend)
  qubit_freq_est   <- backend_qubit_freq_est(backend)
  last_update_date <- backend_last_update_date(backend)
  attributes(last_update_date)$tzone <- "UTC"
  last_update_date <- paste0(format(last_update_date,'%Y-%m-%dT%H:%M:%S'), "+00:00")
  
  device.info.1hr  <- read.csv(file.monitor.1hr, skip = 0, header = TRUE, stringsAsFactors = FALSE)
  if (length(device.info.1hr$timestamp) == 0) {
    device.info.1hr[1,] <- list(timestampUTC,                         #1
                                pending.jobs,                         #2
                                operational,                          #3
                                status_msg,                           #4
                                meas_freq_est,                        #5
                                qubit_freq_est,                       #6
                                last_update_date)                     #7
  } else {
    device.info.1hr <- rbind(device.info.1hr, list(timestampUTC,      #1
                                                   pending.jobs,      #2
                                                   operational,       #3
                                                   status_msg,        #4
                                                   meas_freq_est,     #5
                                                   qubit_freq_est,    #6
                                                   last_update_date)) #7
  }
  write.csv(device.info.1hr, file = file.monitor.1hr, row.names = FALSE, quote = FALSE)
  
  
  backend.calibration <- backend_calibration_full(backend)
  qubits <- backend.calibration[[1]]
  gates  <- backend.calibration[[2]]
  
  # qubits ----------------------------------------------------------------------------------------
  for (qub in 1:length(qubits)) {
    qubit.name     <- paste0("Q", qub - 1)
    qubit.filename <- paste0(dir, "backends/", backend.name, "/qubits/", qubit.name, ".csv")
    matrix.qubit   <- matrix(unlist(qubits[[qub]]), nrow = length(qubits[[qub]]), byrow = TRUE)
    colnames(matrix.qubit) <- names(qubits[[qub]][[1]])
#    if (backend.name == "ibmq_armonk") {
#      print(paste0(backend.name, "_", qubit.name))
#      print(qubits[[qub]])
#      print(matrix.qubit)
#      write.csv(matrix.qubit, file = paste0(dirname(qubit.filename), "/", qubit.name, "_", "matrix_qubit_", timestamp.file, ".csv"))
#    }
    file_exists(qubit.filename, c("timestamp", as.vector(matrix.qubit[, which(colnames(matrix.qubit) == "name")]),
                                        paste0(as.vector(matrix.qubit[, which(colnames(matrix.qubit) == "name")]), ".date")))
    df.qubit       <- read.csv(qubit.filename, skip = 0, header = TRUE, stringsAsFactors = FALSE)
    new.data       <- unlist(list(timestampUTC, matrix.qubit[, which(colnames(matrix.qubit) == "value")],
                                                matrix.qubit[, which(colnames(matrix.qubit) == "date")]))
    # only rewrite if entries exist and at least one parameter is different ----
    if ((nrow(df.qubit) == 0) || ((nrow(df.qubit) > 0) && !all(df.qubit[nrow(df.qubit), 2:ncol(df.qubit)] == new.data[2:length(new.data)]))) {
      df.qubit[nrow(df.qubit) + 1, ] <- new.data
      write.csv(df.qubit, file = qubit.filename, row.names = FALSE, quote = FALSE)
    }
  }
  
  # gates -----------------------------------------------------------------------------------------
  for (gate in 1:length(gates)) {
    gate.name     <- gates[[gate]]$name
    gate.filename <- paste0(dir, "/backends/", backend.name, "/gates/", gate.name, ".csv")
    file_exists(gate.filename, c("timestamp", gates[[gate]]$parameters[[1]]$name, gates[[gate]]$parameters[[2]]$name,
                                  paste0(gates[[gate]]$parameters[[1]]$name, ".date"), paste0(gates[[gate]]$parameters[[2]]$name, ".date")))
    #df.qubit       <- data.frame(matrix(ncol = 1 + 2*length(qubits[[qub]]), nrow = 0))
    df.gate       <- read.csv(gate.filename, skip = 0, header = TRUE, stringsAsFactors = FALSE)
    new.data      <- c(timestampUTC, gates[[gate]]$parameters[[1]]$value, gates[[gate]]$parameters[[2]]$value,
                                     gates[[gate]]$parameters[[1]]$date,  gates[[gate]]$parameters[[2]]$date)
    # only rewrite if entries exist and at least one parameter is different ----
    if ((nrow(df.gate) == 0) || ((nrow(df.gate) > 0) && !all(df.gate[nrow(df.gate), 2:ncol(df.gate)] == new.data[2:length(new.data)]))) {
      df.gate[nrow(df.gate) + 1, ] <- new.data
      write.csv(df.gate, file = gate.filename, row.names = FALSE, quote = FALSE)
    }
  }
}

####
gc()
