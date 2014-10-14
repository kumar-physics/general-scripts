setwd('~/test/plots')
library(RMySQL)
library(ggplot2)
library(plyr)
library(reshape2)
#dbconnection
mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05")
on.exit(dbDisconnect(mydb))
ep=fetch(dbSendQuery(mydb,"select pdbCode,mmSize,count_bio(pdbCode) biocall from Assembly where method='authors'"),-1)

ggplot(ep)+
  geom_point(aes(x=mmSize,y=biocall))