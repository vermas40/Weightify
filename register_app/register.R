register <- function(id){
  ns <- NS(id)
  tagList(
          fluidRow(
                  column(width = 4, offset = 0,
                         textInput(ns('text_input'),
                                   'Choose a username'
                                   ), #close textInput
                         actionButton(ns('action'),
                                      'Check Availability'
                                      ) 
                         )#close column 
                  ) #close fluidRow
         ) #close tagList
}