
library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("EPPIC vs authors"),

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Number of datapoints:",
                  min = 500,
                  max = 60000,
                  value = 1000)
    ),

    # Show a plot of the generated distribution
    mainPanel(position = "below",
      plotOutput("distPlot")
    )
  )
))
