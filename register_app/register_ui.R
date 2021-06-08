register_ui <- function(id){
  ns <- NS(id)
  tagList(
          fluidRow(shinyjs::useShinyjs(),
                  column(width = 4, offset = 0,
                         column(width = 9, offset = 0,
                               textInput(ns('user_name'),
                                         'Choose a username'
                                         )
                               ), #close textInput
                         column(width = 3, offset = 0,
                               actionButton(ns('user_btn'),
                                          'Check Availability',
                                          #line-height is to vertically align 
                                          #the text inside the button to be in 
                                          #the middle of the shrunken button
                                          style='height:34px; line-height:0px;
                                                 width:145px;'
                                           ),
                               style='margin-top:26px;'
                                )
                         )#close column 
                  ), #close fluidRow
          fluidRow(
                  column(width = 4, offset = 0,
                         column(width = 9, offset = 0,
                                passwordInput(ns('pass'), 'Choose Password')
                               )#close column
                        )#close column
                  ),#close fluidRow
          fluidRow(
                  column(width = 4, offset = 0,
                         column(width = 9, offset = 0,
                                passwordInput(ns('confirm_pass'), 'Confirm Password')
                                ),#close column
                         column(width = 3, offset = 0,
                                actionButton(ns('acct_btn'),
                                             'Create Account',
                                             #line-height is to vertically align 
                                             #the text inside the button to be in 
                                             #the middle of the shrunken button
                                             style='height:34px; line-height:0px;
                                                    width:145px;'
                                ),
                                style='margin-top:26px;'
                         )
                        )#close column
                  )
         ) #close tagList
}

register_server <- function(input, output, session){
  shinyjs::disable('pass')
  shinyjs::disable('confirm_pass')
  shinyjs::disable('acct_btn')
  
  #checking if the user name exists in the database or not
  observeEvent(input$user_btn,{
    #if the user name is taken then keep password disabled
    users_df <- get_app_users('weightloss.db')
    if (input$user_name %in% users_df[['user_name']]){
      showNotification('This username already exists',
                       type='error')
      #disabling if they tried to create another account and that
      #user name was not there
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
    users_df <<- get_app_users('weightloss.db')
    if ((input$pass == input$confirm_pass) & 
        !(input$user_name %in% users_df[['user_name']])){
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

  
  