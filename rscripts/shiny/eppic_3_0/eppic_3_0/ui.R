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
  titlePanel(img(src="eppic-logo.png",align="right")),
  titlePanel(h1("EPPIC Explorer",align="center",style = "color:coral")),
  #fluidRow(img(src="eppic-logo.png", height = 200, width = 80)),
  fluidRow(h4("UniProt version: 2014_11, EPPICdb version: 3.0",align="center",style = "color:green")),
  #fluidRow(h4("EPPICdb version: 3.0",align="center",style = "color:green")),
  
  fluidRow(
    column(12,h4(strong("PDB level filters"),style = "color:red"))),
  
  fluidRow(
    column(3,
           numericInput("resmin",
                         label="Resolution (low) [Å]",
                         value=50.0)),
    column(3,
           numericInput("resmax",
                         label="Resolution (high) [Å]",
                         value=0.0)),
    column(3,
           numericInput("rfmin",
                        label="R-Free (min)",
                        value=-1.0)),
    column(3,
           numericInput("rfmax",
                        label="R-Free (max)",
                        value=1.0))
  ),
  
  fluidRow(
    column(3,
           selectInput("sgv", "Space group", sg, selected = "*")),
    column(3,
           selectInput("opt", "Operator type", optype, selected = "*")),
    column(3,
           selectInput("exp", "Exp. method", exptype, selected = "*")),
    column(3,
           textInput("tit",
                     label="Key words in PDB title",
                     value="*"))
  ),
  fluidRow(
    column(3,
           numericInput("cmin",
                        label="No. of chain clusters (min)",
                        value=1)),
    column(3,
           numericInput("cmax",
                        label="No. of chain clusters (max)",
                        value=1000)),
    column(3,
           numericInput("hmin",
                        label="No. of seq. homologs (min)",
                        value=30)),
    column(3,
           numericInput("hmax",
                        label="No. of seq. homologs (max)",
                        value=150))
  ),
  fluidRow(
    column(12," ")),
  fluidRow(
    column(12,h4(strong("Interface level filters"),style = "color:red"))),
  
  fluidRow(
    column(3,
           numericInput("areamin",
                        label="Interface area (min) [Å²]",
                        value=1700.0)),
    column(3,
           numericInput("areamax",
                        label="Interface area (max) [Å²]",
                        value=1800.00)),
    column(3,
           numericInput("cmin",
                        label="No. of chain clusters (min)",
                        value=1)),
    column(3,
           numericInput("cmax",
                        label="No. of chain clusters (max)",
                        value=1000))
  ),
 
  fluidRow(
    column(3,
           numericInput("csmin",
                        label="Core-surface score (min)",
                        value=-10)),
    column(3,
           numericInput("csmax",
                        label="Core-surface score (max)",
                        value=50)),
    column(3,
           numericInput("crmin",
                        label="Core-rim score (min)",
                        value=0)),
    column(3,
           numericInput("crmax",
                        label="Core-rim score (max)",
                        value=100))
  ),
  
  fluidRow(
    column(3,
           selectInput("ncs", "Having NCS operator?", boolcall, selected = "*")),
    column(3,
           selectInput("inf", "Is Infinite?", boolcall, selected = "*")),
    column(3,
           selectInput("prot1", "Is side1 protien?", boolcall, selected = "*")),
    column(3,
           selectInput("prot2", "Is side2 protein?", boolcall, selected = "*"))
  ),
  
  fluidRow(
    column(3,
           textInput("sym",
                        label="Symmetry",
                        value="*")),
    column(3,
           textInput("psym",
                        label="Pseudo symmetry",
                        value="*")),
    column(3,
           textInput("sto",
                        label="Stoichiometry",
                        value="*")),
    column(3,
           textInput("psto",
                        label="Pseudo stoichiometry",
                        value="*"))
  ),
  
 
  
  fluidRow(
    column(3,
           selectInput("gmc","GM call", calls, selected ="*" )),
    column(3,
           selectInput("crc", "Core-rim call", calls, selected = "*")),
    column(3,
           selectInput("csc", "Core-surface call", calls, selected = "*")),
    column(3,
           selectInput("fic","Final call",calls, selected = "*"))
  ),
  
 
  
  fluidRow(
    column(3,selectInput("iso", "Is isologous?", boolcall, selected = "*")),
    column(3, actionButton("goButton",label=strong("Update plot"))),
    column(3,strong("Number of interfaces:"),strong(textOutput("n_ifaces"))),
    column(3,strong("Number of PDB entries:"),strong(textOutput("n_entries")))
  ),
  fluidRow(
    column(12," ")),
  fluidRow(
    column(12,h4(strong("Dynamic parameters"),style = "color:red"))),
  fluidRow(
    column(3,
           selectInput("xvar", "X-axis variable", axis_vars, selected = "area")),
    column(3,
           selectInput("yvar", "Y-axis variable", axis_vars, selected = "cs")),
    column(3,
           selectInput("color", "Color by ", color_vars, selected = "eppic")),
    column(3,
           selectInput("shapevar","Shape by",shape_vars, selected = "operatorType"))
  ),
  fluidRow(
    column(12,
           ggvisOutput("plot1"))   
  )
))
