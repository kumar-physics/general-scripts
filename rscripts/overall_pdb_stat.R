setwd('~/pdbstatistics/')
library(RMySQL)
library(ggplot2)


mydb=dbConnect(MySQL(),host=,username=,password=,dbname="eppic_test_2_1_0")
on.exit(dbDisconnect(mydb))

d=fetch(dbSendQuery(mydb,sprintf("select * from detailedTable;")),n=-1)
d2=subset(d,gmScore>0)
plot1=ggplot(d,aes(x=area,fill=final))+geom_line(aes(color=final),stat="Density",kernel="opt")+geom_histogram(aes(y=..density..),alpha=.5,position="Identity",binwidth=200)+scale_color_manual(values=c("green","red"))+scale_fill_manual(values=c("green","red"))+xlim(0,5000);plot1

d1=subset(d,cs!='nopred' & cr != 'nopred' & cs == cr)
plot2=ggplot(d1)+geom_density(aes(x=area,color=final,fill=final),binwidth=200,alpha=0.5)+scale_color_manual(values=c("green","red"))+scale_fill_manual(values=c("green","red"))+xlim(0,5000);plot2
plot2a=ggplot(d1,aes(x=area,fill=final))+geom_line(aes(color=final),stat="Density",kernel="opt")+geom_histogram(aes(y=..density..),alpha=.5,position="Identity",binwidth=200)+scale_color_manual(values=c("green","red"))+scale_fill_manual(values=c("green","red"))+xlim(0,5000);plot2a

plot3=ggplot(d,aes(x=gmScore,fill=final))+geom_histogram(aes(y=..density..),alpha=.5,position="Identity",binwidth=1)+scale_color_manual(values=c("green","red"))+scale_fill_manual(values=c("green","red"))+xlim(0,50);plot3

plot12 = ggplot(subset(d,gmScore>0), aes(x=area,y=gmScore,color=final)) + geom_density2d() + ggtitle("Area vs. core size of EPPIC predictions") + ylab("Total Core Size (Res)") +scale_fill_manual(values=c("green","red")); plot12

plot13 = ggplot(subset(d,gmScore>0), aes(x=area,y=gmScore,color=final)) + stat_binhex() + facet_grid(.~final) + ggtitle("Area vs. core size of EPPIC predictions") + ylab("Total Core Size (Res)") +scale_color_manual(values=c("green","red"))+); plot13

pdf('area_dist.pdf')
plot1
dev.off()
pdf('core_dist.pdf')
plot3
dev.off()

pdf('contour.pdf')
plot12
dev.off()

