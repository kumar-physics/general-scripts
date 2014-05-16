setwd('~/pdbstatistics/')
library(RMySQL)
library(ggplot2)


mydb=dbConnect(MySQL(),host=,username=,password=,dbname="eppic_test_2_1_0")
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
  
  bio$benchmark=sprintf("%s(%d,%d)",db,length(bio$pdbCode),length(xtal$pdbCode))
  xtal$benchmark=sprintf("%s(%d,%d)",db,length(bio$pdbCode),length(xtal$pdbCode))
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
colnames(d)[55]='dataset'
d1=subset(d,cs!='nopred')
d2=subset(d,cs!='nopred' & final!=truth)

plot1 = ggplot(d) + facet_wrap(~dataset)+geom_histogram(aes(x=area,fill=truth),binwidth=100,position='identity',alpha=0.5)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red")); plot1
plot1a = ggplot(d) + facet_wrap(~dataset,scale='free')+geom_histogram(aes(x=area,fill=truth),binwidth=100,position='identity',alpha=0.5)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red")); plot1a

plot2 = ggplot(d1) + facet_wrap(~dataset,scale='free')+geom_point(aes(x=area,y=csScore,color=truth,fill=truth,shape=final),size=5.0,alpha=0.5)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red")); plot2
plot2a = ggplot(d2) + facet_wrap(~dataset,scale='free')+geom_point(aes(x=area,y=csScore,color=truth,fill=truth,shape=final),size=5.0,alpha=0.5)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red")); plot2a

plot3 = ggplot(d) + facet_wrap(~dataset)+geom_density(aes(x=area,color=truth,fill=truth),position='identity',alpha=0.5)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red")); plot3
plot3a = ggplot(d) + facet_wrap(~dataset,scale='free')+geom_density(aes(x=area,color=truth,fill=truth),position='identity',alpha=0.5)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red")); plot3a



pdf('area_dist.pdf')
plot1
dev.off()

pdf('area_dist_free.pdf')
plot1a
dev.off()

pdf('area_density.pdf')
plot3
dev.off()

pdf('area_density_free.pdf')
plot3a
dev.off()

pdf('resulst_scatter.pdf')
plot2
dev.off()

pdf('error_scatter.pdf')
plot2a
dev.off()



