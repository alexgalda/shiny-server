# checks if file exists (and 3 directories up) and creates a CSV file with given columns if not
# file <- "C:\\Users\\agalda\\Google Drive\\quantumgate.xyz\\shiny-server\\ibmq\\ibmq_armonk\\qubits\\Q0.csv"
# file <- paste0(dir, backend.name, "/gates/", gate.name, ".csv")
# columns <- c()
# columns <- c("timestamp", gates[[gate]]$parameters[[1]]$name, gates[[gate]]$parameters[[2]]$name, paste0(gates[[gate]]$parameters[[1]]$name, ".date"), paste0(gates[[gate]]$parameters[[2]]$name, ".date"))
# c("timestamp", "pending_jobs")

file_exists <- function(file, columns) {
  if (!dir.exists(dirname(dirname(dirname(file))))) {
    dir.create(dirname(dirname(file)))
    dir.create(dirname(file))
  } else if (!dir.exists(dirname(dirname(file)))) {
    dir.create(dirname(dirname(file)))
    dir.create(dirname(file))
  } else if (!dir.exists(dirname(file))) {
    dir.create(dirname(file))
  }
  if (!file.exists(file)) {
    df <- data.frame(matrix(ncol = length(columns), nrow = 0))
    colnames(df) <- columns
    write.csv(df, file = file, row.names = FALSE, quote = FALSE)
  }
}
