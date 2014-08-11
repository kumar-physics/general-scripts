library(ggvis)
library(ggvis)

# For dropdown menu
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
           sliderInput("res", "Resolution",0, 20, value = c(0.8, 10), step = 0.1)),
    column(3,
           sliderInput("are", "Interface area", 35, 10000, value = c(800, 1800), step = 10)),
    column(3, 
           sliderInput("rfr", "R-free value",0,1,0.3,step=0.1)),
    column(3,
           sliderInput("hom", "Number of homologs",0,200,10,step=1))
  ),
  fluidRow(
    column(6,
           selectInput("xvar", "X-axis variable", axis_vars, selected = "area")),
    column(6,
           selectInput("yvar", "Y-axis variable", axis_vars, selected = "csScore"))
    ),
  fluidRow(
    column(6,
           ggvisOutput("plot3")),
    column(6,
           ggvisOutput("plot1"))
  ),
  fluidRow(
    column(6,
           wellPanel(
             span("Number of interfaces plotted:",
                  textOutput("n_ifaces")
             )
           )
    ),
    column(6,
           ggvisOutput("plot2"))   
    )
    )
)