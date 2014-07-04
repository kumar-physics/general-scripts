library(shiny)

# Define UI for random distribution application 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Eppic Statistics"),
  
  # Sidebar with controls to select the random distribution type
  # and number of observations to generate. Note the use of the
  # br() element to introduce extra vertical spacing
  sidebarLayout(
    sidebarPanel(
#       radioButtons("dist", "Data to plot:",
#                    c("Geometry" = "gm",
#                      "Core Rim" = "cr",
#                      "Core Surface" = "cs",
#                      "Final" = "final")),
#       br(),
#       sliderInput("n", 
#                   "Area bin size:", 
#                   value = 50,
#                   min = 10, 
#                   max = 1000),
#      br(),
      sliderInput("w1", 
                  "Weighting factor GM:", 
                  value = 0.43,
                  min = -10, 
                  max = 10,
                  step=0.01),
      br(),
      sliderInput("w2", 
                  "Weighting factor CR:", 
                  value = 0.03,
                  min = -10, 
                  max = 10,
                  step=0.01),
      br(),
      sliderInput("w3", 
                  "Weighting factor CS:", 
                  value = -1.4,
                  min = -10, 
                  max = 10,
                  step=0.01)
    ),
    
    # Show a tabset that includes a plot, summary, and table view
    # of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Plot", plotOutput("plot")), 
                  tabPanel("Summary", verbatimTextOutput("summary")), 
                  tabPanel("Table", tableOutput("table"))
      )
    )
  )
))