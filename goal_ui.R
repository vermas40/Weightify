goal_ui <- function(id){
  ns <- NS(id)
  fluidPage(
           shinyjs::useShinyjs(),
           fluidRow(
                  tagList(
                          column(width = 4, offset = 0,
                                 dateInput(ns("date"), "Select starting date", value = NULL)
                                 )
                         )
                   ),
           fluidRow(
                 tagList(
                         column(width = 4, offset = 0,
                                selectInput(ns('wt_unit'),
                                            h5('Select weight unit'),
                                            choices = c('', 'Kg','Lbs'))
                               ),
                         column(width = 4, offset = 0,
                                selectInput(ns('cal_unit'),
                                            h5('Select calorie unit'),
                                            choices = c('', 'Cal.','Kj'))
                                )
                        )
                   ),
           fluidRow(
                   tagList(
                         column(width = 4, offset = 0,
                                numericInput(ns('curr_wt'),
                                            h5('Enter current weight'),
                                            value=NULL
                                            )
                               ),
                         column(width = 4, offset = 0,
                                numericInput(ns('goal_wt'),
                                            h5('Enter goal weight'),
                                            value=NULL
                                            )
                               ),
                         column(width = 4, offset = 0,
                                numericInput(ns('loss_slope'),
                                            h5('Enter goal weight loss per week'),
                                            value=NULL
                                            )
                               )
                          )
                  )
           )
}

goal_server <- function(input, output, session){
  shinyjs::disable('wt_unit')
  shinyjs::disable('cal_unit')
  shinyjs::disable('curr_wt')
  shinyjs::disable('goal_wt')
  shinyjs::disable('loss_slope')
  
}