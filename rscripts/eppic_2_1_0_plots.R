setwd('~/pdb_statistics/')
library(RMySQL)
library(ggplot2)
library(MASS)
mydb=dbConnect(MySQL(),dbname="eppic_test_2_1_0")
on.exit(dbDisconnect(mydb))

pdb=fetch(dbSendQuery(mydb,"select p.* from PdbInfo as p 
                          inner join Job as j on p.job_uid=j.uid 
                          where j.inputType=0;"),-1)
exp=fetch(dbSendQuery(mydb,"select p.expMethod,p.assembly,count(*)  count from PdbInfo as p
                      inner join Job as j on p.job_uid=j.uid
                      where p.expMethod is not NULL and
                      j.inputType=0 group by p.expMethod,p.assembly order by count(*) desc;"),-1)
spacegroup=fetch(dbSendQuery(mydb,"select p.spaceGroup,p.assembly,count(*) count from PdbInfo as p
                      inner join Job as j on p.job_uid=j.uid
                      where p.spaceGroup is not NULL and
                      j.inputType=0 group by p.spaceGroup,p.assembly order by count(*) desc;"),-1)

eppic=fetch(dbSendQuery(mydb,"select * from EppicTable;"),-1)
op=fetch(dbSendQuery(mydb,"select operatorType,final,count(*) count from EppicTable where operatorType is not NULL group by operatorType,final;"),-1)
eppic2=subset(eppic,gmScore>0,select =c(area,gmScore,final))

areavscore=ggplot(eppic2)+
  geom_density2d(aes(x=area,y=gmScore,color=final),bins=5000,alpha=0.5)+
  scale_color_manual(values=c("green","red"),name="Eppic final")+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of core residues');areavscore

areaplot=ggplot(subset(eppic,area<=5000),aes(x=area))+
  geom_histogram(aes(color=final,fill=final),binwidth=100,alpha=0.5,position="identity")+
  scale_color_manual(values=c("green","red"),name="Eppic final")+
  scale_fill_manual(values=c("green","red"),name="Eppic final")+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Count');areaplot

exp2=transform(exp, expMethod = reorder(expMethod, -count))
expplot=ggplot(exp2,aes(x=expMethod,y=count))+
  geom_bar(aes(color=assembly,fill=assembly),alpha=0.5)+
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+
  scale_color_manual(values=c("red","green"),name="Assembly")+
  scale_fill_manual(values=c("red","green"),name="Assembly")+
  xlab('Experimental techniqe')+
  ylab('Count');expplot

spacegroup2=transform(spacegroup, spaceGroup = reorder(spaceGroup, -count))
spacegroupplot=ggplot(spacegroup2,aes(x=spaceGroup,y=count))+
  geom_bar(aes(color=assembly,fill=assembly),alpha=0.5)+
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+
  scale_color_manual(values=c("red","green"),name="Assembly")+
  scale_fill_manual(values=c("red","green"),name="Assembly")+
  xlab('Space group')+
  ylab('Count');spacegroupplot


op2=transform(op, operatorType = reorder(operatorType, -count))
opplot=ggplot(op2,aes(x=operatorType,y=count))+
  geom_bar(aes(color=final,fill=final),alpha=0.5)+
  scale_color_manual(values=c("green","red"),name="Eppic final")+
  scale_fill_manual(values=c("green","red"),name="Eppic final")+
  xlab('Operator type')+
  ylab('Count');opplot




jpeg("exp_stat.jpg",width=1200,height=800)
expplot
dev.off()
