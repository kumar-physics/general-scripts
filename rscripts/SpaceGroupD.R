#!/usr/bin/env Rscript
library(RMySQL)
library(ggplot2)
library(plyr)
library(reshape2)

attach_E=function(dat2,dat=NA){
  dat2$E[dat2$spaceGroup=="P 41"| dat2$spaceGroup=="P 43"]="E01"
  dat2$E[dat2$spaceGroup=="P 41 21 2"| dat2$spaceGroup=="P 43 21 2"]="E02"
  dat2$E[dat2$spaceGroup=="P 41 2 2"| dat2$spaceGroup=="P 43 2 2"]="E03"
  dat2$E[dat2$spaceGroup=="P 31"| dat2$spaceGroup=="P 32"]="E04"
  dat2$E[dat2$spaceGroup=="P 31 1 2"| dat2$spaceGroup=="P 32 1 2"]="E05"
  dat2$E[dat2$spaceGroup=="P 31 2 1"| dat2$spaceGroup=="P 32 2 1"]="E06"
  dat2$E[dat2$spaceGroup=="P 61"| dat2$spaceGroup=="P 65"]="E07"
  dat2$E[dat2$spaceGroup=="P 62"| dat2$spaceGroup=="P 64"]="E08"
  dat2$E[dat2$spaceGroup=="P 61 2 2"| dat2$spaceGroup=="P 65 2 2"]="E09"
  dat2$E[dat2$spaceGroup=="P 62 2 2"| dat2$spaceGroup=="P 64 2 2"]="E10"
  dat2$E[dat2$spaceGroup=="P 43 3 2"| dat2$spaceGroup=="P 41 3 2"]="E11"
  dat=subset(dat2,!(E=='NA') & !is.na(spaceGroup))
}
attach_E2=function(dat2,dat=NA){
  dat2$E2[dat2$spaceGroup=="P 41"]="E01_P 41"
  dat2$E2[dat2$spaceGroup=="P 43"]="E01_P 43"
  dat2$E2[dat2$spaceGroup=="P 41 21 2"]="E02_P 41 21 2"
  dat2$E2[dat2$spaceGroup=="P 43 21 2"]="E02_P 43 21 2"
  dat2$E2[dat2$spaceGroup=="P 41 2 2"]="E03_P 41 2 2"
  dat2$E2[dat2$spaceGroup=="P 43 2 2"]="E03_P 42 2 2"
  dat2$E2[dat2$spaceGroup=="P 31"]="E04_P 31"
  dat2$E2[dat2$spaceGroup=="P 32"]="E04_P 32"
  dat2$E2[dat2$spaceGroup=="P 31 1 2"]="E05_P 31 1 2"
  dat2$E2[dat2$spaceGroup=="P 32 1 2"]="E05_P 32 1 2"
  dat2$E2[dat2$spaceGroup=="P 31 2 1"]="E06_P 31 2 1"
  dat2$E2[dat2$spaceGroup=="P 32 2 1"]="E06_P 32 2 1"
  dat2$E2[dat2$spaceGroup=="P 61"]="E07_P 61"
  dat2$E2[dat2$spaceGroup=="P 65"]="E07_P 65"
  dat2$E2[dat2$spaceGroup=="P 62"]="E08_P 62"
  dat2$E2[dat2$spaceGroup=="P 64"]="E08_P 64"
  dat2$E2[dat2$spaceGroup=="P 61 2 2"]="E09_P 61 2 2"
  dat2$E2[dat2$spaceGroup=="P 65 2 2"]="E09_P 65 2 2"
  dat2$E2[dat2$spaceGroup=="P 62 2 2"]="E10_P 62 2 2"
  dat2$E2[dat2$spaceGroup=="P 64 2 2"]="E10_P 64 2 2"
  dat2$E2[dat2$spaceGroup=="P 43 3 2"]="E11_P 43 3 2"
  dat2$E2[dat2$spaceGroup=="P 41 3 2"]="E11_P_41 3 2"
  dat=subset(dat2,!(E2=='NA') & !is.na(spaceGroup))
}


attach_crystal_system=function(dat2,dat=NA){
  dat2$CS[dat2$spaceGroup=="P 1"]="Triclinic"
  dat2$CS[dat2$spaceGroup=='P 1 2 1'|
            dat2$spaceGroup=='P 1 21 1'|
            dat2$spaceGroup=='C 1 2 1'
            ]="Monoclinic"
  dat2$CS[dat2$spaceGroup=='P 2 2 2'|
            dat2$spaceGroup=='P 2 2 21'|
            dat2$spaceGroup=='P 21 21 2'|
            dat2$spaceGroup=='P 21 21 21'|
            dat2$spaceGroup=='C 2 2 2'|
            dat2$spaceGroup=='C 2 2 21'|
            dat2$spaceGroup=='F 2 2 2'|
            dat2$spaceGroup=='I 2 2 2'|
            dat2$spaceGroup=='I 21 21 21']="Orthorhombic"
  dat2$CS[dat2$spaceGroup=='P 4'|
            dat2$spaceGroup=='P 41'|
            dat2$spaceGroup=='P 42'|
            dat2$spaceGroup=='P 43'|
            dat2$spaceGroup=='P 4 2 2'|
            dat2$spaceGroup=='P 4 21 2'|
            dat2$spaceGroup=='P 41 2 2'|
            dat2$spaceGroup=='P 42 2 2'|
            dat2$spaceGroup=='P 43 2 2'|
            dat2$spaceGroup=='P 41 21 2'|
            dat2$spaceGroup=='P 42 21 2'|
            dat2$spaceGroup=='P 43 21 2'|
            dat2$spaceGroup=='I 4'|
            dat2$spaceGroup=='I 41'|
            dat2$spaceGroup=='I 4 2 2'|
            dat2$spaceGroup=='I 41 2 2']="Tetragonal"
  dat2$CS[dat2$spaceGroup=='P 2 3'|
            dat2$spaceGroup=='P 21 3'|
            dat2$spaceGroup=='P 4 3 2'|
            dat2$spaceGroup=='P 41 3 2'|
            dat2$spaceGroup=='P 42 3 2'|
            dat2$spaceGroup=='P 43 3 2'|
            dat2$spaceGroup=='F 2 3'|
            dat2$spaceGroup=='F 4 3 2'|
            dat2$spaceGroup=='F 41 3 2'|
            dat2$spaceGroup=='I 2 3'|
            dat2$spaceGroup=='I 21 3'|
            dat2$spaceGroup=='I 4 3 2'|
            dat2$spaceGroup=='I 41 3 2']="Cubic"
  dat2$CS[dat2$spaceGroup=='P 3'|
             dat2$spaceGroup=='P 31'|
             dat2$spaceGroup=='P 32'|
             dat2$spaceGroup=='P 3 2 1'|
             dat2$spaceGroup=='P 31 2 1'|
             dat2$spaceGroup=='P 32 2 1'|
             dat2$spaceGroup=='P 3 1 2'|
             dat2$spaceGroup=='P 31 1 2'|
             dat2$spaceGroup=='P 32 1 2'|
             dat2$spaceGroup=='P 6'|
             dat2$spaceGroup=='P 61'|
             dat2$spaceGroup=='P 62'|
             dat2$spaceGroup=='P 63'|
             dat2$spaceGroup=='P 64'|
             dat2$spaceGroup=='P 65'|
             dat2$spaceGroup=='P 6 2 2'|
             dat2$spaceGroup=='P 61 2 2'|
             dat2$spaceGroup=='P 62 2 2'|
             dat2$spaceGroup=='P 63 2 2'|
             dat2$spaceGroup=='P 64 2 2'|
             dat2$spaceGroup=='P 65 2 2'|
            dat2$spaceGroup=='R 3'|
            dat2$spaceGroup=='R 3 2'|
            dat2$spaceGroup=='H 3'|
            dat2$spaceGroup=='H 3 2']="Hexoganal"
  dat=dat2
}
attach_cell_type=function(dat2,dat=NA){
  dat2$CT=substr(dat$spaceGroup,1,1)
  dat=dat2
}

attach_D=function(dat2,lab,dat=NA){
  dat2$D[dat2$spaceGroup=='P 21 21 21']=7
  dat2$D[dat2$spaceGroup=='P 1 21 1' |
           dat2$spaceGroup=='C 1 2 1' |
           dat2$spaceGroup=='P 43 21 2' |
           dat2$spaceGroup=='P 31 2 1' |
           dat2$spaceGroup=='C 2 2 21' |
           dat2$spaceGroup=='P 21 21 2' |
           dat2$spaceGroup=='P 32 2 1' |
           dat2$spaceGroup=='P 61 2 2' |
           dat2$spaceGroup=='P 1' |
           dat2$spaceGroup=='P 65 2 2' |
           dat2$spaceGroup=='P 41 21 2' |
           dat2$spaceGroup=='I 2 2 2' |
           dat2$spaceGroup=='I 21 21 21'] = 6
  dat2$D[dat2$spaceGroup=='I 4' |
           dat2$spaceGroup=='P 61' |
           dat2$spaceGroup=='R 3' |
           dat2$spaceGroup=='H 3' |
           dat2$spaceGroup=='H 3 2' |
           dat2$spaceGroup=='R 3 2' |
           dat2$spaceGroup=='P 42 21 2' |
           dat2$spaceGroup=='P 31' |
           dat2$spaceGroup=='P 41' |
           dat2$spaceGroup=='P 43' |
           dat2$spaceGroup=='P 32' |
           dat2$spaceGroup=='P 6' |
           dat2$spaceGroup=='P 63' |
           dat2$spaceGroup=='P 65' |
           dat2$spaceGroup=='I 4 2 2' |
           dat2$spaceGroup=='P 31 1 2' |
           dat2$spaceGroup=='P 64 2 2' |
           dat2$spaceGroup=='R 32' |
           dat2$spaceGroup=='P 4 21 2' |
           dat2$spaceGroup=='P 41 2 2' |
           dat2$spaceGroup=='P 43 2 2' |
           dat2$spaceGroup=='I 41 2 2' |
           dat2$spaceGroup=='P 3 2 1' |
           dat2$spaceGroup=='P 32 1 2' |
           dat2$spaceGroup=='P 6 2 2' |
           dat2$spaceGroup=='P 62 2 2' |
           dat2$spaceGroup=='P 63 2 2' |
           dat2$spaceGroup=='I 41' |
           dat2$spaceGroup=='P 62' |
           dat2$spaceGroup=='P 64' |
           dat2$spaceGroup=='P 21 3' |
           dat2$spaceGroup=='I 2 3' |
           dat2$spaceGroup=='I 21 3' |
           dat2$spaceGroup=='P 41 3 2' |
           dat2$spaceGroup=='P 42 3 2' |
           dat2$spaceGroup=='P 43 3 2' |
           dat2$spaceGroup=='P 4 3 2' |
           dat2$spaceGroup=='I 4 3 2' |
           dat2$spaceGroup=='I 41 3 2' |
           dat2$spaceGroup=='F 4 3 2' |
           dat2$spaceGroup=='F 41 3 2' |
           dat2$spaceGroup=='P 2 2 21' |
           dat2$spaceGroup=='C 2 2 2' |
           dat2$spaceGroup=='F 2 2 2' |
           dat2$spaceGroup=='P 1 2 1'] = 5
  dat2$D[dat2$spaceGroup=='P 42' |
           dat2$spaceGroup=='P 4' |
           dat2$spaceGroup=='P 3' |
           dat2$spaceGroup=='P 2 3' |
           dat2$spaceGroup=='F 2 3' |
           dat2$spaceGroup=='P 3 1 2' |
           dat2$spaceGroup=='P 4 2 2' |
           dat2$spaceGroup=='P 42 2 2' |
           dat2$spaceGroup=='P 2 2 2'] = 4
  
  if (lab==1){
    dat2$D<-sprintf("%s",dat2$D)
  }
  dat=subset(dat2,!(D=='NA') & !is.na(spaceGroup))
}

attach_C=function(dat2,lab,dat=NA){
  dat2$C[dat2$spaceGroup=='P 21 21 21' |
           dat2$spaceGroup=='P 43 21 2' |
           dat2$spaceGroup=='P 31 2 1' |
           dat2$spaceGroup=='P 32 2 1' |
           dat2$spaceGroup=='P 61 2 2' |
           dat2$spaceGroup=='P 65 2 2' |
           dat2$spaceGroup=='P 41 21 2' |
           dat2$spaceGroup=='I 4' |
           dat2$spaceGroup=='P 61' |
           dat2$spaceGroup=='R 3' |
           dat2$spaceGroup=='H 3' |
           dat2$spaceGroup=='P 31' |
           dat2$spaceGroup=='P 41' |
           dat2$spaceGroup=='P 43' |
           dat2$spaceGroup=='P 32' |
           dat2$spaceGroup=='P 6' |
           dat2$spaceGroup=='P 63' |
           dat2$spaceGroup=='P 65' |
           dat2$spaceGroup=='I 41' |
           dat2$spaceGroup=='P 62' |
           dat2$spaceGroup=='P 64' |
           dat2$spaceGroup=='P 21 3' |
           dat2$spaceGroup=='I 2 3' |
           dat2$spaceGroup=='I 21 3' |
           dat2$spaceGroup=='P 41 3 2' |
           dat2$spaceGroup=='P 42 3 2' |
           dat2$spaceGroup=='P 43 3 2' |
           dat2$spaceGroup=='P 4 3 2' |
           dat2$spaceGroup=='I 4 3 2' |
           dat2$spaceGroup=='I 41 3 2' |
           dat2$spaceGroup=='F 4 3 2' |
           dat2$spaceGroup=='F 41 3 2' ]= 2
  dat2$C[dat2$spaceGroup=='P 1 21 1' |
           dat2$spaceGroup=='C 1 2 1' |
           dat2$spaceGroup=='C 2 2 21' |
           dat2$spaceGroup=='P 21 21 2' |
           dat2$spaceGroup=='P 1' |
           dat2$spaceGroup=='I 2 2 2' |
           dat2$spaceGroup=='I 21 21 21' |
           dat2$spaceGroup=='P 42 21 2' |
           dat2$spaceGroup=='I 4 2 2' |
           dat2$spaceGroup=='P 31 1 2' |
           dat2$spaceGroup=='P 64 2 2' |
           dat2$spaceGroup=='R 3 2' |
           dat2$spaceGroup=='H 3 2' |
           dat2$spaceGroup=='P 4 21 2' |
           dat2$spaceGroup=='P 41 2 2' |
           dat2$spaceGroup=='P 43 2 2' |
           dat2$spaceGroup=='I 41 2 2' |
           dat2$spaceGroup=='P 3 2 1' |
           dat2$spaceGroup=='P 32 1 2' |
           dat2$spaceGroup=='P 6 2 2' |
           dat2$spaceGroup=='P 62 2 2' |
           dat2$spaceGroup=='P 63 2 2' |
           dat2$spaceGroup=='P 42' |
           dat2$spaceGroup=='P 4' |
           dat2$spaceGroup=='P 3' |
           dat2$spaceGroup=='P 2 3' |
           dat2$spaceGroup=='F 2 3' ]=3
  dat2$C[dat2$spaceGroup=='P 2 2 21' |
           dat2$spaceGroup=='C 2 2 2' |
           dat2$spaceGroup=='F 2 2 2' |
           dat2$spaceGroup=='P 1 2 1' |
           dat2$spaceGroup=='P 3 1 2' |
           dat2$spaceGroup=='P 4 2 2' |
           dat2$spaceGroup=='P 42 2 2' ]=4
  dat2$C[dat2$spaceGroup=='P 2 2 2' ]=5
  if (lab==1){
    dat2$C=sprintf("%s",dat2$C)
  }
  dat=subset(dat2,!(C=='NA') & !is.na(spaceGroup))
}





plotframe=scale_y_continuous(breaks=-10:20)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

# function for number of observations 
give.n <- function(x){
  return(c(y = median(x)*1.01, label = length(x))) 
  # experiment with the multiplier to find the perfect position
}


# function for mean labels
mean.n <- function(x){
  return(c(y = median(x)*0.99, label = round(mean(x),2))) 
  # experiment with the multiplier to find the perfect position
}


dat=read.table('~/sp.dat',sep="\t")
colnames(dat)=c('pdb','spaceGroup','Contact35','Contact','SolventPDB','SolventPhenix','SolventPhenixNoWater')
d=attach_crystal_system(attach_C(attach_D(dat,1),1))


memdat=read.table('~/memb/sp2.dat',sep="\t")
colnames(memdat)=c('pdb','spaceGroup','SolventContent')
memdat2=attach_D(memdat,1)
memdat3=attach_C(memdat2,1)
memdat4=subset(memdat3,SolventContent>0 & SolventContent<90)
dd2=subset(dd,SolventPhenixNoWater>0 & SolventPhenixNoWater<95)

sgplot=ggplot(dd2,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot(aes(fill=D,color=C),notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');sgplot
memsgplot=ggplot(memdat4,aes(x=spaceGroup,y=SolventContent))+
  geom_boxplot(aes(fill=D,color=C))+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');memsgplot

Dplot=ggplot(subset(dd2,lattice!="R" & lattice!="H"),aes(x=lattice,y=SolventPhenixNoWater))+
  geom_boxplot(notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');Dplot

Dplot=ggplot(dd2,aes(x=D,y=SolventPhenixNoWater))+
  geom_boxplot(notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text",size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');Dplot

memDplot=ggplot(memdat4,aes(x=D,y=SolventContent))+
  geom_violin()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');memDplot


Cplot=ggplot(dd2,aes(x=C,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');Cplot

DCplot=ggplot(dd2,aes(x=D,y=SolventPhenixNoWater))+
  geom_boxplot(aes(fill=C,color=C))+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');DCplot


pdf("/afs/psi.ch/project/bioinfo2/kumaran/spacegroup/membsgboxplot.pdf")
memsgplot
dev.off()
pdf("/afs/psi.ch/project/bioinfo2/kumaran/spacegroup/latticeDboxplot.pdf")
Dplot
dev.off()
pdf("~/spacegroupplots/Cplot.pdf")
Cplot
dev.off()
pdf("~/spacegroupplots/DCplot.pdf")
DCplot
dev.off()
x2=attach_D(dat,0)
ddd2=attach_C(x2,0)
ddd3=subset(ddd2,SolventPhenixNoWater>0)

ggplot(dd2,aes(x=D,y=SolventPhenixNoWater))+
  geom_boxplot(color=C,fill=C)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom')




dd2=subset(dd,SolventPhenixNoWater>0 & SolventPhenixNoWater<95)
ggplot(dd2)+
  geom_boxplot(aes(x=spaceGroup,y=SolventPhenixNoWater,color='red'))+
  geom_boxplot(aes(x=spaceGroup,y=SolventPhenix,color='green'))+#scale_y_continuous(breaks=-10:20)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom')




p4143=subset(dd2,spaceGroup=="P 41" | spaceGroup == "P 43")
p4143plot=ggplot(p4143,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p4143plot
p4121243212=subset(dd2,spaceGroup=="P 41 21 2" | spaceGroup == "P 43 21 2")
p4121243212plot=ggplot(p4121243212,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p4121243212plot
p41224322=subset(dd2,spaceGroup=="P 41 2 2" | spaceGroup == "P 43 2 2")
p41224322plot=ggplot(p41224322,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p41224322plot
p3132=subset(dd2,spaceGroup=="P 31" | spaceGroup == "P 32")
p3132plot=ggplot(p3132,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p3132plot

p31123121=subset(dd2,spaceGroup=="P 31 1 2" | spaceGroup == "P 31 2 1")
p31123121plot=ggplot(p31123121,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p31123121plot

p32123221=subset(dd2,spaceGroup=="P 32 1 2" | spaceGroup == "P 32 2 1")
p32123221plot=ggplot(p32123221,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p32123221plot

p6165=subset(dd2,spaceGroup=="P 61" | spaceGroup == "P 65")
p6165plot=ggplot(p6165,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p6165plot

p6264=subset(dd2,spaceGroup=="P 62" | spaceGroup == "P 64")
p6264plot=ggplot(p6264,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p6264plot

p61226522=subset(dd2,spaceGroup=="P 61 2 2" | spaceGroup == "P 65 2 2")
p61226522plot=ggplot(p61226522,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p61226522plot

p62226422=subset(dd2,spaceGroup=="P 62 2 2" | spaceGroup == "P 64 2 2")
p62226422plot=ggplot(p62226422,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p62226422plot


p43324132=subset(dd2,spaceGroup=="P 43 3 2" | spaceGroup == "P 41 3 2")
p43324132plot=ggplot(p43324132,aes(x=spaceGroup,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');p43324132plot


pdf("/afs/psi.ch/project/bioinfo2/kumaran/spacegroup/enantiomoph.pdf")
p4143plot
p4121243212plot
p41224322plot
p3132plot
p31123121plot
p32123221plot
p6165plot
p6264plot
p61226522plot
p62226422plot
p43324132plot
dev.off()


dd3=attach_E(attach_C(d2))
dd4=dd3[with(dd3, order(E)), ]
d2=subset(d,SolventPhenixNoWater>0 & SolventPhenixNoWater<95)
d3=attach_cell_type(d2)
d4=attach_E(attach_E2(d2))
enantiomophplot=ggplot(d4,aes(x=E2,y=SolventPhenixNoWater))+
  geom_boxplot(aes(fill=E))+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text",fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean,colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');enantiomophplot
pdf("/afs/psi.ch/project/bioinfo2/kumaran/spacegroup/enantiomoph.pdf")
enantiomophplot
dev.off()
d2=subset(d,SolventPhenixNoWater>0 & SolventPhenixNoWater< 95)

csplot=ggplot(d2,aes(x=CS,y=SolventPhenixNoWater))+
  geom_boxplot()+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text",fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean,colour = "red",size=3)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');csplot

pdf("/afs/psi.ch/project/bioinfo2/kumaran/spacegroup/crystalsystem_vs_sol.pdf")
csplot
dev.off()
