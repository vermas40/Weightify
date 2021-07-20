goal_ui <- function(id){
  ns <- NS(id)
  fluidPage(
           shinyjs::useShinyjs(),
           fluidRow(
                  tagList(
                          column(width = 4, offset = 0,
                                 dateInput(ns("date"), "Select starting date", 
                                           value = NULL)
                                 )
                         )
                   ),
           fluidRow(
                 tagList(
                         column(width = 4, offset = 0,
                                selectInput(ns('wt_unit'),
                                            h5('Select weight unit'),
                                            choices = c('',
                                                        'Kg'='kg',
                                                        'Lbs'='lbs'))
                               ),
                         column(width = 4, offset = 0,
                                selectInput(ns('cal_unit'),
                                            h5('Select calorie unit'),
                                            choices = c('',
                                                        'Cal.'='cal',
                                                        'Kj'='kj'))
                                )
                        )
                   ),
           fluidRow(
                   tagList(
                         column(width = 4, offset = 0,
                                numericInput(ns('curr_wt'),
                                            h5('Enter current weight'),
                                            value=NULL,
                                            min = 0
                                            )
                               ), #close column
                         column(width = 4, offset = 0,
                                numericInput(ns('goal_wt'),
                                            h5('Enter goal weight'),
                                            value=NULL,
                                            min = 0
                                            )
                               ), #close column
                         column(width = 4, offset = 0,
                                numericInput(ns('loss_slope'),
                                            h5('Enter goal weight loss/gain per week'),
                                            value=NULL,
                                            min = 0
                                            )
                               )#close column
                          )#close tagList
                  ), #close fluidRow
           fluidRow(
                  tagList(
                          column(width = 4, offset = 4,
                                 actionButton(ns('confirm_goal'),'Submit')
                                ) #close column
                          ), #close tagList
                  style='padding-top:10px;'
                    ), #close fluidRow
           fluidRow(
                  tagList(
                    column(width=8, offset = 1,
                           uiOutput(ns('tdee_display'))
                          ) #close column
                         ), #close tagList
                    style='padding-top:10px;')
           )
}

goal_server <- function(input, output, session, user){
  shinyjs::disable('wt_unit')
  shinyjs::disable('cal_unit')
  shinyjs::disable('curr_wt')
  shinyjs::disable('goal_wt')
  shinyjs::disable('loss_slope')
  
  #prepopulating the fields with user goals the second time they log in
  user_goals <- get_user_goals('weightloss.db')
  if (user %in% user_goals[['user']]){
    user_goals <- user_goals[which(user_goals['user'] == user),]
    user_goals <- spread(user_goals, metric, value)
    updateDateInput(session, 'date', value = user_goals[['start_date']])
    updateSelectInput(session, 'wt_unit', selected = user_goals[['wt_unit']])
    updateSelectInput(session, 'cal_unit', selected = user_goals[['cal_unit']])
    updateNumericInput(session, 'curr_wt', value = user_goals[['curr_wt']])
    updateNumericInput(session, 'goal_wt', value = user_goals[['goal_wt']])
    updateNumericInput(session, 'loss_slope', value = user_goals[['loss_slope']])
  }
  #enable wt and cal unit selection once date is selected
  observeEvent(input$date,{
    shinyjs::enable('wt_unit')
    shinyjs::enable('cal_unit')
  })
  
  #if weight and cal units are filled then what to do
  observeEvent(input$wt_unit,{
    if ((input$wt_unit != '') & (input$cal_unit != '')){
      shinyjs::enable('curr_wt')
      shinyjs::enable('goal_wt')
      shinyjs::enable('loss_slope')
    }else{
      shinyjs::disable('curr_wt')
      shinyjs::disable('goal_wt')
      shinyjs::disable('loss_slope')
    }
  })
  
  observeEvent(input$cal_unit,{
    if ((input$wt_unit != '') & (input$cal_unit != '')){
      shinyjs::enable('curr_wt')
      shinyjs::enable('goal_wt')
      shinyjs::enable('loss_slope')
    }else{
      shinyjs::disable('curr_wt')
      shinyjs::disable('goal_wt')
      shinyjs::disable('loss_slope')
    }
  })
  
  #feed the information to db only if all the fields are populated
  observeEvent(input$confirm_goal,{
    if ((input$wt_unit != '') & (input$cal_unit != '') & !(is.na(input$curr_wt))
        & !(is.na(input$goal_wt)) & !(is.na(input$loss_slope))){
      data <- list('user' = user,
                   'date_created' = as.character(Sys.time()),
                   'year' = year(Sys.time()),
                   'month' = month(Sys.time()),
                   'week_in_yr' = week(Sys.time()),
                   'start_date' = as.character(input$date),
                   'wt_unit' = input$wt_unit,
                   'cal_unit' = input$cal_unit,
                   'curr_wt' = input$curr_wt,
                   'goal_wt' = input$goal_wt,
                   'loss_slope' = input$loss_slope)
      user_data <- data.frame(data)
      #adding user goal to database
      add_user_goal('weightloss.db', user_data)
      showNotification('Goals updated!', type='message')
      
      #The below code makes an api call to get the tdee calories
      output$tdee_display <- renderUI({
                              verbatimTextOutput(session$ns('tdee_text'))
                                })
      output$tdee_text <- renderText({
                            tdee <- GET(url = paste0('http://127.0.0.1:5000/',
                                                     user,'/',
                                                     isolate(input$curr_wt),'/',
                                                     isolate(input$wt_unit),'/',
                                                     isolate(input$cal_unit)))
                            curr_tdee <- content(tdee)
                            paste('Your current TDEE is', curr_tdee)
                                    })
      shinyjs::show('tdee_display')
    }else{
      showNotification('Please fill all the required fields', type='error')
      shinyjs::hide('tdee_display')
    }
  })

}