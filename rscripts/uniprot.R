setwd('~/pdbstatistics/')
library(RMySQL)
library(ggplot2)
library(reshape2)
d<-read.table('uniportogrowth.dat',header=T)
d <- melt(d, id.vars="Uniprot")
plot1=ggplot(d, aes(x=Uniprot,y=value, col=variable,fill=variable)) + geom_line(aes(group=variable))+ylab('% of PDB having at least 10 homolos(or)% of EPPIC predictability')+theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))
plot1
pdf('uniprotvseppic.pdf')
plot1
dev.off()