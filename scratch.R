library(shiny)
library(shiny.router)

root_page <- div(h2("Root page"))
other_page <- div(h3("Other page"))

router <- make_router(
  route("/", root_page),
  route("other", other_page)
)

ui <- fluidPage(
  title = "Router demo",
  router$ui
)

server <- function(input, output, session) {
  router$server(input, output, session)
}

shinyApp(ui, server)
