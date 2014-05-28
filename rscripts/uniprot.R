setwd('~/pdbstatistics/')
library(RMySQL)
library(ggplot2)
library(reshape2)
d<-read.table('uniportogrowth.dat',header=T)
d <- melt(d, id.vars="Uniprot")
ggplot(d, aes(x=Uniprot,y=value, col=variable,fill=variable)) + geom_line(aes(group=variable))+ylab('% of PDB having at least 10 homolos')

