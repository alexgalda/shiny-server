users = reactiveValues(count = 0)

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
  
  reticulate::source_python('python_functions.py')
  output$message <- renderText({
    return(test_string_function(input$str))
  })
  
  output$backend   <- renderText("ibmq_armonk2")
  output$usercount <- reactive({paste0(users$count, " active session(s)")})
}