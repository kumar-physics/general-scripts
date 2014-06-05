setwd('~/pdb_statistics/plots/')
library(RMySQL)
library(ggplot2)

mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05")
on.exit(dbDisconnect(mydb))

pdb=fetch(dbSendQuery(mydb,"select p.* from PdbInfo as p 
                          inner join Job as j on p.job_uid=j.uid 
                          where j.inputType=0;"),-1)
exp=fetch(dbSendQuery(mydb,"select p.expMethod,assembly(p.pdbCode) assembly,count(*)  count from PdbInfo as p
                      inner join Job as j on p.job_uid=j.uid
                      where p.expMethod is not NULL and
                      j.inputType=0 group by p.expMethod,assembly(p.pdbCode) order by count(*) desc;"),-1)
spacegroup=fetch(dbSendQuery(mydb,"select p.spaceGroup,assembly(p.pdbCode) assembly,count(*) count from PdbInfo as p
                      inner join Job as j on p.job_uid=j.uid
                      where p.spaceGroup is not NULL and
                      j.inputType=0 group by p.spaceGroup,assembly(p.pdbCode) order by count(*) desc;"),-1)

eppic=fetch(dbSendQuery(mydb,"select * from EppicTable;"),-1)
infinite=fetch(dbSendQuery(mydb,"select pdbCode,interfaceId,area from EppicTable where infinite=1 and area>350;"),-1)

op=fetch(dbSendQuery(mydb,"select operatorType,final,count(*) count from EppicTable where operatorType is not NULL group by operatorType,final;"),-1)




# chain=fetch(dbSendQuery(mydb,"select p.pdbCode,c.repChain,c.numHomologs,c.seqIdCutoff from ChainCluster as c 
# inner join PdbInfo as p on p.uid=c.pdbInfo_uid inner join 
# Job as j on j.uid=p.job_uid where length(j.jobId)=4 and c.hasUniProtRef"),-1)
# 
# chainplot=ggplot(subset(chain,seqIdCutoff>0.45))+
#   geom_line(aes(x=numHomologs,y=100-cumsum((..count../sum(..count..))*100)),stat='bin',binwidth=5)+
#   xlim(0,150)+
#   geom_vline(xintercept = 10)+
#   geom_vline(xintercept = 30)+
#   geom_vline(xintercept = 50);chainplot


eppic2=subset(eppic,gmScore>0,select =c(area,gmScore,final))
areavscore=ggplot(eppic2)+
  geom_density2d(aes(x=area,y=gmScore,color=final),bins=5000,alpha=0.5)+
  scale_color_manual(values=c("green","red"),name="Eppic final")+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of core residues')+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA));areavscore

areaplot=ggplot(subset(eppic,area<=5000),aes(x=area))+
  geom_histogram(aes(fill=final),binwidth=100,alpha=0.5,position="identity")+
  scale_color_manual(values=c("green","red"),name="Eppic final")+
  scale_fill_manual(values=c("green","red"),name="Eppic final")+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of interfaces')+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA));areaplot


coreplot=ggplot(subset(eppic,area<=5000 & gmScore>0),aes(x=gmScore))+
  geom_histogram(aes(fill=final),binwidth=1,alpha=0.5,position="identity")+
  scale_color_manual(values=c("green","red"),name="Eppic final")+
  scale_fill_manual(values=c("green","red"),name="Eppic final")+
  xlab('Number of core residues')+
  ylab('Number of interfaces')+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA));coreplot


exp2=transform(exp, expMethod = reorder(expMethod, -count))
expplot=ggplot(exp2)+
  geom_bar(aes(x=expMethod,y=count,fill=assembly),alpha=0.5,position="dodge",stat='identity')+
  scale_fill_manual(values=c("red","green"),name="Assembly")+
  scale_color_manual(values=c("red","green"),name="Assembly")+
  xlab('')+
  ylab('Number of PDBs')+
  geom_text(aes(color=assembly,group=assembly,x=expMethod,y=count,label=count),position=position_dodge(1.0),vjust=-0.5)+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA));expplot

spacegroup2=transform(spacegroup, spaceGroup = reorder(spaceGroup, -count))
spacegroupplot=ggplot(spacegroup2,aes(x=spaceGroup,y=count))+
  geom_bar(aes(fill=assembly),alpha=0.5)+
  scale_color_manual(values=c("red","green"),name="Assembly")+
  scale_fill_manual(values=c("red","green"),name="Assembly")+
  xlab('Space group')+
  ylab('Number of PDBs')+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA));spacegroupplot



op2=transform(op, operatorType = reorder(operatorType, -count))
opplot=ggplot(op2,aes(x=operatorType,y=count))+
  geom_bar(aes(fill=final),alpha=0.5)+
  scale_color_manual(values=c("green","red"),name="Eppic final")+
  scale_fill_manual(values=c("green","red"),name="Eppic final")+
  xlab('Operator type')+
  ylab('Count')+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA));opplot



janin<-function(x){0.016*exp(-x/260)}
janindata<-data.frame(area=0:2500,density=janin(0:2500),'Janin')
janindata=rbind(janindata,subset(infinite,select=c(a)))


janinplot=ggplot()+
  geom_line(data=janindata,aes(x=area,y=density,color='Janin'),size=1.0)+
  geom_line(data=infinite,aes(x=area,y=..density..,color='Infinite assemblies'),stat='density',size=1.0)+
  geom_line(data=subset(eppic,cs=='xtal' & cr=='xtal' & area>350),aes(x=area,y=..density..,color='Xtal based on evolution'),stat='density',size=1.0)+
  geom_line(data=subset(eppic,gm=='xtal' & area>350),aes(x=area,y=..density..,color='Xtal based on geometry'),stat='density',size=1.0)+
  ylim(0,0.006)+xlim(0,2500)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab("Probability")+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.title=element_blank(),
        legend.position='bottom');janinplot


jpeg("janin.jpg",width=800,height=600)
janinplot
dev.off()
jpeg("area_vs_core.jpg",width=1200,height=800)
areavscore
dev.off()
jpeg("area_hist.jpg",width=1200,height=800)
areaplot
dev.off()
jpeg("core_hist.jpg",width=1200,height=800)
coreplot
dev.off()
jpeg("exp_stat.jpg",width=1200,height=800)
expplot
dev.off()
jpeg("spacegroup.jpg",width=1200,height=800)
spacegroupplot
dev.off()
jpeg("operatortype.jpg",width=1200,height=800)
opplot
dev.off()