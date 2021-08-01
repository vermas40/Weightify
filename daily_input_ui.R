daily_input_ui <- function(id){
  ns <- NS(id)
  fluidPage(
          shinyjs::useShinyjs(),
          fluidRow(
            tagList(
              column(width = 4, offset = 0,
                     dateInput(ns("date"), "Tracking for:", 
                               value = NULL)
                    )
                    )
                  ), #close fluidRow
          fluidRow(
            tagList(
              column(width = 4, offset = 0,
                     numericInput(ns('daily_wt'),
                                  h5('Enter weight'),
                                  value=NULL,
                                  min = 0
                     )
              ), #close column
              column(width = 4, offset = 0,
                     numericInput(ns('daily_cal'),
                                  h5('Enter calories consumed'),
                                  value=NULL,
                                  min = 0
                     )
              ) #close column
            )#close tagList
          ), #close fluidRow
        fluidRow(
          tagList(
            column(width = 4, offset = 4,
                   actionButton(ns('input_submit'),'Submit')
            ) #close column
          ), #close tagList
          style='padding-top:10px;'
        )
  ) #close FluidPage
}

daily_input_server <- function(input, output, session, user){
  
  observeEvent(input$input_submit,{
    if ((length(input$date) == 0) | (is.na(input$daily_wt)) | 
        (is.na(input$daily_cal))){
      showNotification('Please fill all the required fields', type = 'error')
    }else{

      data <- list('user' = user,
                   'date_created' = as.character(Sys.time()),
                   'date' = as.character(input$date),
                   'year' = year(input$date),
                   'month' = month(input$date),
                   'week_in_yr' = epiweek(input$date),
                   'wt' = input$daily_wt,
                   'cal' = input$daily_cal,
                   'source' = 'user_generated')
      track_weight_data <- data.frame(data)
      track_weight_data <- create_week_calendar_data(track_weight_data)
      update_db('weightloss.db', track_weight_data, 'weighing_scale','daily_input')
      showNotification('Data updated!', type = 'message')
                   
    }
  }, ignoreInit = TRUE)
}


