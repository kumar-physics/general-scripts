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
  output$plot <- renderPlot({
    
    ggplot(ep)+
      geom_bar(aes(x=input$dist,color=final,fill=final))+
      theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5))
  })
  
  # Generate a summary of the data
  output$summary <- renderPrint({
    summary(ep)
  })
  
  # Generate an HTML table view of the data
  output$table <- renderTable({
   head(ep)
  })
  
})