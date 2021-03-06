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
      radioButtons("dist", "Data to plot:",
                   c("Experimental method" = 'expMethod',
                     "Space group" = 'spaceGroup',
                     "Operator" = 'operator',
                     "Operator type" = 'operatorType'))
#       br(),
#       
#       sliderInput("n", 
#                   "Area bin size:", 
#                   value = 50,
#                   min = 10, 
#                   max = 1000)
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