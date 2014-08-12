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
           sliderInput("res", "Resolution",0, 20, value = c(0.8, 1.3), step = 0.1)),
    column(3,
           sliderInput("are", "Interface area", 30, 20000, value = c(1800, 2800), step = 10)),
    column(3, 
           sliderInput("rfr", "R-free value",0,1,0.3,step=0.1)),
    column(3,
           sliderInput("hom", "Number of homologs",0,200,50,step=1))
  ),
  fluidRow(
    column(3,
           selectInput("xvar", "X-axis variable", axis_vars, selected = "area")),
    column(4,
           selectInput("yvar", "Y-axis variable", axis_vars, selected = "csScore")),
    column(3,
           selectInput("color", "Color by ", color_vars, selected = "final")),
    column(3,
           actionButton("goButton", "Go!"))
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