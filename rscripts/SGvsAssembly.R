library(ggplot2)
setwd('/media/baskaran_k/data/spacegroup/')
library(reshape2)
dat=read.table('sg.dat',sep="\t")
colnames(dat)=c('pdb','spaceGroup','resolution','rfree','assembly','R2','S2','A2','R3','S3','A3','R4','S4','A4','R6','S6','A6')

dat2=read.table('sg2.dat',sep="\t")
colnames(dat2)=c('pdb','spaceGroup','resolution','rfree','assembly','R2','S2','A2','R3','S3','A3','R4','S4','A4','R6','S6','A6','assembly2')
dat3=subset(dat2,assembly=='1-mer' | assembly=='2-mer' |assembly=='3-mer'|assembly=='4-mer'|assembly=='6-mer')
ggplot(dat3)+
  geom_bar(aes(x=assembly2,fill=R4),stat='bin',position='dodge')+ylim(0,1000)
 

s=read.table('summary.dat')

plot1=ggplot(subset(dat,assembly=='1-mer' | assembly=='2-mer'))+
  geom_bar(aes(x=A2,color=assembly,fill=assembly));plot1

s=read.table('summary.dat')
plot1=ggplot(s)+
  geom_point(aes(x=V2,y=V1,color=V4),size=5)+
  geom_line(aes(x=c(0,s[1,2]),y=c(0,s[1,1])))+
  geom_line(aes(x=c(0,s[3,2]),y=c(0,s[3,1])))+
  geom_line(aes(x=c(0,s[5,2]),y=c(0,s[5,1])))+
  geom_line(aes(x=c(0,s[7,2]),y=c(0,s[7,1])))+
  xlab("Crystals in space group lacking n-fold symmetry axis")+
  ylab("Crystals in all space group");plot1
plot2=ggplot(subset(s,V4=="Dimer"))+
  geom_point(aes(x=V2,y=V1,color=V4),size=5)+
  geom_line(aes(x=c(0,s[1,2]),y=c(0,s[1,1])))+
  xlab("Crystals in space group lacking 2-fold symmetry axis")+
  ylab("Crystals in all space group");plot2

plot3=ggplot(subset(s,V4=="Trimer"))+
  geom_point(aes(x=V2,y=V1,color=V4),size=5)+
  geom_line(aes(x=c(0,s[3,2]),y=c(0,s[3,1])))+
  xlab("Crystals in space group lacking 3-fold symmetry axis")+
  ylab("Crystals in all space group");plot3

plot4=ggplot(subset(s,V4=="Tetramer"))+
  geom_point(aes(x=V2,y=V1,color=V4),size=5)+
  geom_line(aes(x=c(0,s[5,2]),y=c(0,s[5,1])))+
  xlab("Crystals in space group lacking 4-fold symmetry axis")+
  ylab("Crystals in all space group");plot4

plot5=ggplot(subset(s,V4=="Hexamer"))+
  geom_point(aes(x=V2,y=V1,color=V4),size=5)+
  geom_line(aes(x=c(0,s[7,2]),y=c(0,s[7,1])))+
  xlab("Crystals in space group lacking 6-fold symmetry axis")+
  ylab("Crystals in all space group");plot5



s2=read.table('summary_3fold.dat')
plot6=ggplot(s2)+
  geom_point(aes(x=V2,y=V1,color=V4),size=5)+
  geom_line(aes(x=c(0,s2[1,2]),y=c(0,s2[1,1])))+
  #geom_line(aes(x=c(0,s2[2,2]),y=c(0,s2[2,1])))+
  #geom_line(aes(x=c(0,s2[4,2]),y=c(0,s2[4,1])))+
  #geom_line(aes(x=c(0,s2[6,2]),y=c(0,s2[6,1])))+
  geom_line(aes(x=c(s2[2,2],s2[2,2]),y=c(0,40000)))+
  geom_abline(intercept= 0,slope=s2[2,1]/s2[2,2],color='red')+
  geom_abline(intercept= 0,slope=s2[4,1]/s2[4,2],color='pink')+
  geom_abline(intercept= 0,slope=s2[6,1]/s2[6,2],color='blue')+
  geom_abline(intercept= 0,slope=s2[8,1]/s2[8,2],color='green')+
  #geom_line(aes(x=c(0,s2[8,2]),y=c(0,s2[8,1])))+
  xlab("Crystals in space group lacking 2-fold symmetry axis")+
  ylab("Crystals in all space group");plot6

s3=read.table('summary_3fold.dat')
plot7=ggplot(s3)+
  geom_point(aes(x=V2,y=V1,color=V4),size=5)+
  geom_line(aes(x=c(0,s3[1,2]),y=c(0,s3[1,1])))+
  geom_line(aes(x=c(0,s3[3,2]),y=c(0,s3[3,1])))+
  geom_line(aes(x=c(0,s3[5,2]),y=c(0,s3[5,1])))+
  geom_line(aes(x=c(0,s3[7,2]),y=c(0,s3[7,1])))+
  xlab("Crystals in space group lacking 3-fold symmetry axis")+
  ylab("Crystals in all space group");plot7

s4=read.table('summary_4fold.dat')
plot8=ggplot(s4)+
  geom_point(aes(x=V2,y=V1,color=V4),size=5)+
  geom_line(aes(x=c(0,s4[1,2]),y=c(0,s4[1,1])))+
  geom_line(aes(x=c(0,s4[3,2]),y=c(0,s4[3,1])))+
  geom_line(aes(x=c(0,s4[5,2]),y=c(0,s4[5,1])))+
  geom_line(aes(x=c(0,s4[7,2]),y=c(0,s4[7,1])))+
  xlab("Crystals in space group lacking 4-fold symmetry axis")+
  ylab("Crystals in all space group");plot8

s6=read.table('summary_6fold.dat')
plot9=ggplot(s6)+
  geom_point(aes(x=V2,y=V1,color=V4),size=5)+
  geom_line(aes(x=c(0,s6[1,2]),y=c(0,s6[1,1])))+
  geom_line(aes(x=c(0,s6[3,2]),y=c(0,s6[3,1])))+
  geom_line(aes(x=c(0,s6[5,2]),y=c(0,s6[5,1])))+
  geom_line(aes(x=c(0,s6[7,2]),y=c(0,s6[7,1])))+
  xlab("Crystals in space group lacking 6-fold symmetry axis")+
  ylab("Crystals in all space group");plot9

setwd('/afs/psi.ch/project/bioinfo2/kumaran/spacegroup/plot221214/')
pdf('spaceGroupSymaxis.pdf')
plot1
plot2
plot3
plot4
plot5
plot6
plot7
plot8
plot9
dev.off()


dat=read.table('sss2.dat',sep="\t")
colnames(dat)=c("r","assembly","missing")
dat$assembly=factor(dat$assembly,levels=c("Monomer","Dimer","Trimer","Tetramer","Hexamer"))
plot=ggplot(dat)+#+facet_wrap(~missing,scale='free')+
  geom_bar(aes(x=missing,color=assembly,fill=assembly,y=r),stat='identity',position='dodge')+
  ylab("Ratio between relative abundance of monomer and oligomer")+
  xlab("Space groups with missing n-fold rotation axis")+
  coord_cartesian(ylim=c(.9,2.5))+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');plot
pdf("plot10.pdf")
plot
dev.off()
cbPalette <- c("#fc8d62","#66c2a5", "#56B4E9","#E69F00","#999999", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
datdb=read.table('sgg2.dat',sep="\t")
colnames(datdb)=c('Assembly','all','2-fold','3-fold','4-fold','6-fold','2-fold-observed','3-fold-observed','4-fold-observed',
                  '6-fold-observed','2-fold-ratio','3-fold-ratio','4-fold-ratio','6-fold-ratio')
dfm <- melt(datdb, id.vars = "Assembly")

dfm_n=subset(dfm,variable=='all'|variable=='2-fold'|variable=='3-fold'|variable=='4-fold'|variable=='6-fold')
dfm_o=subset(dfm,variable=='2-fold-observed'|variable=='3-fold-observed'|variable=='4-fold-observed'|variable=='6-fold-observed')
dfm_r=subset(dfm,variable=='2-fold-ratio'|variable=='3-fold-ratio'|variable=='4-fold-ratio'|variable=='6-fold-ratio')
dfm_n$Assembly=factor(dfm_n$Assembly,levels=c("Monomer","Dimer","Trimer","Tetramer","D2-Tetramer","C4-Tetramer","Hexamer","D3-Hexamer","C6-Hexamer"))
dfm_o$Assembly=factor(dfm_o$Assembly,levels=c("Monomer","Dimer","Trimer","Tetramer","D2-Tetramer","C4-Tetramer","Hexamer","D3-Hexamer","C6-Hexamer"))
dfm_r$Assembly=factor(dfm_r$Assembly,levels=c("Monomer","Dimer","Trimer","Tetramer","D2-Tetramer","C4-Tetramer","Hexamer","D3-Hexamer","C6-Hexamer"))

plotr=ggplot(dfm_r)+
  geom_bar(aes(x=variable,y=value,fill=Assembly),stat='identity',position='dodge')+scale_fill_manual(values = cbPalette)+
  ylab("Ratio between observed and expected")+
  xlab(" ")+
  theme(panel.background = element_blank(),
        axis.text.x=element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='right');plotr

ploto=ggplot(dfm_o)+
  geom_bar(aes(x=variable,y=value,fill=Assembly),stat='identity',position='dodge')+scale_fill_manual(values = cbPalette)+
  ylab("Observed ratio")+
  xlab("")+
  theme(panel.background = element_blank(),
        axis.text.x=element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='right');ploto


plotn=ggplot(dfm_n,aes(x=Assembly,y=value,fill=variable))+
  geom_bar(stat='identity',position='dodge')+
  geom_text(aes(label=value), position=position_dodge(width=0.9), vjust=-0.25,size=1.5)+scale_fill_manual(values = cbPalette)+
  ylab("Count")+
  xlab("")+
  theme(panel.background = element_blank(),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='right');plotn

pdf('assembly_vs_axis.pdf')
plotn
ploto
plotr
dev.off()