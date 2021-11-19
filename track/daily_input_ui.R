daily_input_ui <- function(id){
  ns <- NS(id)
  fluidPage(
          shinyjs::useShinyjs(),
          fluidRow(
            #tagList(
              column(width = 4, offset = 0,
                     dateInput(ns("date"), "Tracking for:", 
                               value = NULL)
                    ),
              column(width = 4, offset = 0,
                     numericInput(ns('daily_wt'),
                                  h5('Enter weight',
                                     style='position:relative; top:7px;'),
                                  value=NULL,
                                  min = 0
                                  ),
                     style='position:relative; top:-15px;'
                    ), #close column
              column(width = 4, offset = 0,
                     numericInput(ns('daily_cal'),
                                  h5('Enter calories consumed',
                                     style='position:relative; top:7px;'),
                                  value=NULL,
                                  min = 0
                                  ),
                     style='position:relative; top:-15px;'
                    ) #close column
            #)#close tagList
          ), #close fluidRow
        fluidRow(
          column(width = 4, offset = 4,
                 actionButton(ns('input_submit'),'Submit',
                              style='height:34px; line-height:0px;
                                     width:145px;')
            ) #close column
        ), #close fluidRow
        fluidRow(
          tabsetPanel(
            tabPanel('Trend', 
                     uiOutput(ns('wt_trend')),
                     style='padding-top:30px;'),
            tabPanel('Diary'),
            type='tabs'
          ),
          style='padding-top:25px;'
        )
  ) #close FluidPage
}

daily_input_server <- function(input, output, session, user){
  #creating the UI for the html and plotly output
  output$wt_trend <- renderUI({
                            tagList(
                              htmlOutput(session$ns('tdee_text'),
                                         style='padding-bottom:10px;'),
                              plotlyOutput(session$ns('plotly_output'), 
                                           reportTheme = TRUE)
                            )
                              })
  #observing the submit button
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
      tdee <- GET(url = paste0('http://flask-api:5000/tdee/',
                               user))
      showNotification('Data updated!', type = 'message')
      output$tdee_text <- renderText({paste('You need to eat', content(tdee)[[2]],
                                            'calories per day.')})
      output$plotly_output <- renderPlotly({
                                        make_wt_plot(user,'weightloss.db')
                                          })
                   
    }
  }, ignoreInit = TRUE, ignoreNULL = TRUE)

  df <- pull_plot_data(user,'weightloss.db')
  if (nrow(df)>0){
    output$plotly_output <- renderPlotly({
                                      make_wt_plot(user,'weightloss.db')
                                        })
  }else{
    output$tdee_text <- renderText({'Start using the weight & calorie tracking
                                     to see results here'})
  }
}


