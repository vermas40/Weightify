library(shiny)

ui <- navbarPage(title=div(img(src='scale.png', style='margin-top:-14px;', height=45)),
                 header='', id='main_navbar', windowTitle='My Weight Loss Pal',
                 theme='bootstrap.css',
                 tabPanel('Track'),
                 tabPanel('History')
                 )
server <- function(input,output,session){
  
}

shinyApp(ui = ui, server = server)