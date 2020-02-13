ui <- fluidPage(
  useShinyjs(),     # Set up shinyjs
  useShinyalert(),  # Set up shinyalert
  div(
    id = "loading_page",
    h1("Loading...")
  ),
  hidden(
    div(
      id = "main_content",
      navbarPage(id = "app",
                 tags$style(type = 'text/css', '#usercount  {color: #ffffff;}'),
                 windowTitle = "IBMQ",
                 collapsible = T,
                 tabPanel("IBMQ", value = "ibmq",
                          tags$style(type = 'text/css', '#refresh {background-color:lightblue; color: black;}'),
                          #tags$style(type = 'text/css', '#gate.map {max-width: 100%; max-height: 200px; width: auto; height: auto}'),
                          tags$head(tags$style(type = 'text/css', '#gate.map {width: 100%}')),
                          sidebarPanel(
                            fluidRow(
                              column(12, align = "center",
                                     selectizeInput(inputId = "backend",
                                                    label = "Select available backend:",
                                                    choices =  c("ibmq_armonk")#,
                                                    #options = list(
                                                    #  placeholder = 'Loading available backends',
                                                    #  onInitialize = I('function() { this.setValue(""); }')
                                                    #)
                                                    )
                                     )
                              ),
                            fluidRow(
                              column(4, align = "center",
                                     htmlOutput("n.qubits")
                              ),
                              column(4, align = "center",
                                     htmlOutput("backend.status")
                              ),
                              column(4, align = "center",
                                     htmlOutput("backend.jobs")
                              )),
                            br(),
                            uiOutput('ui.map'),
                            fluidRow(
                              column(6, align = "center",
                                     htmlOutput("current.time.title"),
                                     verbatimTextOutput("current.time")
                              ),
                              column(6, align = "center",
                                     htmlOutput("qiskit.version.title"),
                                     verbatimTextOutput("qiskit.version")
                              )
                            ),
                            uiOutput('ui.refresh')
                          )
                          ),
                 mainPanel(
                   tabsetPanel(
                     tabPanel("Queue history",
                       h1(""),
                       htmlOutput("usercount"),
                       highchartOutput("infoplot", height = 400) #width = "100%",
                     ),
                     tabPanel("Qubits",
                              h1("")
                     ),
                     tabPanel("Gates",
                              h1("")
                     )
                   )
                 ))
      )
    )
  )
