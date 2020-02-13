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
                          sidebarPanel(
                            fluidRow(
                              column(12, align = "center",
                                     #verbatimTextOutput('provider'),
                                     htmlOutput("device.backend.title"),
                                     verbatimTextOutput("device.backend"),
                                     htmlOutput("device.dt.title"),
                                     verbatimTextOutput("device.dt"),
                                     htmlOutput("device.freq.title"),
                                     verbatimTextOutput("device.freq")
                                     )
                              )
                            )
                          ),
                 mainPanel(
                   h1(""),
                   htmlOutput("usercount"),
                   highchartOutput("infoplot", height = 400) #width = "100%", 
                   )
                 )
      )
    )
  )
