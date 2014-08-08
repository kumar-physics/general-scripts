library(ggvis)
library(shiny)
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}

shinyUI(fluidPage(
  titlePanel("EPPIC explorer"),
  fluidRow(
    column(3,
           wellPanel(
             h4("Filter"),
             sliderInput("ar", "Area",35,10000,value = c(3500,10000), step=10),
             sliderInput("res", "Resolution", 0, 20, value = c(0.8, 10), step = 0.1),
             sliderInput("homo", "Number of Homologs", 0,200, 50)
           ),
           wellPanel(
             selectInput("xvar", "X-axis variable", axis_vars, selected = "resolution"),
             selectInput("yvar", "Y-axis variable", axis_vars, selected = "csScore")
           )
    ),
    column(9,
           ggvisOutput("plot1")
           )
    )
  )
)
