library(shiny)
library(shinythemes)

#background color of navbar is 375A7F
ui <- shinyauthr::loginUI('login')

server <- function(input, output, session){
  
}

shinyApp(ui, server)