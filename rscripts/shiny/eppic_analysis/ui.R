library(ggvis)
library(RMySQL)
library(dplyr)
library(shiny)
# For dropdown menu
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}
shinyUI(fluidPage(
  titlePanel(h1("EPPIC Analysis",align="center",style = "color:coral")),
  fluidRow(h4("Database: UniProt 2014_10",align="center",style = "color:green")),
  fluidRow(
    column(6,
           textInput("pdbid",
                        label=h5("PDB ID"),
                        value="2gs2")),
    column(6,
           numericInput("interfaceid",
                        label=h5("Interface no"),
                        value=1))
  ),
  fluidRow(
    column(6,
           numericInput("resmin",
                         label=h5("Resolution (low) [Å]"),
                         value=50.0)),
    column(6,
           numericInput("resmax",
                         label=h5("Resolution (high) [Å]"),
                         value=0.0))
  ),
  fluidRow(
    column(6,
           numericInput("rfmin",
                        label=h5("R-Free (min)"),
                        value=-1.0)),
    column(6,
           numericInput("rfmax",
                        label=h5("R-Free (max)"),
                        value=1.0))
  ),
  fluidRow(
    column(6,
           numericInput("areamin",
                        label=h5("Interface area (min) [Å²]"),
                        value=0.0)),
    column(6,
           numericInput("areamax",
                        label=h5("Interface area (max) [Å²]"),
                        value=180000.00))
  ),
  fluidRow(
    column(6,
           numericInput("cmin",
                        label=h5("No. of chain clusters (min)"),
                        value=1)),
    column(6,
           numericInput("cmax",
                        label=h5("No. of chain clusters (max)"),
                        value=1000))
  ),
  fluidRow(
    column(6,
           numericInput("hmin",
                        label=h5("No. of sequence homologs (min)"),
                        value=0)),
    column(6,
           numericInput("hmax",
                        label=h5("No. of sequence homologs (max)"),
                        value=150))
  ),
  fluidRow(
    column(6,
           numericInput("csmin",
                        label=h5("Core-surface score (min)"),
                        value=-10)),
    column(6,
           numericInput("csmax",
                        label=h5("Core-surface score (max)"),
                        value=50))
  ),
  fluidRow(
    column(6,
           numericInput("crmin",
                        label=h5("Core-rim score (min)"),
                        value=0)),
    column(6,
           numericInput("crmax",
                        label=h5("Core-rim score (max)"),
                        value=100))
  ),
  fluidRow(
    column(4,
           selectInput("sgv", h5("Space group"), sg, selected = "B 2|C 1 2 1|C 1 2/c 1|C 1 21 1|C 2 2 2|C 2 2 21|F 2 2 2|F 2 3|F 4 3 2|F 41 3 2|H 3|H 3 2|I -4 2 d|I -4 c 2|
I 1 21 1|I 2|I 2 2 2|I 2 3|I 21 21 21|I 21 3|I 4|I 4 2 2|I 4 3 2|I 41|I 41 2 2|I 41 3 2|I 41/a|P -1|P -3|P 1|P 1 1 21|
P 1 2 1|P 1 21 1|P 1 21/c 1|P 2 2 2|P 2 2 21|P 2 21 21|P 2 3|P 21 2 2|P 21 2 21|P 21 21 2|P 21 21 21|P 21 3|P 3|P 3 1 2|
P 3 2 1|P 31|P 31 1 2|P 31 2 1|P 32|P 32 1 2|P 32 2 1|P 4|P 4 2 2|P 4 21 2|P 4 3 2|P 41|P 41 2 2|P 41 21 2|P 41 3 2|P 42|
P 42 2 2|P 42 21 2|P 42 3 2|P 43|P 43 2 2|P 43 21 2|P 43 3 2|P 6|P 6 2 2|P 61|P 61 2 2|P 62|P 62 2 2|P 63|P 63 2 2|
P 64|P 64 2 2|P 65|P 65 2 2|P b c a|R 3|R 3 2")),
    column(4,
           selectInput("opt", h5("Operator type"), optype, selected = "-1|-4|2|2S|3|3S|4|4S|6|6S|AU|FT|GL|XT")),
    column(4,
           selectInput("exp", h5("Exp. method"), exptype, selected = "ELECTRON CRYSTALLOGRAPHY|ELECTRON MICROSCOPY|FIBER DIFFRACTION|FLUORESCENCE TRANSFER|INFRARED SPECTROSCOPY
  NEUTRON DIFFRACTION|POWDER DIFFRACTION|SOLID-STATE NMR|SOLUTION NMR|SOLUTION SCATTERING|X-RAY DIFFRACTION"))
  ),
  fluidRow(
       column(6, actionButton("goButton",
                              label=h5("Press here to update the plot",align="center"))
      
    ),
    column(6,h5("Number of interfaces:"),h6(textOutput("n_ifaces"))
    )
    
  ),
  
  
  fluidRow(
    column(4,
           selectInput("xvar", "X-axis variable", axis_vars, selected = "area")),
    column(4,
           selectInput("yvar", "Y-axis variable", axis_vars, selected = "interfaceId")),
    column(4,
           selectInput("color", "Color by ", color_vars, selected = "pdbCode"))
  ),
  fluidRow(
    column(12,
           ggvisOutput("plot1"))   
  )
))
