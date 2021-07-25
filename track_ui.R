track_ui <- function(id){
  ns <- NS(id)
  tagList(
         navlistPanel(
                      ' ',
                      id = ns('track_navlist_tabs'),
                      tabPanel('Goal Setting',goal_ui('goal')),
                      tabPanel('Daily Input',daily_input_ui('daily')),
                      widths = c(2,10),
                      well = FALSE
                     )
         )
}