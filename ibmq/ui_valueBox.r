

valueBoxSmall <- function(value, icon, color) {
  div(class = "col-lg-12 col-md-12",
      div(class = "panel panel-primary",
          div(class = "panel-heading", style = paste0("background-color:", color),
              div(class = "row",
                  div(class = "col-xs-2",
                      icon(icon, "fa-2x")
                  ),
                  div(class = ("col-xs-9 text-right"),
                      #div(style = ("font-size: 20px; font-weight: bold;"),
                      #    textOutput(value)
                      #),
                      div(style = ("font-size: 16px;"),
                          value
                      )
                  )
              )
          ),
          div(class = "clearfix")
      )
  )
}

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
                          sidebarPanel(
                            fluidRow(
                              column(12, align = "center",
                                     selectizeInput(inputId = "backend",
                                                    label = "Select backend:",
                                                    choices =  c("ibmq_armonk")#,
                                                    #options = list(
                                                    #  placeholder = 'Loading available backends',
                                                    #  onInitialize = I('function() { this.setValue(""); }')
                                                    #)
                                     )
                              )#,
                              #column(4, align = "center",
                              #       valueBoxSmall(value = "qubits",
                              #                 icon = "tachometer",
                              #                 color = "red")
                                     #htmlOutput("n.qubits.title"),
                                     #verbatimTextOutput("n.qubits")
                              #)
                              ),
                            uiOutput('ui.sidebar2.5'),
                            uiOutput('ui.sidebar3')
                            )
                          ),
                 mainPanel(
                   h1(""),
                   htmlOutput("usercount"),
                   uiOutput('ui.highplot')
                   )
                 )
      )
    )
  )
