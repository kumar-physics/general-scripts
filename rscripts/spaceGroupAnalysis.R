#!/usr/bin/env Rscript
library(ggplot2)
mydb=dbConnect(MySQL(),dbname="eppic_2015_01")

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
# function for number of observations 
give.n <- function(x){
  return(c(y = median(x)*1.02, label = length(x))) 
  # experiment with the multiplier to find the perfect position
}


# function for mean labels
mean.n <- function(x){
  return(c(y = median(x)*0.98, label = round(mean(x),2))) 
  # experiment with the multiplier to find the perfect position
}
median.n <- function(x){
  return(c(y = median(x)*0.98, label = round(median(x),2))) 
  # experiment with the multiplier to find the perfect position
}
setwd('/Users/kumaran/Documents/presentations/kumaran/jlbrFeb2015')
sol_content=read.table('plots/solventcontent/solvent.dat',sep="\t")
colnames(sol_content)=c('pdb','spaceGroup','ExpMethod','resolution','rfree','solvent')
alldat=subset(attach_D(attach_crystal_system(sol_content),1),solvent<.95)

#dat$D=factor(dat$D,levels=c("7","6","5","4"))
pp=ggplot(ssplotdat)+
  geom_bar(aes(x=spaceGroup,y=count,color=D,fill=D),stat='identity')+
  xlab('Space group')+
  ylab('Number of PDBs')+
  scale_y_log10(breaks=c(1,10,100,500,1000,5000,10000,20000))+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');pp

plot1=ggplot(alldat,aes(x=D,y=solvent))+
  geom_boxplot(aes(color=D),notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  ggtitle('All data')+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');plot1
plot2=ggplot(alldat,aes(x=D,y=solvent))+
  geom_violin(aes(color=D),notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  ggtitle('All data')+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');plot2

plot3=ggplot(subset(alldat,resolution>0 & resolution<2.5 & rfree>0 & rfree<0.3),aes(x=D,y=solvent))+
  geom_boxplot(aes(color=D),notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  geom_violin(aes(color=D),alpha=0.5)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  #ggtitle("All data with resolution and rfree filter")+
  ylab("Solvent content")+
  xlab("Number of degrees of freedom")+
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(panel.background = element_blank(),
        axis.text.x=element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='none');plot3
plot4=ggplot(subset(alldat,resolution>0 & resolution<2.5 & rfree>0 & rfree<0.3),aes(x=D,y=solvent))+
  geom_violin(aes(color=D),notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  ggtitle("All data with resolution and rfree filter")+
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(panel.background = element_blank(),
        axis.text.x=element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='none');plot4



sol_content=read.table('plots/solventcontent/solvent_singleentity.dat',sep="\t")
colnames(sol_content)=c('pdb','spaceGroup','ExpMethod','resolution','rfree','solvent')
sedat=subset(attach_D(attach_crystal_system(sol_content),1),solvent<.95)


plot5=ggplot(sedat,aes(x=D,y=solvent))+
  geom_boxplot(aes(color=D),notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  ggtitle("Single entity data")+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');plot5
plot6=ggplot(sedat,aes(x=D,y=solvent))+
  geom_violin(aes(color=D),notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  ggtitle("Single entitiy data")+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');plot6

plot7=ggplot(subset(sedat,resolution>0 & resolution<2.5 & rfree>0 & rfree<0.3),aes(x=D,y=solvent))+
  geom_boxplot(aes(color=D),nothc=TRUE)+#scale_y_continuous(breaks=-10:20)+
  geom_violin(aes(color=D),alpha=0.5)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  #ggtitle("All data with resolution and rfree filter")+
  ylab("Solvent content")+
  xlab("Number of degrees of freedom")+
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(panel.background = element_blank(),
        axis.text.x=element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='none');plot7
plot8=ggplot(subset(sedat,resolution>0 & resolution<2.5 & rfree>0 & rfree<0.3),aes(x=D,y=solvent))+
  geom_violin(aes(color=D),nothc=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  ggtitle("Single entity data with resolution and rfree filter")+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');plot8

sol_content=read.table('plots/solventcontent/solvent_singlechain.dat',sep="\t")
colnames(sol_content)=c('pdb','spaceGroup','ExpMethod','resolution','rfree','solvent')
sgdat=subset(attach_D(attach_crystal_system(sol_content),1),solvent<.95)


plot9=ggplot(sgdat,aes(x=D,y=solvent))+
  geom_boxplot(aes(color=D),notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  ggtitle("Single chain data")+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');plot9
plot10=ggplot(sgdat,aes(x=D,y=solvent))+
  geom_violin(aes(color=D),notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  ggtitle("Single chain data")+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');plot10

plot11=ggplot(subset(sgdat,resolution>0 & resolution<2.5 & rfree>0 & rfree<0.3),aes(x=D,y=solvent))+
  geom_boxplot(aes(color=D),nothc=TRUE)+#scale_y_continuous(breaks=-10:20)+
  geom_violin(aes(color=D),alpha=0.5)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  #ggtitle("All data with resolution and rfree filter")+
  ylab("Solvent content")+
  xlab("Number of degrees of freedom")+
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  theme(panel.background = element_blank(),
        axis.text.x=element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='none');plot11
plot12=ggplot(subset(sgdat,resolution>0 & resolution<2.5 & rfree>0 & rfree<0.3),aes(x=D,y=solvent))+
  geom_violin(aes(color=D),nothc=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red",size=3)+
  ggtitle("Single chain data with resolution and rfree filter")+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');plot12

plotsol=ggplot(subset(dat,resolution>0 & resolution<2.5 & rfree>0 & rfree<0.3),aes(x=D,y=solvent))+
  geom_violin(aes(color=D,fill=D),alpha=0.5)+#scale_y_continuous(breaks=-10:20)+
  geom_boxplot(aes(fill=D),nothc=TRUE,alpha=0.5)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=3) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "blue",size=3)+
  #ggtitle("Single chain data with resolution and rfree filter")+
  xlab("Degrees of freedom")+
  ylab("Solvent content")+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.title=element_blank(),
        legend.position="");plotsol

pdf('/home/baskaran_k/solventContent.pdf')
plotsol
dev.off()



sol_content=read.table('plots/solventcontent/solvent.dat',sep="\t")
colnames(sol_content)=c('pdb','spaceGroup','ExpMethod','resolution','rfree','solvent')
edat=attach_E(attach_E2(subset(attach_D(attach_crystal_system(sol_content),1),solvent<.95)))

eplot=ggplot(subset(edat,resolution>0 & resolution<3 & rfree>0 & rfree<0.3),aes(x=E2,y=solvent))+
  geom_boxplot(aes(color=E),notch=TRUE)+#scale_y_continuous(breaks=-10:20)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median,size=2) +
  ylab("Solvent content")+
  xlab("Enantiomorphic spacegroups")+
  stat_summary(fun.data = median.n, geom = "text", fun.y = mean, colour = "red",size=2)+
  theme(panel.background = element_blank(),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='none');eplot

pdf('plot3.pdf')
plot3
dev.off()
pdf('plot7.pdf')
plot7
dev.off()
pdf('plot11.pdf')
plot11
dev.off()
pdf('eplot.pdf')
eplot
dev.off()
pdf('spaceGroupvsDplots.pdf')
plot1
plot2
plot3
plot4
plot5
plot6
plot7
plot8
plot9
plot10
plot11
plot12
dev.off()
