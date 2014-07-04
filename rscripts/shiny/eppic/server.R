library(shiny)
library(ggplot2)
library(RMySQL)
library(zoo)
#dbconnection
library(gridExtra)
# Define server logic for random distribution application
roc_gm = function(score,truth,tag,dat=NA){
  cutoff<-NULL
  sensitivity<-NULL
  specificity<-NULL
  accuracy<-NULL
  dataset<-NULL
  mcc<-NULL
  s=data.frame(score,truth)
  attach(s)
  d<-s[order(score),]
  p=subset(count(d,'truth'),truth=='bio')$freq
  n=subset(count(d,'truth'),truth=='xtal')$freq
  for (i in length(d$score):1){
    tp=subset(count(subset(d,score>=d$score[i]),'truth'),truth=='bio')$freq
    tn=subset(count(subset(d,score<d$score[i]),'truth'),truth=='xtal')$freq
    if (length(tn)==0){
      tn=0
    }
    if (length(tp)==0){
      tp=0
    }
    fn=p-tp
    fp=n-tn
    dataset<-c(dataset,tag)
    cutoff<-c(cutoff,d$score[i])
    sensitivity<-c(sensitivity,tp/p)
    specificity<-c(specificity,tn/n)
    accuracy<-c(accuracy,(tp+tn)/(p+n))
    mcc<-c(mcc,(((tp*tn)-(fp*fn))/(sqrt(p)*sqrt(n)*sqrt(tp+fp)*sqrt(tn+fn))))
  }
  if (all(is.na(dat))){
    dat=data.frame(cutoff,sensitivity,specificity,accuracy,mcc,dataset)
  }else{
    dat=rbind(dat,data.frame(cutoff,sensitivity,specificity,accuracy,mcc,dataset))
  } 
}

shinyServer(function(input, output) {
  mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05") #~/.my.cnf file configured with right username and passwd
  on.exit(dbDisconnect(mydb))
  xt=fetch(dbSendQuery(mydb,"select * from many_xtal where 
                       crScore<50 and crScore>=0 and csScore<50 and csScore>=-50"),-1)
  bo=fetch(dbSendQuery(mydb,"select * from many_bio where
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
    data.frame(area=ep$area,s=1/(1+exp(-1*(-3.33+ep$gmScore*input$w1+
                 ep$crScore*input$w2+
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
    rocdat<-roc_gm(dat()$s,dat()$truth,'many')
    x<-1-rocdat$specificity
    y<-rocdat$sensitivity
    id <- order(x)
    auc<-sum(diff(x[id])*rollmean(y[id],2))
    p1<-ggplot(rocdat)+
    geom_line(aes(x=1-specificity,y=sensitivity,color=dataset),size=1.0)+
      xlim(0,1)+
      ylim(0,1)+ggtitle(auc)
    p2<-ggplot(dat())+
      geom_point(aes(x=area,y=s,color=truth,shape=final),alpha=0.5)
    grid.arrange(p1,p2)
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