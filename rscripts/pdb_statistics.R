setwd('~/pdb_statistics/')
library(RMySQL)
library(ggplot2)


mydb=dbConnect(MySQL(),host=,username=,password=,dbname="crk_2014_01")
on.exit(dbDisconnect(mydb))

allpdb=dbSendQuery(mydb,"select pdbName,expMethod,resolution,spaceGroup,overall from detailedView group by pdbName;")
pdbdat=fetch(allpdb,-1)

allint=dbSendQuery(mydb,"select pdbName,expMethod,resolution,chain1,chain2,spaceGroup,operatorType,area,isInfinite,
size1+size2 size,cr1,cr2,crScore,cs1,cs2,csScore,geometry go,cr,cs,final,overall
from detailedView")
intdat=fetch(allint,-1)

#res=dbSendQuery(mydb,"select residueType,assignment,entropyScore from InterfaceResidue where residueType in ('ALA','ARG','ASN','ASP','CYS','GLU','GLN','GLY','HIS','ILE','LEU','LYS','MET','PHE','PRO','SER','THR','TRP','TYR','VAL') group by residueType,assignment;")

pdbcount=dbSendQuery(mydb,"select p.expMethod,get_final_call(p.uid) final,count(*) count from PdbScore as p inner join Job as j on j.uid=p.jobItem_uid where length(j.jobId)=4 group by p.expMethod,get_final_call(p.uid)")
pdbcount_dat=fetch(pdbcount,-1)

pdbcount_dat$pred=ifelse(pdbcount_dat$final=="xtal","Monomer","Multimer")

pdbdat$pred=ifelse(pdbdat$overall=="xtal","Monomer","Multimer")
pdbxray<-subset(pdbdat,(expMethod=="X-RAY DIFFRACTION"))
pdbxray$com=ifelse(pdbxray$overall=="xtal","Monomer","Multimer")
intxray<-subset(intdat,(expMethod=="X-RAY DIFFRACTION"))
predxray<-subset(intxray,(cr!="nopred" & cs!="nopred" & crScore>0 & crScore<50 & csScore>-50 & csScore<50))
predxray2<-subset(predxray,(size>0 & size<50 & area>0 & area<5000))

plot0a=ggplot(pdbcount_dat)+ggtitle('PDB wide monomer and multimer distribution')+
  geom_bar(aes(x=expMethod,y=count,color=pred,fill=pred))+theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+scale_fill_manual(values=c("red","green"))+scale_color_manual(values=c("red","green"))
plot0b=ggplot(pdbcount_dat)+facet_wrap(~expMethod,scales="free_y")+ggtitle('PDB wide monomer and multimer distribution')+
  geom_bar(aes(x=pred,y=count,color=pred,fill=pred))+scale_fill_manual(values=c("red","green"))+scale_color_manual(values=c("red","green"))
plot1=ggplot(pdbxray)+facet_wrap(~spaceGroup,scales="free_y")+ggtitle('PDB wide monomer and multimer distribution in different space groups')+
  geom_bar(aes(x=com,color=com,fill=com))+scale_fill_manual(values=c("red","green"))+scale_color_manual(values=c("red","green"))


plot1a=ggplot(pdbxray)+ggtitle('PDB wide monomer and multimer distribution in different space groups')+
  geom_bar(aes(x=spaceGroup,color=com,fill=com))+theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+scale_fill_manual(values=c("red","green"))+scale_color_manual(values=c("red","green"))

plot2=ggplot(intxray)+facet_wrap(~operatorType,scales="free_y")+ggtitle('Interface distribution in different operator type')+
  geom_bar(aes(x=final,color=final,fill=final))+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"))

plot2a=ggplot(intxray)+ggtitle('Interface distribution in different operator type')+
  geom_bar(aes(x=operatorType,color=final,fill=final))+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"))

plot3=ggplot(intxray)+facet_wrap(~spaceGroup,scales="free_y")+ggtitle('Interface distribution in different spacegroup and operator type')+
  geom_bar(aes(x=operatorType,color=final,fill=final))+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"))

plot3a=ggplot(intxray)+facet_wrap(~spaceGroup,scales="free_y")+ggtitle('Interface distribution in different spacegroup and operator type')+
  geom_bar(aes(x=operatorType,color=final,fill=final))+theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"))

plot4=ggplot(predxray)+facet_wrap(~operatorType)+ggtitle('Correlation between core-rim and core-sureface scores in different operator types')+
  geom_point(aes(x=crScore,y=csScore,color=final,fill=final))+
  geom_vline(aes(xintercept=0.75), linetype=1)+
  geom_hline(aes(yintercept=-1.0), linetype=1)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"))


plot5=ggplot(predxray)+facet_wrap(~operatorType)+ggtitle('Correlation between core-rim scores on two sides of the interface')+
  geom_point(aes(x=cr1,y=cr2,color=cr,fill=cr))+
  geom_vline(aes(xintercept=0.75), linetype=1)+
  geom_hline(aes(yintercept=0.75), linetype=1)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"))

plot6=ggplot(predxray2)+facet_wrap(~operatorType)+ggtitle('Correlation between core-sureface scores on two sides of the interface')+
  geom_point(aes(x=cs1,y=cs2,color=cs,fill=cs))+
  geom_vline(aes(xintercept=-1), linetype=1)+
  geom_hline(aes(yintercept=-1), linetype=1)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"))

plot7=ggplot(intxray)+facet_wrap(~operatorType)+ggtitle('Area vs Core residues distribution in different operator type')+
  geom_point(aes(x=area,y=size,color=final,fill=final))+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"))
plot8=ggplot(intxray)+facet_wrap(~operatorType)+ggtitle('Area vs Core residues distribution in different operator type(with filter size=1~50 and area=0~5000')+
  geom_point(aes(x=area,y=size,color=final,fill=final))+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"))



jpeg("pdb_monoer_multimer_a.jpg",width=1200,height=800)
plot0a
dev.off()
jpeg("pdb_monoer_multimer_b.jpg")
plot0b
dev.off()

jpeg("pdb_monoer_multimer_spacegroup_a.jpg",width=1200,height=800)
plot1a
dev.off()
jpeg("Interface_operator_a.jpg",width=1200,height=800)
plot2a
dev.off()

jpeg("Interface_space_operator_a.jpg",width=1200,height=1200)
plot3a
dev.off()


jpeg("cr_cs.jpg",width=1200,height=1200)
plot4
dev.off()
jpeg("cr.jpg",width=1200,height=1200)
plot5
dev.off()
jpeg("cs.jpg",width=1200,height=1200)
plot6
dev.off()
jpeg("area_core.jpg",width=1200,height=1200)
plot7
dev.off()
jpeg("area_core_zoom.jpg",width=1200,height=1200)
plot8
dev.off()


