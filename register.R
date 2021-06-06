library(shiny)
library(shinythemes)
library(DBI)
library(RSQLite)

source('register_app/register_ui.R')
source('helper_functions.R')
options(shiny.port = 8000)
register <- navbarPage(title=div(img(src='body-scale.png', style='margin-top:-14px;', 
                                          height=45)),
                            header='', id='main_navbar', windowTitle='My Weight Loss Pal',
                            theme=shinytheme('darkly'),
                            tabPanel('Register', register_ui('reg')),
                            includeCSS('www/bootstrap.css') #including custom css to overwrite darkly theme
                )
server <- function(input,output,session){
  user_data <- get_data('weightloss.db')
  callModule(register_server, 'reg', user_data)
}
shinyApp(register, server)