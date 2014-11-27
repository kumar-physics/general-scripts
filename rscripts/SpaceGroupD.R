#!/usr/bin/env Rscript
library(RMySQL)
library(ggplot2)
library(plyr)
library(reshape2)

mydb=dbConnect(MySQL(),dbname="eppic_2014_10")
dat=fetch(dbSendQuery(mydb,"select pdbCode,count(*) count from InterfaceCluster where pdbCode is not NULL group by pdbCode ;"),-1)
#dat2=fetch(dbSendQuery(mydb,"select i.pdbCode,count(i.pdbCode) c,s.spaceGroup from Interface as i inner join SingleChainSpaceGroups as s on s.pdbCode=i.pdbCode where i.pdbCode is not NULl group by i.pdbCode;"),-1)
#dat2=fetch(dbSendQuery(mydb,"select spaceGroup,sum(c) c from space_temp group by spaceGroup"),-1)
#dat2=fetch(dbSendQuery(mydb,'select * from space_temp2'),-1)

dat2=fetch(dbSendQuery(mydb,'select p.pdbCode,p.spaceGroup,count(*) c from PdbInfo as p inner join
ChainCluster as c on p.uid=c.pdbInfo_uid inner join Interface as i on
i.pdbCode=p.pdbCode where p.numChainClusters=1 and length(c.memberChains)=1 group by p.pdbCode;'),-1)

dat2=read.table('~/spacegroup.dat',sep="\t")
colnames(dat2)=c('spaceGroup','MinContact35','AvgContact35','MinContact','AvgContact')
dat2$D[dat2$spaceGroup=='P 21 21 21']='D=7 Optimal'
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
         dat2$spaceGroup=='I 21 21 21'] = 'D=6 Favorable'
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
        dat2$spaceGroup=='P 1 2 1'] = 'D=5 Unfavorable'
dat2$D[dat2$spaceGroup=='P 42' |
         dat2$spaceGroup=='P 4' |
         dat2$spaceGroup=='P 3' |
         dat2$spaceGroup=='P 2 3' |
         dat2$spaceGroup=='F 2 3' |
         dat2$spaceGroup=='P 3 1 2' |
         dat2$spaceGroup=='P 4 2 2' |
         dat2$spaceGroup=='P 42 2 2' |
         dat2$spaceGroup=='P 2 2 2'] = 'D=4 Forbidden'

dat2$mc[dat2$spaceGroup=='P 21 21 21' |
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
dat2$mc[dat2$spaceGroup=='P 1 21 1' |
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
dat2$mc[dat2$spaceGroup=='P 2 2 21' |
          dat2$spaceGroup=='C 2 2 2' |
          dat2$spaceGroup=='F 2 2 2' |
          dat2$spaceGroup=='P 1 2 1' |
          dat2$spaceGroup=='P 3 1 2' |
          dat2$spaceGroup=='P 4 2 2' |
          dat2$spaceGroup=='P 42 2 2' ]=4
dat2$mc[dat2$spaceGroup=='P 2 2 2' ]=5


dat3=subset(dat2,!is.na(mc) & !is.na(spaceGroup))
dat4=transform(dat3, spaceGroup = reorder(spaceGroup, -c))
ggplot(dat4)+
  geom_bar(aes(x=spaceGroup,y=c,color=D,fill=D),stat='identity',alpha=0.5)+
  theme(panel.background = element_blank(),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');
dat3=subset(dat2,is.na(D) & !is.na(spaceGroup))

space_op=fetch(dbSendQuery(mydb,"select p.pdbCode,p.spaceGroup,i.operator,i.operatorId,i.operatorType 
                           from PdbInfo as p inner join Interface as i on i.pdbCode=p.pdbCode"),-1)



space_op$ot=sprintf("o_%d",space_op$operatorId)
ggplot(space_op)+
  facet_wrap(~spaceGroup,scales = "free")+
  geom_bar(aes(x=operatorId))+
  theme(panel.background = element_blank(),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

dat2=fetch(dbSendQuery(mydb,"select spaceGroup,pdbCode,count(*) d from space_temp group by pdbCode;"),-1)
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
         dat2$spaceGroup=='I 21 21 21'] = 'D=6 Favorable'
ggplot(subset(dat2,D=='D=6 Favorable'))+
  geom_density(aes(x=d,color=spaceGroup,fill=spaceGroup))

ggplot(subset(dat2,D=='D=6 Favorable' | D=='D=5 Unfavorable'))+
  geom_bar(aes(x=c,color=D,fill=D),alpha=0.5,binwidth=1,position='identity')

p=ggplot(dat3)+
  facet_wrap(~spaceGroup,scale='free')+
  geom_bar(aes(x=c,color=mc,fill=mc,group=spaceGroup),binwidth=1)


dat2=read.table('~/spacegroup.dat',sep="\t")
colnames(dat2)=c('spaceGroup','MinContact35','AvgContact35','MinContact','AvgContact')
dat2$mc[dat2$spaceGroup=='P 21 21 21' |
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
dat2$mc[dat2$spaceGroup=='P 1 21 1' |
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
dat2$mc[dat2$spaceGroup=='P 2 2 21' |
          dat2$spaceGroup=='C 2 2 2' |
          dat2$spaceGroup=='F 2 2 2' |
          dat2$spaceGroup=='P 1 2 1' |
          dat2$spaceGroup=='P 3 1 2' |
          dat2$spaceGroup=='P 4 2 2' |
          dat2$spaceGroup=='P 42 2 2' ]=4
dat2$mc[dat2$spaceGroup=='P 2 2 2' ]=5
dat3=subset(dat2,!is.na(mc) & !is.na(spaceGroup))
dat3$diff35=dat3$MinContact35-dat3$mc
dat3$diff=dat3$MinContact-dat3$mc
df=melt(dat3,id.vars=1)
ggplot(df)+
  geom_bar(aes(x=spaceGroup,y=value,color=variable,fill=variable),stat='identity',position='dodge')+
  scale_y_continuous(breaks=-10:10)+
  theme(axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');
