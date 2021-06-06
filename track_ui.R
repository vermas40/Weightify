track_ui <- function(id){
  ns <- NS(id)
  tagList(
         navlistPanel(
                      ' ',
                      id = ns('track_navlist_tabs'),
                      tabPanel('Goal Setting',goal_ui('goal')),
                      tabPanel('Daily Input'),
                      widths = c(2,10),
                      well = FALSE
                     )
         )
}