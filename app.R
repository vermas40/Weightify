library(shiny)
library(shinythemes)

ui <- navbarPage(title=div(img(src='body-scale.png', style='margin-top:-14px;', height=45)),
                 header='', id='main_navbar', windowTitle='My Weight Loss Pal',
                 theme=shinytheme('darkly'),
                 tabPanel('Track'),
                 tabPanel('History'),
                 tabPanel('Profile'),
                 includeCSS('www/bootstrap.css') #including custom css to overwrite darkly theme
                 
)

server <- function(input,output,session){
  
}

shinyApp(ui = ui, server = server)