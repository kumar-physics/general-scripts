library(shiny)

# Define UI for random distribution application 
shinyUI(fluidPage(
  
  # Application title
#   titlePanel("Machine learning in EPPIC with simple logistic model "),
  
  # Sidebar with controls to select the random distribution type
  # and number of observations to generate. Note the use of the
  # br() element to introduce extra vertical spacing
  sidebarLayout(
    sidebarPanel(
      radioButtons("train", "Database to train:",
                   c("DC" = "dc",
                     "Ponstingl" = "po",
                     "Many" = "many"),selected = "dc"),
      br(),
      radioButtons("test", "Database to test:",
                   c("DC" = "dc",
                     "Ponstingl" = "po",
                     "Many" = "many"),selected = "dc"),
      br()
      
#       sliderInput("n", 
#                   "Area bin size:", 
#                   value = 50,
#                   min = 10, 
#                   max = 1000),
#      br(),
#       sliderInput("w1", 
#                   "Weighting factor H1:", 
#                   value = 0.004,
#                   min = -10, 
#                   max = 10,
#                   step=0.01),
#       br(),
#       sliderInput("w2", 
#                   "Weighting factor H2:", 
#                   value = 0.009,
#                   min = -10, 
#                   max = 10,
#                   step=0.01),
#       br(),
#       sliderInput("w3", 
#                   "Weighting factor area:", 
#                   value = 0.003,
#                   min = -10, 
#                   max = 10,
#                   step=0.01),
#       br(),
#       sliderInput("w4", 
#                   "Weighting factor GM:", 
#                   value = 0.324,
#                   min = -10, 
#                   max = 10,
#                   step=0.01),
#       br(),
#       sliderInput("w5", 
#                   "Weighting factor CR:", 
#                   value = 0.058,
#                   min = -10, 
#                   max = 10,
#                   step=0.01),
#       br(),
#       sliderInput("w6", 
#                   "Weighting factor CS:", 
#                   value = -1.36,
#                   min = -10, 
#                   max = 10,
#                   step=0.01)
    ),
    
    # Show a tabset that includes a plot, summary, and table view
    # of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Plot", plotOutput("plot")), 
                  tabPanel("Summary", verbatimTextOutput("summary")), 
                  tabPanel("Confidence interval", verbatimTextOutput("confint"))
      )
    )
# mainPanel(position = "below",
#           plotOutput("plot"))
  )
))