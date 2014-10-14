library(ggvis)
library(RMySQL)
library(dplyr)
library(shiny)



mydb=dbConnect(MySQL(),dbname="eppic_2014_07")
all_ifaces=fetch(dbSendQuery(mydb,"select *,abs(cs1-cs2) dcs,abs(cr1-cr2) dcr from EppicTable"),-1)

all_ifaces$ID=sprintf("%s-%d",all_ifaces$pdbCode,all_ifaces$interfaceId)
all_ifaces$bio_size_tag=sprintf("s_%d",all_ifaces$bio_size)


shinyServer(function(input, output, session) {
  
  # Filter the movies, returning a data frame
  ifaces <- reactive({
    # Due to dplyr issue #318, we need temp variables for input values
    input$goButton
    mincs<-isolate(input$csmin)
    maxcs<-isolate(input$csmax)
    mincr<-isolate(input$crmin)
    maxcr<-isolate(input$crmax)
    minres <- isolate(input$res[1])
    maxres <-  isolate(input$res[2])
    minare <-  isolate(input$are[1])
    maxare <-  isolate(input$are[2])
    minrfr <-  isolate(input$rfr[1])
    maxrfr <-  isolate(input$rfr[2])
    minhom <-  isolate(input$homin)
    maxhom <-  isolate(input$homax)
    minbs <- isolate(input$bs[1])
    maxbs <- isolate(input$bs[2])
    finalval <- isolate(input$final)
    csval<- isolate(input$cs)
    crval <- isolate(input$cr)
    authval <- isolate(input$auth)
    pisaval <- isolate(input$pisa)
    tax1val<- isolate(input$tax1)
    tax2val<- isolate(input$tax2)
    # Apply filters
    m <- all_ifaces %>%
      filter(
        resolution >= minres,
        resolution <= maxres,
        area >= minare,
        area <= maxare,
        rfreeValue >= minrfr,
        rfreeValue <= maxrfr,
        h1 >= minhom,
        h2 >= minhom,
        h1 <= maxhom,
        h2 <= maxhom,
        bio_size >= minbs,
        bio_size <= maxbs,
        grepl(finalval,final),
        grepl(csval,cs),
        grepl(crval,cr),
        grepl(authval,authors),
        grepl(pisaval,pisa),
        grepl(tax1val,tax1),
        grepl(tax2val,tax2),
#         cs1 >= mincs,
#         cs1 <= maxcs,
#         cs2 >= mincs,
#         cs2 <= maxcs,
#         cr1 >= mincr,
#         cr1 <= maxcr,
#         cr2 >= mincr,
#         cr2 <= maxcr,
        csScore >= mincs,
        csScore <= maxcs,
        crScore >= mincr,
        crScore <= maxcr
      ) %>%
      arrange(area)
    
    #     # Optional: filter by genre
    #     if (input$genre != "All") {
    #       genre <- paste0("%", input$genre, "%")
    #       m <- m %>% filter(Genre %like% genre)
    #     }
    #     # Optional: filter by director
    #     if (!is.null(input$director) && input$director != "") {
    #       director <- paste0("%", input$director, "%")
    #       m <- m %>% filter(Director %like% director)
    #     }
    #     # Optional: filter by cast member
    #     if (!is.null(input$cast) && input$cast != "") {
    #       cast <- paste0("%", input$cast, "%")
    #       m <- m %>% filter(Cast %like% cast)
    #     }
    #     
    
    m <- as.data.frame(m)
    
    # Add column which says whether the movie won any Oscars
    # Be a little careful in case we have a zero-row data frame
    #     m$has_oscar <- character(nrow(m))
    #     m$has_oscar[m$Oscars == 0] <- "No"
    #     m$has_oscar[m$Oscars >= 1] <- "Yes"
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
           "<br> Geometry :",iface$gmScore," ",iface$gm, 
           "<br> Core-rim :",sprintf("%.2f",iface$crScore)," ",iface$cr,
           "<br> Core-surface :",sprintf("%.2f",iface$csScore)," ",iface$cs,
           "<br> Final :",iface$final
           
    )
  }
  
  # A reactive expression with the ggvis plot
  vis <- reactive({
    # Lables for axes
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]
    strokeval <- as.symbol(input$color)
    
    # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
    # but since the inputs are strings, we need to do a little more work.
    xvar <- prop("x", as.symbol(input$xvar))
    yvar <- prop("y", as.symbol(input$yvar))
    
    ifaces %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 50, size.hover := 200,
                   #fillOpacity := 0.2, fillOpacity.hover := 0.5, 
                   stroke=strokeval, fill=strokeval, key := ~ID) %>%
      #mark_rect() %>%
      add_tooltip(iface_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) %>%
      #add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
      #scale_nominal("stroke", domain = c("Yes", "No"),
      #range = c("orange", "#aaa")) %>%
    set_options(width = 1200, height = 1200)
  })
  
 
 
vis %>% bind_shiny("plot1")


output$n_ifaces <- renderText({ nrow(ifaces()) })
})
