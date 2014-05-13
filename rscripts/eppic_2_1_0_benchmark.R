setwd('~/pdbstatistics/')
library(RMySQL)
library(ggplot2)


mydb=dbConnect(MySQL(),host="mpc1153",username="root",password="edb+1153",dbname="eppic_test_2_1_0")
on.exit(dbDisconnect(mydb))

loadBenchmark = function(db, #database name
                         db_bio=paste(db,"_bio",sep=""), # bio db name
                         db_xtal=paste(db,"_xtal",sep=""), # xtal db name
                         data=NA #dataframe returned from previous call
)
{
  result=dbSendQuery(mydb,sprintf("select * from %s;",db_bio))
  bio=fetch(result,n=-1)
  result=dbSendQuery(mydb,sprintf("select * from %s;",db_xtal))
  xtal=fetch(result,n=-1)
  
  bio$benchmark=db
  xtal$benchmark=db
  bio$truth="bio"
  xtal$truth="xtal"
  
  if (all(is.na(data))){
    data = rbind(bio,xtal)
  }else{
    data = rbind(data,bio,xtal)
  }
}
d=loadBenchmark('dc')
d=loadBenchmark('po',data=d)
d=loadBenchmark('many',data=d)
d1=subset(d,cs!='nopred')
plot1 = ggplot(d) + facet_wrap(~benchmark)+geom_histogram(aes(x=area,facet=benchmark,color=truth,fill=truth,binwidth=500),position='identity',alpha=0.5); plot1
plot1a = ggplot(d1) + facet_wrap(~benchmark)+geom_histogram(aes(x=area,facet=benchmark,color=truth,fill=truth,binwidth=500),position='identity',alpha=0.5); plot1a
plot1 = ggplot(d) + facet_wrap(~benchmark,scale='free')+geom_histogram(aes(x=area,color=truth,fill=truth),binwidth=100,position='identity',alpha=0.5); plot1
plot1a = ggplot(d1) + facet_wrap(~benchmark,scale='free')+geom_histogram(aes(x=area,color=truth,fill=truth),binwidth=100,position='identity',alpha=0.5); plot1a
plot2 = ggplot(d1) + facet_wrap(~benchmark,scale='free')+geom_point(aes(x=area,y=csScore,color=truth,fill=truth,shape=cs),position='identity',alpha=0.5,size=3.0); plot2
