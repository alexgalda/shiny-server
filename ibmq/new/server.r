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
  
  withProgress(message = 'Connecting to IBMQ', value = 1, {
    reticulate::source_python(paste0(dir, "ibmq_functions.py"))
    provider           <- get_provider()
    backends.available <- get_unique_backends()
  })
  
  df.backend         <- data.frame(backend = character(length(backends.available)), n.qubits = numeric(length(backends.available)), stringsAsFactors = FALSE)
  list.qubits        <- c()
  for (i in 1:length(backends.available)) {
    backend.name     <- backends.available[[i]]
    backend          <- get_backend(provider, backend.name)
    n.qubits         <- device_n_qubits(backend)
    list.qubits      <- append(n.qubits, list.qubits)
    #qubits           <- ifelse(n.qubits == 1, paste0("1 qubit"), paste0(n.qubits, " qubits"))
    df.backend[i, ]  <- list(backend.name, n.qubits)
  }
  #df.backend[9, ] <- c("ibmq_armonk2", "1 qubit")
  split_tibble <- function(tibble, column = 'col') {
    tibble %>% split(., .[,column]) %>% lapply(., function(x) x[,setdiff(names(x),column)])
  }
  df.list <- split_tibble(df.backend, 'n.qubits')
  
  backend.list <- vector("list", length(df.list))
  for (i in 1:length(df.list)) {
    backend.list[[order(list.qubits)[i]]] <- as.vector(df.list[[i]])
    names(backend.list[[order(list.qubits)[i]]]) <- as.vector(df.list[[i]])
  }
  names(backend.list) <- paste0(names(df.list), " qubits")
  names(backend.list)[which(list.qubits == 1)] <- "1 qubit"
  #new.backend.list <- backend.list[names(backend.list)[order(c(1, 15, 5))]]
  
  updateSelectizeInput(session, "backend",
                       choices = backend.list,
                       selected =  c("ibmq_armonk")
  )

  backend          <- reactive(get_backend(provider, input$backend))
#  backend.name     <- backend
  backend.config   <- reactive(backend_config(backend()))
  backend.defaults <- reactive(backend_defaults(backend()))
  backend.status   <- reactive(backend_status_msg(backend()))
  backend.jobs     <- reactive(pending_jobs(backend()))
  backend.qubits   <- reactive(device_n_qubits(backend()))
  
  # We will work with the following qubit.
  #output$provider       <- renderText({paste0("provider: ", provider)})
  time.now                    <- Sys.time()
  attributes(time.now)$tzone  <- "UTC"
  output$n.qubits             <- renderText({paste0("<b>Qubits: ", backend.qubits(), "</b>")})
  output$backend.status       <- renderText({paste0("<b>Backend status: <font color=", ifelse(backend.status() == "active", "green", "red"), ">", backend.status(), "</font> </b>")})
  output$backend.jobs         <- renderText({paste0("<b>Queue: <font color=", ifelse(backend.jobs() < 10, "green", "red"), ">", backend.jobs(), ifelse(backend.jobs() == 1, " job", " jobs"), "</b>")})
  output$current.time.title   <- renderText({paste0("<b>Current time (UTC):</b>")})
  output$current.time         <- renderText({paste0(as.character(time.now))})
  output$device.backend.title <- renderText({paste0("<b>Backend:</b>")})
  output$device.backend       <- renderText({paste0(backend())})
  output$backend.status.title <- renderText({paste0("<b>Status:</b>")})
  
  output$qiskit.version.title <- renderText({paste0("<b>", "Qiskit version:", "</b>")})
  output$qiskit.version       <- renderText({paste0(qiskit_version())})
  output$usercount            <- reactive({paste0(users$count, " active session(s)")})
  
  output$ui.refresh <- renderUI({
    fluidRow(
      output$gate.map <- renderImage({
        device_gate_map(backend())
        list(src = 'backend.png')
      }),
      column(12, align = "center",
             actionButton("refresh", "Refresh")
      )
    )
  })
  
  file.monitor.10min <- reactive(paste0(dir, 'backends/', backend(), "/", backend(), "_10min.csv"))
  file.monitor.1hr   <- reactive(paste0(dir, 'backends/', backend(), "/", backend(), "_1hr.csv"))
  device.info.10min  <- reactive(read.csv(file.monitor.10min(), skip = 0, header = TRUE, stringsAsFactors = FALSE))
  device.info.1hr    <- reactive(read.csv(file.monitor.1hr(),   skip = 0, header = TRUE, stringsAsFactors = FALSE))
  
  
  observeEvent(input$refresh, {
    withProgress(message = 'Refreshing', value = 1, {
      time.now                    <- Sys.time()
      attributes(time.now)$tzone  <- "UTC"
      backend.status              <- reactive(backend_status_msg(backend()))
      backend.jobs                <- reactive(pending_jobs(backend()))
      output$backend.status       <- renderText({paste0("<b>Backend status: <font color=", ifelse(backend.status() == "active", "green", "red"), ">", backend.status(), "</font> </b>")})
      output$backend.jobs         <- renderText({paste0("<b>Queue: <font color=", ifelse(backend.jobs() < 10, "green", "red"), ">", backend.jobs(), ifelse(backend.jobs() == 1, " job", " jobs"), "</b>")})
      output$current.time         <- renderText({paste0(as.character(time.now))})
      output$usercount            <- reactive({paste0(users$count, " active session(s)")})
      
      file.monitor.10min <- reactive(paste0(dir, 'backends/', backend(), "/", backend(), "_10min.csv"))
      file.monitor.1hr   <- reactive(paste0(dir, 'backends/', backend(), "/", backend(), "_1hr.csv"))
      device.info.10min  <- reactive(read.csv(file.monitor.10min(), skip = 0, header = TRUE, stringsAsFactors = FALSE))
      device.info.1hr    <- reactive(read.csv(file.monitor.1hr(),   skip = 0, header = TRUE, stringsAsFactors = FALSE))
      #output$infoplot    <- renderHighchart(highstock(device.info.10min()))
    }
    )
  })
  
  output$infoplot <- renderHighchart(highstock(device.info.10min()))
}
