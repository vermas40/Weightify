library(shiny)
library(shinythemes)

source('register_app/register.R')
options(shiny.port = 8000)
register_ui <- navbarPage(title=div(img(src='body-scale.png', style='margin-top:-14px;', 
                                          height=45)),
                            header='', id='main_navbar', windowTitle='My Weight Loss Pal',
                            theme=shinytheme('darkly'),
                            tabPanel('Register', register('reg')),
                            includeCSS('www/bootstrap.css') #including custom css to overwrite darkly theme
                )
server <- function(input,output,session){
  
}
shinyApp(register_ui, server)