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
                                     textOutput("backend")
                                     )
                              )
                            )
                          ),
                 mainPanel(
                   h1(""),
                   htmlOutput("usercount")
                 )
                 )
      )
    )
  )
