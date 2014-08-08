library(ggvis)
library(RMySQL)
library(dplyr)
library(RSQLite)
library(RSQLite.extfuns)
library(shiny)

mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05")

alldata=fetch(dbSendQuery(mydb,"select * from EppicTable"),-1)

shinyServer(function(input, output, session) {
  ep <- reactive({
    # Due to dplyr issue #318, we need temp variables for input values
    minres <- input$res[1]
    maxres <- input$res[2]
    minarea <-input$ar[1]
    maxarea <-input$ar[2]
    h<-input$homo
    #minar <- input$ar[1]
    #maxar <- input$ar[2]

    # Apply filters
    m <- alldata %>%
      filter(
        resolution >= minres,
        resolution < maxres,
        area >= minarea,
        area < maxarea,
        h1>h,
        h2>h,
        csScore > -1000,
        crScore < 1000,
        crScore > -1000
      )
    m <- as.data.frame(m)
    m
  })

  eppic_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$area)) return(NULL)

    # Pick out the movie with this ID
    alldata <- isolate(ep())
    eps <- alldata[alldata$area == x$area, ]

    paste0("<b>", eps$pdbCode, "</b><br>",
           eps$csScore, "<br>"
    )
  }

  vis <- reactive({
    # Lables for axes
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]

    # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
    # but since the inputs are strings, we need to do a little more work.
    xvar <- prop("x", as.symbol(input$xvar))
    yvar <- prop("y", as.symbol(input$yvar))

    ep %>%
      ggvis(x = xvar, y = yvar) %>%
      #layer_points(size := 50, size.hover := 200,
       #            fillOpacity := 0.2, fillOpacity.hover := 0.5)
                   #stroke = ~has_oscar, key := ~ID) %>%
      add_tooltip(eppic_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) %>%
      #add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
      #scale_nominal("stroke", domain = c("Yes", "No"),
        #            range = c("orange", "#aaa")) %>%
      set_options(width = 500, height = 500)
  })

  vis %>% bind_shiny("plot1")

  #output$n_movies <- renderText({ nrow(ep()) })
})

