#!/usr/bin/env Rscript
library(RMySQL)
library(ggplot2)
library(plyr)
library(reshape2)

#color blind free paletter
cbPalette <- c("#fc8d62","#66c2a5", "#56B4E9","#E69F00","#999999", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
#dbconnection
if(system("hostname",intern=T) == "delilah.psi.ch") { #spencer's system
  system("ssh -fN -L 3307:localhost:3306 -o ExitOnForwardFailure=yes mpc")
  mydb = dbConnect(MySQL(),group = "client_mpc",dbname="eppic_2_1_0_2014_05")
} else {
  mydb=dbConnect(MySQL(),dbname="eppic_2014_07") #~/.my.cnf file configured with right username and passwd
}

d=fetch(dbSendQuery(mydb,"select h.queryCoverage,h.seqId,h.chainCluster_uid chain,h.firstTaxon,h.lastTaxon  from Homolog as h 
                    inner join ChainCluster as c on c.uid=h.chainCluster_uid where c.numHomologs>50 and h.queryEnd-h.queryStart>20;"),-1)

d$chainname=sprintf("c_%d",d$chain)


plot1=ggplot(subset(d,  queryCoverage>0.8 & 
                      (firstTaxon=='Bacteria' | firstTaxon == 'Archaea' | 
                         firstTaxon =='Eukaryota' | firstTaxon=='Viruses' )))+
  facet_wrap(~firstTaxon,scale='free')+
  geom_histogram(aes(x=seqId,y=..count..,group=chainname,fill=firstTaxon),
                 alpha=0.1,stat='bin',binwidth=0.01,position='identity')

plot2=ggplot(subset(d, chain<5000 &  queryCoverage>0.8 & 
                      (firstTaxon=='Bacteria' | firstTaxon == 'Archaea' | 
                         firstTaxon =='Eukaryota' | firstTaxon=='Viruses' )))+
  facet_wrap(~firstTaxon)+
  geom_density(aes(x=seqId,group=chainname,color=firstTaxon));plot2

plot3=ggplot(subset(d, chain<5000 & queryCoverage>0.8 & 
                      (firstTaxon=='Bacteria' | firstTaxon == 'Archaea' | 
                         firstTaxon =='Eukaryota' | firstTaxon=='Viruses' )))+
  facet_wrap(~firstTaxon,scale='free')+
  geom_density(aes(x=seqId,group=chainname,color=firstTaxon));plot3

plot4=ggplot(subset(d, chain<5000 & queryCoverage>0.8 & 
                      (firstTaxon=='Bacteria' | firstTaxon == 'Archaea' | 
                         firstTaxon =='Eukaryota' | firstTaxon=='Viruses' )))+
  geom_density(aes(x=seqId,group=chainname,color=firstTaxon));plot4






setwd('/home/baskaran_k/publications/Structure_validation_analysis/')
jpeg("homologs_dist1.jpg",width=1200,height=800)
plot1
dev.off()
jpeg("homologs_dist2.jpg",width=1200,height=800)
plot2
dev.off()
jpeg("homologs_dist3.jpg",width=1200,height=800)
plot3
dev.off()
jpeg("homologs_dist4.jpg",width=1200,height=800)
plot4
dev.off()