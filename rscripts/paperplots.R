setwd('~/pdb_statistics/')
library(RMySQL)
library(ggplot2)


mydb=dbConnect(MySQL(),dbname="eppic_test_2_1_0")
on.exit(dbDisconnect(mydb))

pdb=fetch(dbSendQuery(mydb,"select p.* from PdbInfo as p 
                          inner join Job as j on p.job_uid=j.uid 
                          where j.inputType=0;"),-1)
pdb2=fetch(dbSendQuery(mydb,"select pdbCode,expMethod,resolution,rfreevalue,spaceGroup,assembly from detailedTable group by pdbCode;"),-1)
exp=fetch(dbSendQuery(mydb,"select expMethod,assembly,count(*) count from PdbInfo where expMethod is not NULL group by expMethod,assembly;"),-1)

interface=fetch(dbSendQuery(mydb,"select * from detailedTable;"),-1)

plot0a=ggplot(pdb2)+ggtitle('PDB wide monomer and multimer distribution')+
  geom_bar(facet=expMethod,aes(color=assembly,fill=assembly))+theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+scale_fill_manual(values=c("red","green"))+scale_color_manual(values=c("red","green"));plot0a
plot0a=ggplot(pdb2)+geom

plot0a=ggplot(exp)+ggtitle('PDB wide monomer and multimer distribution')+
  geom_bar(aes(x=expMethod,y=count,color=assembly,fill=assembly),alpha=0.5)+theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+scale_fill_manual(values=c("red","green"))+scale_color_manual(values=c("red","green"));plot0a

plot0b=ggplot(exp)+facet_wrap(~expMethod,scales="free_y")+ggtitle('PDB wide monomer and multimer distribution')+
  geom_bar(aes(x=assembly,y=count,color=assembly,fill=assembly),alpha=0.5)+scale_fill_manual(values=c("red","green"))+scale_color_manual(values=c("red","green"));plot0b

plot1=ggplot(subset(pdb,expMethod=="X-RAY DIFFRACTION"))+facet_wrap(~spaceGroup,scales="free_y")+ggtitle('PDB wide monomer and multimer distribution in different space groups')+
  geom_bar(aes(x=assembly,color=assembly,fill=assembly),alpha=0.5)+scale_fill_manual(values=c("red","green"))+scale_color_manual(values=c("red","green"));plot1

plot1a=ggplot(subset(pdb,expMethod=="X-RAY DIFFRACTION"))+ggtitle('PDB wide monomer and multimer distribution in different space groups')+
  geom_bar(aes(x=spaceGroup,color=assembly,fill=assembly),alpha=0.5)+theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+scale_fill_manual(values=c("red","green"))+scale_color_manual(values=c("red","green"));plot1a

plot2=ggplot(subset(interface,expMethod=="X-RAY DIFFRACTION"))+facet_wrap(~operatorType,scales="free_y")+ggtitle('Interface distribution in different operator type')+
  geom_bar(aes(x=final,color=final,fill=final),alpha=0.5)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"));plot2

plot2a=ggplot(subset(interface,expMethod=="X-RAY DIFFRACTION"))+
  ggtitle('Interface distribution in different operator type')+
  geom_bar(aes(x=operatorType,fill=final),alpha=0.5)+
  geom_text(aes(label=sprintf("%d/%d",
                          length((subset(interface,interface$expMethod=="X-RAY DIFFRACTION" & interface$operatorType==operatorType & interface$final=="bio"))$final),
                          length((subset(interface,interface$expMethod=="X-RAY DIFFRACTION" & interface$operatorType==operatorType & interface$final=="xtal"))$final)),
                x=operatorType,y=length((subset(interface,interface$expMethod==expMethod & interface$operatorType==operatorType & interface$final=="bio"))$final)+
                  length((subset(interface,interface$expMethod==expMethod & interface$operatorType==operatorType & interface$final=="xtal"))$final)))+
  scale_fill_manual(values=c("green","red"))+
  scale_color_manual(values=c("green","red"));plot2a

plot3=ggplot(subset(interface,expMethod=="X-RAY DIFFRACTION"))+facet_wrap(~spaceGroup,scales="free_y")+ggtitle('Interface distribution in different spacegroup and operator type')+
  geom_bar(aes(x=operatorType,fill=final),alpha=0.5)+scale_fill_manual(values=c("green","red"))+scale_color_manual(values=c("green","red"))+theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5));plot3


