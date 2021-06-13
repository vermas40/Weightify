pass_change_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(shinyjs::useShinyjs(),
      column(width = 4, offset = 0,
             column(width = 9, offset = 0,
                    passwordInput(ns('pass'), 'Choose New Password')
             )#close column
      )#close column
    ),#close fluidRow
    fluidRow(
      column(width = 4, offset = 0,
             column(width = 9, offset = 0,
                    passwordInput(ns('confirm_pass'), 'Repeat Password')
             ),#close column
             column(width = 3, offset = 0,
                    actionButton(ns('password_btn'),
                                 'Change Password',
                                 #line-height is to vertically align 
                                 #the text inside the button to be in 
                                 #the middle of the shrunken button
                                 style='height:34px; line-height:0px;
                                                    width:145px;'
                    ),
                    style='margin-top:26px;'
                    )
          )#close column
    )#close fluidRow
  ) #close tagList
}

pass_server <- function(input, output, session, user){
  observeEvent(input$password_btn,{
    if ((input$pass == input$confirm_pass) & (input$confirm_pass != '')){
      change_pwd('weightloss.db', user, input$confirm_pass)
      showNotification('Password changed successfully!',
                       type='message')
      
      showNotification('Taking you back to login screen',
                       type='default')
      Sys.sleep(3)
      session$reload()
    }else{
      showNotification('Entered password does not meet requirements!',
                       type='error')
    }
  })
}