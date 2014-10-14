library(shiny)
library(ggplot2)
library(RMySQL)
library(zoo)
library(plyr)
#dbconnection
library(gridExtra)
# Define server logic for random distribution application
roc = function(score,truth,tag,dat=NA){
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
  for (i in 1:length(d$score)){
    tp=subset(count(subset(d,score<=d$score[i]),'truth'),truth=='bio')$freq
    tn=subset(count(subset(d,score>d$score[i]),'truth'),truth=='xtal')$freq
    if (length(tn)==0){
      tn=0
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
  
  
#   dat <- reactive({
# #     switch(input$dist,
# #            gm = data.frame(area=ep$area,call=ep$gm),
# #            cr =data.frame(area=ep$area,call=ep$cr),
# #            cs = data.frame(area=ep$area,call=ep$cs),
# #            final = data.frame(area=ep$area,call=ep$final),
# #            data.frame(area=ep$area,call=ep$gm))
#     data.frame(area=test$area,s=1/(1+exp(-1*(coef(bm)["(Intercept)"]+
#                                              test$gmScore*coef(bm)["gmScore"]+
#                                              test$crScore*coef(bm)["crScore"]+
#                                              test$csScore*coef(bm)["csScore"]))),
#                truth=test$truth,final=test$final)
#     
#   })
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
    mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05") #~/.my.cnf file configured with right username and passwd
    on.exit(dbDisconnect(mydb))
    xt=fetch(dbSendQuery(mydb,sprintf("select * from %s_xtal where 
                       crScore<50 and crScore>=0 and csScore<50 and csScore>=-50",input$train)),-1)
    bo=fetch(dbSendQuery(mydb,sprintf("select * from %s_bio where
                       crScore<50 and crScore>=0 and csScore<50 and csScore>=-50",input$train)),-1)
    
    
    xt$truthv=0
    bo$truthv=1
    xt$truth='xtal'
    bo$truth='bio'
    train=rbind(xt,bo)
    bm <- glm(truthv ~ gmScore + crScore + csScore, data = train, family = "binomial")
    xt2=fetch(dbSendQuery(mydb,sprintf("select * from %s_xtal where 
                       crScore<50 and crScore>=0 and csScore<50 and csScore>=-50",input$test)),-1)
    bo2=fetch(dbSendQuery(mydb,sprintf("select * from %s_bio where
                       crScore<50 and crScore>=0 and csScore<50 and csScore>=-50",input$test)),-1)
    
    xt2$truth='xtal'
    bo2$truth='bio'
    test=rbind(xt2,bo2)
    dat<-data.frame(area=test$area,s=1/(1+exp(-1*(coef(bm)["(Intercept)"]+
                                                    test$gmScore*coef(bm)["gmScore"]+
                                                    test$crScore*coef(bm)["crScore"]+
                                                    test$csScore*coef(bm)["csScore"]))),
                    truth=test$truth,final=test$final)
    rocdat<-roc_gm(dat$s,dat$truth,input$test)
    rocgm<-roc_gm(test$gmScore,test$truth,input$test)
    roccr<-roc(test$crScore,test$truth,input$test)
    roccs<-roc(test$csScore,test$truth,input$test)
    x<-1-rocdat$specificity
    y<-rocdat$sensitivity
    id <- order(x)
    auc<-sum(diff(x[id])*rollmean(y[id],2))
    x<-1-rocgm$specificity
    y<-rocgm$sensitivity
    id <- order(x)
    aucgm<-sum(diff(x[id])*rollmean(y[id],2))
    x<-1-roccr$specificity
    y<-roccr$sensitivity
    id <- order(x)
    auccr<-sum(diff(x[id])*rollmean(y[id],2))
    x<-1-roccs$specificity
    y<-roccs$sensitivity
    id <- order(x)
    auccs<-sum(diff(x[id])*rollmean(y[id],2))
    p1<-ggplot(rocdat)+
    geom_line(aes(x=1-specificity,y=sensitivity,color=dataset),size=1.0)+
      xlim(0,1)+
      ylim(0,1)+ggtitle(sprintf("Area unter the curve(S) = %.2f",auc))
    p2<-ggplot(rocgm)+
      geom_line(aes(x=1-specificity,y=sensitivity,color=dataset),size=1.0)+
      xlim(0,1)+
      ylim(0,1)+ggtitle(sprintf("Area unter the curve(GM) = %.2f",aucgm))
    p3<-ggplot(roccr)+
      geom_line(aes(x=1-specificity,y=sensitivity,color=dataset),size=1.0)+
      xlim(0,1)+
      ylim(0,1)+ggtitle(sprintf("Area unter the curve(CR) = %.2f",auccr))
    p4<-ggplot(roccs)+
      geom_line(aes(x=1-specificity,y=sensitivity,color=dataset),size=1.0)+
      xlim(0,1)+
      ylim(0,1)+ggtitle(sprintf("Area unter the curve(CS) = %.2f",auccs))
    output$summary <- renderPrint({
      summary(bm)
    })
    output$confint <- renderPrint({
      confint(bm)
    })
    p5<-ggplot(dat)+
      geom_point(aes(x=area,y=s,color=truth,shape=final),alpha=0.5)+
      ggtitle(sprintf("GM=%.2f,CR=%.2f,CS=%.2f",coef(bm)["gmScore"],coef(bm)["crScore"],coef(bm)["csScore"]))
    grid.arrange(p1,p2,p3,p4)
  })
  
  # Generate a summary of the data
 
  
  # Generate an HTML table view of the data
#   output$table <- renderTable({
#    head(dat)
#   })
  
})