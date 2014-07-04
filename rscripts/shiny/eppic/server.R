library(shiny)
library(ggplot2)
library(RMySQL)
#dbconnection
library(gridExtra)
# Define server logic for random distribution application
shinyServer(function(input, output) {
  mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05") #~/.my.cnf file configured with right username and passwd
  on.exit(dbDisconnect(mydb))
  xt=fetch(dbSendQuery(mydb,"select * from dc_xtal where 
                       crScore<50 and crScore>=0 and csScore<50 and csScore>=-50"),-1)
  bo=fetch(dbSendQuery(mydb,"select * from dc_bio where
                       crScore<50 and crScore>=0 and csScore<50 and csScore>=-50"),-1)
  xt$truth='xtal'
  bo$truth='bio'
  ep=rbind(xt,bo)
  dat <- reactive({
#     switch(input$dist,
#            gm = data.frame(area=ep$area,call=ep$gm),
#            cr =data.frame(area=ep$area,call=ep$cr),
#            cs = data.frame(area=ep$area,call=ep$cs),
#            final = data.frame(area=ep$area,call=ep$final),
#            data.frame(area=ep$area,call=ep$gm))
    data.frame(area=ep$area,s=1/(1+exp(-1*(-2.5+ep$gmScore*input$w1+
                 ep$area*input$w2+
                 ep$csScore*input$w3))),truth=ep$truth,final=ep$final)
    
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
#   dat=data.frame(area=ep$area,s=ep$gmScore*ep$area*input$w1+
#                    ep$crScore*ep$area*input$w2+
#                    ep$csScore*ep$area*input$w3,truth=ep$truth,final=ep$final)
  output$plot <- renderPlot({
    ggplot(dat())+
      geom_point(aes(x=area,y=s,color=truth,shape=final),alpha=0.5)
  })
  
  # Generate a summary of the data
  output$summary <- renderPrint({
    summary(dat())
  })
  
  # Generate an HTML table view of the data
  output$table <- renderTable({
   head(dat())
  })
  
})