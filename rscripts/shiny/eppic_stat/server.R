library(shiny)
library(ggplot2)
library(RMySQL)
#dbconnection
library(gridExtra)
# Define server logic for random distribution application
shinyServer(function(input, output) {
  mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05") #~/.my.cnf file configured with right username and passwd
  on.exit(dbDisconnect(mydb))
  ep=fetch(dbSendQuery(mydb,"select * from EppicTable"),-1)
  d <- reactive({
    switch(input$dist,
           gm = data.frame(area=ep$area,call=ep$gm),
           cr =data.frame(area=ep$area,call=ep$cr),
           cs = data.frame(area=ep$area,call=ep$cs),
           final = data.frame(area=ep$area,call=ep$final),
           data.frame(area=ep$area,call=ep$gm))
    
    
  })
  #colnames(d)[1]='area'
 # colnames(d)[2]='call'
#   if (input$dist == 'gm'){
#     data<-data.frame(eppic$area,eppic$gm)
#   } else if (input$dist == 'cr'){
#     data<-data.frame(eppic$area,eppic$cr)
#   } else if (input$dist == 'cs'){
#     data<-data.frame(eppic$area,eppic$cs)
#   } else {
#     data<-data.frame(eppic$area,eppic$final)
#   }
  
  
  # Generate a plot of the data. Also uses the inputs to build
  # the plot label. Note that the dependencies on both the inputs
  # and the data reactive expression are both tracked, and
  # all expressions are called in the sequence implied by the
  # dependency graph

  output$plot <- renderPlot({
    ggplot(d())+
      geom_density(aes(x=area,color=call,fill=call),binwidth=input$n,position='identity',alpha=0.5)+
      xlim(0,5000)
  })
  
  # Generate a summary of the data
  output$summary <- renderPrint({
    summary(d())
  })
  
  # Generate an HTML table view of the data
  output$table <- renderTable({
   head(d())
  })
  
})