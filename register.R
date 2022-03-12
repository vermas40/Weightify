library(shiny)
library(shinythemes)
library(shinydashboard)
library(DBI)
library(RSQLite)
library(scrypt)

source('register_app/register_ui.R')
source('functions/helper_functions.R')
options(shiny.port = 7890)
options(shiny.host = "0.0.0.0")
#just by giving an id argument, one can give an id to an entire page in rshiny
register <- fluidPage(register_ui('reg'), 
                      includeCSS('/app/www/bootstrap.css'), id='reg_page')

server <- function(input,output,session){
  callModule(register_server, 'reg')
}
shinyApp(register, server)