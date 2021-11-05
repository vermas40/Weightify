register_ui <- function(id){
  ns <- NS(id)
  tagList(
    shinydashboard::box(id='reg_box',
                        width = 4,
                        title = 'Get Started',
          fluidRow(shinyjs::useShinyjs(),
                  div(   class='reg_form_control',
                         textInput(ns('user_name'),
                                   h5('Choose a username:',
                                      style='display: inline-block;
                                             max-width: 100%;
                                             margin-bottom: 5px;
                                             font-weight: bold;
                                             color:white;')),
                         style='padding-left:45px; padding-top:90px;'
                        ),
                  ),
          fluidRow(
                 div(
                       actionButton(ns('user_btn'),
                                  'Check Availability',
                                  style='width:350px; border-width:2px;
                                         height:45px;color: #ffffff;
                                         background-color: #375a7f;
                                         border-color: #375a7f;'),
                       style='padding-left:45px;'
                        )
                  ), #close fluidRow
          fluidRow(
                div(
                  class='empty_div'
                )
          ),
          fluidRow(
                  div(   class='reg_form_control',
                         passwordInput(ns('pass'), 
                                       h5('Choose Password:',
                                          style='display: inline-block;
                                             max-width: 100%;
                                             margin-bottom: 5px;
                                             font-weight: bold;
                                             color:white;')),
                         style='padding-left:45px;
                                padding-top:30px'
                      )#close column
                  ),#close fluidRow
          fluidRow(
                  div(   class='reg_form_control',
                         passwordInput(ns('confirm_pass'), 
                                       h5('Confirm Password:',
                                          style='display: inline-block;
                                             max-width: 100%;
                                             margin-bottom: 5px;
                                             font-weight: bold;
                                             color:white;')),
                         style='padding-left:45px;'
                        ),#close column
                  div(
                        actionButton(ns('acct_btn'),
                                     'Create Account',
                                     style='width:350px; border-width:2px;
                                            height:45px;color: #ffffff;
                                            background-color: #375a7f;
                                            border-color: #375a7f;'),
                      style='padding-left:45px;'
                         )
                  ), #close fluidRow
          fluidRow(
                   div(
                          actionButton(ns('back_btn'), 
                                       'Back to login',
                                       style='width:350px; border-width:2px;
                                              height:45px;color: #ffffff;
                                              background-color: #375a7f;
                                              border-color: #375a7f;',
                                       onclick ="window.open('http://google.com', '_blank')"
                                      ), #close actionButton
                          style='padding-left:45px; padding-top:10px; 
                                 padding-bottom:15px;'
                          ) #close columns
                  ) #close fluidRow
                      )# shinydashboard box
  ) #close tagList
}

register_server <- function(input, output, session){
  shinyjs::disable('pass')
  shinyjs::disable('confirm_pass')
  shinyjs::disable('acct_btn')
  
  #checking if the user name exists in the database or not
  observeEvent(input$user_btn,{
    #if the user name is taken then keep password disabled
    #browser()
    users_df <- get_app_users('weightloss.db')
    if (input$user_name %in% users_df[['user']]){
      showNotification('This username already exists',
                       type='error')
      #disabling if they tried to create an account and that
      #user name was already taken there
      shinyjs::disable('pass')
      shinyjs::disable('confirm_pass')
      shinyjs::disable('acct_btn')
      
    }else if (input$user_name == ''){
      showNotification('Please enter a username!',
                       type='error')
      #disabling if they tried to create an account and that
      #user name was already taken there
      shinyjs::disable('pass')
      shinyjs::disable('confirm_pass')
      shinyjs::disable('acct_btn')      
    }else{
      #if user name is not taken then enable password entering
      showNotification('This username is available',
                       type='message')
      shinyjs::enable('pass')
      shinyjs::enable('confirm_pass')
      shinyjs::enable('acct_btn')
      
         }
    }
    )
  
  observeEvent(input$acct_btn,{
    #allowing the user to create an account
    users_df <- get_app_users('weightloss.db')
    if ((input$pass == '') & (input$confirm_pass == '')){
      #if the user does not enter a password and tries to make a password
      #less account
      showNotification('Please enter a password!',
                       type='error')     
    }else if ((input$pass == input$confirm_pass) & 
        !(input$user_name %in% users_df[['user']])){
      #if the user tries to change username after entering password
      #then that will be signaled as an error
      create_acct('weightloss.db',input$user_name, input$pass)
      showNotification('Account created!',
                       type='message')
    }else{
      showNotification('Check username or password!',
                       type='error')
    }
                              }#close observeEvent
              )#close observeEvent
  }

  
  