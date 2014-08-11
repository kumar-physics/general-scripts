library(ggvis)
library(RMySQL)
library(dplyr)
library(shiny)



mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05")
all_ifaces=fetch(dbSendQuery(mydb,"select * from EppicTable where csScore > -1000 and csScore < 400 limit 10000"),-1)

all_ifaces$ID=sprintf("%s-%d",all_ifaces$pdbCode,all_ifaces$interfaceId)


shinyServer(function(input, output, session) {
  
  # Filter the movies, returning a data frame
  ifaces <- reactive({
    # Due to dplyr issue #318, we need temp variables for input values
    minres <- input$res[1]
    maxres <- input$res[2]
    minare <- input$are[1]
    maxare <- input$are[2]
    rfr <- input$rfr
    hom <- input$hom
    
    # Apply filters
    m <- all_ifaces %>%
      filter(
        resolution >= minres,
        resolution <= maxres,
        area >= minare,
        area <= maxare,
        rfreeValue <= rfr,
        h1 >= hom,
        h2 >= hom
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
    
    # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
    # but since the inputs are strings, we need to do a little more work.
    xvar <- prop("x", as.symbol(input$xvar))
    yvar <- prop("y", as.symbol(input$yvar))
    
    ifaces %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 50, size.hover := 200,
                   fillOpacity := 0.2, fillOpacity.hover := 0.5, stroke=~final, key := ~ID) %>%
      #mark_rect() %>%
      add_tooltip(iface_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) %>%
      #add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
      #scale_nominal("stroke", domain = c("Yes", "No"),
      #range = c("orange", "#aaa")) %>%
    set_options(width = 400, height = 400)
  })
  
  vis2 <- reactive({
    # Lables for axes
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]
    
    # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
    # but since the inputs are strings, we need to do a little more work.
    xvar <- prop("x", as.symbol(input$xvar))
    yvar <- prop("y", as.symbol(input$yvar))
    
    ifaces %>%
      ggvis(xvar,fill=~final) %>% 
      group_by(final) %>% 
      layer_histograms(stack=FALSE, fillOpacity := 0.5) %>%
      #layer_point(fill=~final) %>%
      #mark_rect() %>%
      #add_tooltip(iface_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      #add_axis("y", title = yvar_name) %>%
      #add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
      #scale_nominal("stroke", domain = c("Yes", "No"),
      #range = c("orange", "#aaa")) %>%
      set_options(width = 400, height = 400)
  })
  
  vis3 <- reactive({
    # Lables for axes
    xvar_name <- names(axis_vars)[axis_vars == input$yvar]
    yvar_name <- names(axis_vars)[axis_vars == input$xvar]
    
    # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
    # but since the inputs are strings, we need to do a little more work.
    xvar <- prop("x", as.symbol(input$yvar))
    yvar <- prop("y", as.symbol(input$xvar))
    ifaces %>%
      ggvis(xvar,fill=~final) %>% 
      group_by(final) %>% 
      layer_histograms(stack=FALSE, fillOpacity := 0.5) %>%
      #layer_point(fill=~final) %>%
      #mark_rect() %>%
      #add_tooltip(iface_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      #add_axis("y", title = yvar_name) %>%
      #add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
      #scale_nominal("stroke", domain = c("Yes", "No"),
      #range = c("orange", "#aaa")) %>%
      set_options(width = 400, height = 400)
  })

vis %>% bind_shiny("plot1")
vis2 %>% bind_shiny("plot2")
vis3 %>% bind_shiny("plot3")
output$n_ifaces <- renderText({ nrow(ifaces()) })
})
