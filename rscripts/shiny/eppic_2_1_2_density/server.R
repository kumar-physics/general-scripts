library(ggvis)
library(RMySQL)
library(dplyr)
library(shiny)

mydb=dbConnect(MySQL(),host="",username="", password="",dbname="eppic_2014_10")
#mydb=dbConnect(MySQL(),dbname="eppic_2014_10")
all_ifaces=fetch(dbSendQuery(mydb,"select *,abs(cs1-cs2) dcs,abs(cr1-cr2) dcr from EppicTable"),-1)
all_ifaces$ID=sprintf("%s-%d",all_ifaces$pdbCode,all_ifaces$interfaceId)

shinyServer(function(input, output, session) {
  
  # Filter the movies, returning a data frame
  ifaces <- reactive({
    input$goButton
    minres <- isolate(input$resmin)
    maxres <- isolate(input$resmax)
    minrf<-isolate(input$rfmin)
    maxrf<-isolate(input$rfmax)
    minarea <- isolate(input$areamin)
    maxarea <- isolate(input$areamax)
    minc<-isolate(input$cmin)
    maxc<-isolate(input$cmax)
    minh <- isolate(input$hmin)
    maxh <- isolate(input$hmax)
    mincs <-isolate(input$csmin)
    maxcs <-isolate(input$csmax)
    mincr <-isolate(input$crmin)
    maxcr <-isolate(input$crmax)
    vsg <-isolate(input$sgv)
    top<-isolate(input$opt)
    et<-isolate(input$exp)
    colvar<-isolate(input$color)
    # Apply filters
    m <- all_ifaces %>%
      filter(
        resolution >= maxres,
        resolution <= minres,
        rfreeValue>=minrf,
        rfreeValue<=maxrf,
        area <= maxarea,
        area >= minarea,
        numChainClusters>=minc,
        numChainClusters<=maxc,
        h1 >= minh,
        h2 >= minh,
        h1 <= maxh,
        h2 <= maxh,
        cr1 <= maxcr,
        cr2 <= maxcr,
        cr1 >= mincr,
        cr2 >= mincr,
        cs1 <= maxcs,
        cs2 <= maxcs,
        cs1 >= mincs,
        cs2 >= mincs,
        cr <= maxcr,
        cs <= maxcs,
        cr >= mincr,
        cs >= mincs,
        grepl(vsg,spaceGroup),
        grepl(top,operatorType),
        grepl(et,expMethod)
      ) %>%
      arrange(area)
    m <- as.data.frame(m)
    names(m)[names(m)==colvar] <- "colorvalue"
    m
  })
  
  # Function for generating tooltip text
  iface_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$ID)) return(NULL)
    
    # Pick out the movie with this ID
    all_ifaces <- isolate(ifaces())
    iface <- all_ifaces[all_ifaces$ID == x$ID, ]
    
    paste0("PDB :", iface$pdbCode, 
           "<br> InterfaceId :",iface$interfaceId,
           "<br> area :",sprintf("%.2f",iface$area),
           "<br> Operator :",iface$operator,
           "<br> Geometry :",iface$gm," ",iface$gmcall, 
           "<br> Core-rim :",sprintf("%.2f",iface$cr)," ",iface$crcall,
           "<br> Core-surface :",sprintf("%.2f",iface$cs)," ",iface$cscall,
           "<br> Final :",iface$eppic
           
    )
  }
  
  
  vis <- reactive({
    # Lables for axes
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    
    
    # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
    # but since the inputs are strings, we need to do a little more work.
    xvar <- prop("x", as.symbol(input$xvar))
    
    
    
    ifaces %>% 
      ggvis(xvar, stroke=~colorvalue,fill=~colorvalue) %>%
      group_by(colorvalue) %>% 
      layer_densities( fillOpacity := 0.5)

  })
  vis %>% bind_shiny("plot1")
  
  output$n_ifaces <- renderText({ nrow(ifaces()) })
})