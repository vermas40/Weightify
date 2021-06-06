register_ui <- function(id){
  ns <- NS(id)
  tagList(
          fluidRow(shinyjs::useShinyjs(),
                  column(width = 4, offset = 0,
                         column(width = 9, offset = 0,
                               textInput(ns('text_input'),
                                         'Choose a username'
                                         )
                               ), #close textInput
                         column(width = 3, offset = 0,
                               actionButton(ns('action'),
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
                                actionButton(ns('action'),
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

register_server <- function(input, output, session, users_df){
  shinyjs::disable('pass')
  shinyjs::disable('confirm_pass')
  #checking if the user name exists in the database or not
  observeEvent(input$action,{
    if (input$text_input %in% users_df[['user_name']]){
      showNotification('This username already exists',
                       type='error')
      shinyjs::disable('pass')
      shinyjs::disable('confirm_pass')
    }else{
      showNotification('This username is available',
                       type='message')
      shinyjs::enable('pass')
         }
    }
    )
}