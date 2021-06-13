library(shiny)
library(shinythemes)
library(shinymanager)
library(shinyjs)
library(scrypt)
library(DBI)
library(RSQLite)
library(docstring)
library(lubridate)
library(tidyr)

source('track_ui.R')
source('goal_ui.R')
source('helper_functions.R')
source('pass_change_ui.R')
#background color of navbar is 375A7F

set_labels(
  language = 'en',
  'Please authenticate' = 'You\'re one step away'
)
ui <- secure_app(
                 navbarPage(title=div(img(src='body-scale.png', style='margin-top:-14px;', 
                                          height=45)),
                           header='', id='main_navbar', windowTitle='My Weight Loss Pal',
                           theme=shinytheme('darkly'),
                           tabPanel('Track', track_ui('track')),
                           tabPanel('Performance'),
                           tabPanel('Change Password',pass_change_ui('pass')),
                           includeCSS('www/bootstrap.css') #including custom css to overwrite darkly theme
                           
                            ), theme = shinytheme('darkly'), #using darkly theme for login dialog box
                   #making background black gradient for the rest of the page
                   #and adding a background
                   background = "linear-gradient(rgba(48, 48, 48, 0.5),
                                  rgba(48, 48, 48, 0.5)),
                                  url('back.jpeg');",
                   tags_bottom = tags$div(
                     tags$p(
                       "New User? ",
                       tags$a(
                         href = "//127.0.0.1:8000", #linking to the registration app
                         target="_blank", "Create an account"
                             )
                           )
                                       ) #close tags_bottom
                 )#close secure_app

server <- function(input,output,session){
  #pulling the app users data
  user_data <- get_app_users('weightloss.db')
  #checking credentials if they are correct
  result_auth <- secure_server(check_credentials = check_credentials(user_data))

  #if user changes tab to change password tab then run the below code
  observeEvent(input$main_navbar,{
    user <- reactiveValuesToList(result_auth)[['user']]
    if (input$main_navbar == 'Change Password'){
      callModule(pass_server, 'pass', user)
    }else if (input$main_navbar == 'Track'){
      callModule(goal_server, 'goal', user)
    }
  })
}

shinyApp(ui = ui, server = server)

