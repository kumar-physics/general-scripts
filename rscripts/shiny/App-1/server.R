library(shiny)
library(ggplot2)
library(RMySQL)
#dbconnection
library(gridExtra)

shinyServer(function(input, output) {
  if(system("hostname",intern=T) == "delilah.psi.ch") { #spencer's system
    system("ssh -fN -L 3307:localhost:3306 -o ExitOnForwardFailure=yes mpc")
    mydb = dbConnect(MySQL(),group = "client_mpc",dbname="eppic_2_1_0_2014_05")
  } else {
    mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05") #~/.my.cnf file configured with right username and passwd
  }
  on.exit(dbDisconnect(mydb))
  ep=fetch(dbSendQuery(mydb,"select pdbCode,interfaceId,area,gmScore,gm,crScore,
                       cr,csScore,cs,final,pisa,authors,pqs from EppicTable 
                       where resolution<2.5 and rfreeValue<0.3 and resolution>0 
                       and h1>30 and h2>30 and cs!='nopred' and cr!='nopred' and 
                       cs=cr and cs=gm and authors is not NULL 
                       and get_chainlength(pdbCode,chain1)>50 and 
                       get_chainlength(pdbCode,chain2)>50 order by csScore " ),-1)
 
  ep$res='novalue'
  ep$res[ep$final=='xtal' & ep$authors=='xtal']='xtal xtal'
  ep$res[ep$final=='xtal' & ep$authors=='bio']='xtal bio'
  ep$res[ep$final=='bio' & ep$authors=='xtal']='bio xtal'
  ep$res[ep$final=='bio' & ep$authors=='bio']='bio bio'
  ep$res<-factor(ep$res,levels=c('xtal xtal','bio bio','xtal bio','bio xtal'))
  output$distPlot <- renderPlot({
   ep2=rbind(ep[1:input$bins/2,],ep[(dim(ep)[1]-input$bins/2):dim(ep)[1],])
   s<-dim(ep2)[1]
   xx<-(dim(subset(ep2,ep2$res=='xtal xtal')[1])/s)*100
   bb<-(dim(subset(ep2,ep2$res=='bio bio')[1])/s)*100
   xb<-(dim(subset(ep2,ep2$res=='xtal bio')[1])/s)*100
   bx<-(dim(subset(ep2,ep2$res=='bio xtal')[1])/s)*100
   
   # bins <- seq(min(ep$area), max(ep$area), length.out = input$bins + 1)
    # draw the histogram with the specified number of bins
   p1<-ggplot(ep2)+
     geom_bar(aes(x=area,fill=res),stat='bin',binwidth=200,position='identity',alpha=.5)+
     ggtitle(sprintf("xx=%.2f ,bb=%.2f ,xb=%.2f ,bx=%.2f acc=%.2f",xx,bb,xb,bx,xx+bb))+
     xlim(0,5000)
    p2<-ggplot(ep2)+
     geom_bar(aes(x=csScore,fill=cs),stat='bin',binwidth=0.2,position='identity',alpha=.5)
   grid.arrange(p1, p2)
  })
})
