library(shiny)
library(shinythemes)
library(shinymanager)
library(scrypt)

source('track_ui.R')
source('goal_ui.R')
#background color of navbar is 375A7F
ui <- secure_app(
                 navbarPage(title=div(img(src='body-scale.png', style='margin-top:-14px;', 
                                          height=45)),
                           header='', id='main_navbar', windowTitle='My Weight Loss Pal',
                           theme=shinytheme('darkly'),
                           tabPanel('Track', track_ui('track')),
                           tabPanel('Performance'),
                           tabPanel('Log Out'),
                           tabPanel('Profile'),
                           includeCSS('www/bootstrap.css') #including custom css to overwrite darkly theme
                           
                            ), theme = shinytheme('darkly'), #using darkly theme for login dialog box
                   #making background black for the rest of the page
                   background = "linear-gradient(rgba(48, 48, 48, 1),
                                  rgba(48, 48, 48, 1));",
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
  #giving a warning if the credentials are incorrect
  output$res_auth <- renderPrint({
    reactiveValuesToList(result_auth)
  })
  # 
  callModule(goal_server, 'goal')
}

shinyApp(ui = ui, server = server)

