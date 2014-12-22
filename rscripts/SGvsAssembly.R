library(ggplot2)
setwd('/media/baskaran_k/data/spacegroup/')

dat=read.table('sg.dat',sep="\t")
colnames(dat)=c('pdb','spaceGroup','resolution','rfree','assembly','R2','S2','A2','R3','S3','A3','R4','S4','A4','R6','S6','A6')


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



s2=read.table('summary_2fold.dat')
plot6=ggplot(s2)+
  geom_point(aes(x=V2,y=V1,color=V4),size=5)+
  geom_line(aes(x=c(0,s2[1,2]),y=c(0,s2[1,1])))+
  geom_line(aes(x=c(0,s2[3,2]),y=c(0,s2[3,1])))+
  geom_line(aes(x=c(0,s2[5,2]),y=c(0,s2[5,1])))+
  geom_line(aes(x=c(0,s2[7,2]),y=c(0,s2[7,1])))+
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
