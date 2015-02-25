library(ggvis)
library(RMySQL)
library(dplyr)
library(shiny)

mydb=dbConnect(MySQL(),host="pc11467.psi.ch",username="eppicweb", password="",dbname="eppic_3_0_2014_11")
#mydb=dbConnect(MySQL(),dbname="eppic_2014_10")
all_ifaces=fetch(dbSendQuery(mydb,"select *,abs(cs1-cs2) dcs,abs(cr1-cr2) dcr from EppicTable"),-1)
all_ifaces$spaceGroup[is.na(all_ifaces$spaceGroup)]="null"
all_ifaces$uniprot1[is.na(all_ifaces$uniprot1)]="null"
all_ifaces$uniprot2[is.na(all_ifaces$uniprot2)]="null"
all_ifaces$ftaxon1[is.na(all_ifaces$ftaxon1)]="null"
all_ifaces$ftaxon2[is.na(all_ifaces$ftaxon2)]="null"
all_ifaces$ltaxon1[is.na(all_ifaces$ltaxon1)]="null"
all_ifaces$ltaxon2[is.na(all_ifaces$ltaxon2)]="null"
all_ifaces$mmSize[is.na(all_ifaces$mmSize)]="null"
all_ifaces$symmetry[is.na(all_ifaces$symmetry)]="null"
all_ifaces$pseudoSymmetry[is.na(all_ifaces$pseudoSymmetry)]="null"
all_ifaces$stoichiometry[is.na(all_ifaces$stoichiometry)]="null"
all_ifaces$pseudoStoichiometry[is.na(all_ifaces$pseudoStoichiometry)]="null"
all_ifaces$ID=sprintf("%s-%d",all_ifaces$pdbCode,all_ifaces$interfaceId)
all_ifaces$intid=sprintf("%s",all_ifaces$interfaceId)
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
    minh1 <- isolate(input$hmin)
    maxh1 <- isolate(input$hmax)
    #minh2 <- isolate(input$hmin2)
    #maxh2 <- isolate(input$hmax2)
    mincs <-isolate(input$csmin)
    maxcs <-isolate(input$csmax)
    mincr <-isolate(input$crmin)
    maxcr <-isolate(input$crmax)
    vsg <-isolate(input$sgv)
    top<-isolate(input$opt)
    et<-isolate(input$exp)
    cgm<-isolate(input$gmc)
    ccr<-isolate(input$crc)
    ccs<-isolate(input$csc)
    cfi<-isolate(input$fic)
    ncs1<-isolate(input$ncs)
    inf1<-isolate(input$inf)
    prota<-isolate(input$prot1)
    protb<-isolate(input$prot2)
    sym1<-isolate(input$sym)
    psym1<-isolate(input$psym)
    sto1<-isolate(input$sto)
    psto1<-isolate(input$psto)
    tit1<-isolate(input$tit)
    iso1<-isolate(input$iso)
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
        h1 >= minh1,
        h2 >= minh1,
        h1 <= maxh1,
        h2 <= maxh1,
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
        grepl(et,expMethod),
        grepl(cgm,gmcall),
        grepl(ccr,crcall),
        grepl(ccs,cscall),
        grepl(cfi,eppic),
        grepl(ncs1,ncsOpsPresent),
        grepl(inf1,infinite),
        grepl(iso1,isologous),
        grepl(prota,prot1),
        grepl(protb,prot2),
        grepl(sym1,symmetry),
        grepl(psym1,pseudoSymmetry),
        grepl(sto1,stoichiometry),
        grepl(psto1,pseudoStoichiometry),
        grepl(tit1,title)
      ) %>%
      arrange(area)
    m <- as.data.frame(m)
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
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]
    strokeval <- as.symbol(input$color)
    xvar <- prop("x", as.symbol(input$xvar))
    yvar <- prop("y", as.symbol(input$yvar))
    shapeval <- as.symbol(input$shapevar)
    ifaces %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 50, size.hover := 200,
                   #fillOpacity := 0.2, fillOpacity.hover := 0.5, 
                   stroke=strokeval, fill=strokeval, shape=shapeval,key := ~ID) %>%
      #mark_rect() %>%
      add_tooltip(iface_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) %>%
      add_legend(scales = "shape", properties = legend_props(legend = list(x = 950))) %>%
      set_options(width=800, height=800, duration = 0)
    #add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
    #scale_nominal("stroke", domain = c("Yes", "No"),
    #range = c("orange", "#aaa")) %>%
    #set_options(width = 1200, height = 1200)
  })
  vis %>% bind_shiny("plot1")
  output$n_ifaces <- renderText({ nrow(ifaces()) })
  output$n_entries <-renderText({ length(unique(ifaces()$pdbCode)) })
  
})
