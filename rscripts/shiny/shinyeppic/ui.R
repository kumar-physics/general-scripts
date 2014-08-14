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
    column(2, 
           sliderInput("res", "Resolution",-1, 50, value = c(0.8, 1.3), step = 0.1)),
    column(2,
           sliderInput("are", "Interface area", 30, 20000, value = c(1800, 2800), step = 10)),
    column(2, 
           sliderInput("rfr", "R-free value",-1,1,value=c(0.0,0.3),step=0.1)),
#     column(2,
#            sliderInput("hom", "Homologs",0,200,50,step=1)),
    column(2,
           sliderInput("bs", "Assembly size", -1, 200, value = c(1, 6), step = 1)),
    column(2,
           numericInput("homin", "Homologs min", value = 10)),
    column(2,
           numericInput("homax", "Homologs max", value = 200))
  ),
fluidRow(
  column(3,
         numericInput("csmin", "Core surface min", value = -2000)),
  column(3,
         numericInput("csmax", "Core surface max", value = 2000)),
  column(3,
         numericInput("crmin", "Core rim min", value = -2000)),
  column(3,
         numericInput("crmax", "Core rim max", value = 2000))
  
),
  fluidRow(
    column(2,
           selectInput("final", "Final", calls, selected = "xtal|bio|nopred")),
    column(2,
           selectInput("cs", "Core surface", calls, selected = "xtal|bio|nopred")),
    column(2,
           selectInput("cr", "Core rim", calls, selected = "xtal|bio|nopred")),
    column(2,
           selectInput("auth", "Authors", calls, selected = "xtal|bio|nopred")),
    column(2,
           selectInput("pisa", "PISA", calls, selected = "xtal|bio|nopred"))
   
  ),
  fluidRow(
    column(4,
           selectInput("tax1","Taxonomy side 1", tax, selected = "Archaea|Bacteria|Eukaryota|Viruses|unclassified sequences|other sequences|unknown")),
    column(4,
           selectInput("tax2","Taxonomy side 2", tax, selected = "Archaea|Bacteria|Eukaryota|Viruses|unclassified sequences|other sequences|unknown")),
    column(4, wellPanel(
      span("Press this button to update filters\n",actionButton("goButton", "Update")
      )
    ))
    
  ),
  fluidRow(
    column(3,
           selectInput("xvar", "X-axis variable", axis_vars, selected = "area")),
    column(3,
           selectInput("yvar", "Y-axis variable", axis_vars, selected = "csScore")),
    column(3,
           selectInput("color", "Color by ", color_vars, selected = "final")),
    column(3,
           wellPanel(
             span("Number of interfaces plotted:",textOutput("n_ifaces")
             )
           )
    )
    ),
  fluidRow(
    column(12,
           ggvisOutput("plot1"))   
    )
    )
)