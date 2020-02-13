users = reactiveValues(count = 0)

GHz <- 1.0e9
MHz <- 1.0e6

valueBox <- function(value, subtitle, icon, color) {
  div(class = "col-lg-11 col-md-11",
      div(class = "panel panel-primary",
          div(class = "panel-heading", style = paste0("background-color:", color),
              div(class = "row",
                  div(class = "col-xs-2",
                      icon(icon, "fa-4x")
                  ),
                  div(class = ("col-xs-9 text-right"),
                      div(style = ("font-size: 32px; font-weight: bold;"),
                          textOutput(value)
                      ),
                      div(style = ("font-size: 16px;"),
                          subtitle
                      ),
                      div(style = ("font-size: 16px;"),
                          subtitle
                      ),
                      div(style = ("font-size: 16px;"),
                          subtitle
                      )
                  )
              )
          ),
          div(class = "clearfix")
      )
  )
}

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
    df.backend[i, ]  <- list(backend.name, n.qubits)
  }
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
  
  
  updateSelectizeInput(session, "backend",
                       choices = backend.list,
                       selected =  c("ibmq_armonk")
  )
  output$ui.sidebar1 <- renderUI({
    })
    
  output$ui.sidebar2 <- renderUI({
    fluidRow(
      br(),
      column(6, align = "center",
             htmlOutput("backend.status")
      ),
      column(6, align = "center",
             htmlOutput("backend.jobs")
      ))
    })
  
  output$ui.sidebar2.5 <- renderUI({
    fluidRow(
      column(6, align = "center",
        valueBox(value = "status",
                 subtitle = "Backend status",
                 icon = "tachometer",
                 color = "green")
      ),
      column(6, align = "center",
             valueBox(value = "n.jobs",
                      subtitle = "Queue length",
                      icon = "tachometer",
                      color = "green")
      )
    )
  })
  output$ui.sidebar3 <- renderUI({
    fluidRow(
      br(),
      column(6, align = "center",
             htmlOutput("current.time.title"),
             verbatimTextOutput("current.time")
      ),
      column(6, align = "center",
             htmlOutput("qiskit.version.title"),
             verbatimTextOutput("qiskit.version")
      ),
      br(),
      column(12, align = "center",
             actionButton("refresh", "Refresh")
      ))
    })
  output$ui.highplot <- renderUI({
    highchartOutput("infoplot", height = 400) #width = "100%", 
    })
  

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
  output$n.qubits.title       <- renderText({paste0("<b>Qubits:</b>")})
  output$n.qubits             <- renderText({paste0(backend.qubits())})
  output$backend.status       <- renderText({paste0("<b>Backend status: <font color=", ifelse(backend.status() == "active", "green", "red"), ">", backend.status(), "</font> </b>")})
  output$backend.jobs         <- renderText({paste0("<b>Queue: <font color=", ifelse(backend.jobs() < 10, "green", "red"), ">", backend.jobs(), ifelse(backend.jobs() == 1, " job", " jobs"), "</b>")})
  output$current.time.title   <- renderText({paste0("<b>Current time (UTC):</b>")})
  output$current.time         <- renderText({paste0(as.character(time.now))})
  output$device.backend.title <- renderText({paste0("<b>Backend:</b>")})
  output$device.backend       <- renderText({paste0(backend())})
  #output$backend.status.title <- renderText({paste0("<b>Status:</b>")})
  
  output$qiskit.version.title <- renderText({paste0("<b>", "Qiskit version:", "</b>")})
  output$qiskit.version       <- renderText({paste0(qiskit_version())})
  output$usercount            <- reactive({paste0(users$count, " active session(s)")})
  
  file.monitor.10min <- reactive(paste0(dir, 'backends/', backend(), "/", backend(), "_10min.csv"))
  file.monitor.1hr   <- reactive(paste0(dir, 'backends/', backend(), "/", backend(), "_1hr.csv"))
  device.info.10min  <- reactive(read.csv(file.monitor.10min(), skip = 0, header = TRUE, stringsAsFactors = FALSE))
  device.info.1hr    <- reactive(read.csv(file.monitor.1hr(),   skip = 0, header = TRUE, stringsAsFactors = FALSE))
  
  output$qubits <- renderText({paste0(backend.qubits(), ifelse(backend.qubits() == 1, " qubit", " qubits"))})
  output$n.jobs <- renderText({backend.jobs()})
  output$status <- renderText({backend.status()})
  
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
