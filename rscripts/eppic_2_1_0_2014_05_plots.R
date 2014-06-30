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
  mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05") #~/.my.cnf file configured with right username and passwd
}
on.exit(dbDisconnect(mydb))


#functions
#to load benchmark data
loadBenchmark = function(db, #database name
                         db_bio=paste(db,"_bio",sep=""), # bio db name
                         db_xtal=paste(db,"_xtal",sep=""), # xtal db name
                         data=NA #dataframe returned from previous call
)
{
  result=dbSendQuery(mydb,sprintf("select * from %s;",db_bio))
  bio=fetch(result,n=-1)
  result=dbSendQuery(mydb,sprintf("select * from %s;",db_xtal))
  xtal=fetch(result,n=-1)
  
  bio$benchmark=db
  xtal$benchmark=db
  bio$truth="bio"
  xtal$truth="xtal"
  
  if (all(is.na(data))){
    data = rbind(bio,xtal)
  }else{
    data = rbind(data,bio,xtal)
  }
}

# to calcualte roc curve
roc = function(score,truth,tag,dat=NA){
  cutoff<-NULL
  sensitivity<-NULL
  specificity<-NULL
  accuracy<-NULL
  dataset<-NULL
  mcc<-NULL
  s=data.frame(score,truth)
  attach(s)
  d<-s[order(score),]
  p=subset(count(d,'truth'),truth=='bio')$freq
  n=subset(count(d,'truth'),truth=='xtal')$freq
  for (i in 1:length(d$score)){
    tp=subset(count(subset(d,score<=d$score[i]),'truth'),truth=='bio')$freq
    tn=subset(count(subset(d,score>d$score[i]),'truth'),truth=='xtal')$freq
    if (length(tn)==0){
      tn=0
    }
    fn=p-tp
    fp=n-tn
    dataset<-c(dataset,tag)
    cutoff<-c(cutoff,d$score[i])
    sensitivity<-c(sensitivity,tp/p)
    specificity<-c(specificity,tn/n)
    accuracy<-c(accuracy,(tp+tn)/(p+n))
    mcc<-c(mcc,(((tp*tn)-(fp*fn))/(sqrt(p)*sqrt(n)*sqrt(tp+fp)*sqrt(tn+fn))))
  }
  if (all(is.na(dat))){
    dat=data.frame(cutoff,sensitivity,specificity,accuracy,mcc,dataset)
  }else{
    dat=rbind(dat,data.frame(cutoff,sensitivity,specificity,accuracy,mcc,dataset))
  } 
}

#due to discrete values of gmScore above script is slightly modified to avoid null cases
roc_gm = function(score,truth,tag,dat=NA){
  cutoff<-NULL
  sensitivity<-NULL
  specificity<-NULL
  accuracy<-NULL
  dataset<-NULL
  mcc<-NULL
  s=data.frame(score,truth)
  attach(s)
  d<-s[order(score),]
  p=subset(count(d,'truth'),truth=='bio')$freq
  n=subset(count(d,'truth'),truth=='xtal')$freq
  for (i in length(d$score):1){
    tp=subset(count(subset(d,score>=d$score[i]),'truth'),truth=='bio')$freq
    tn=subset(count(subset(d,score<d$score[i]),'truth'),truth=='xtal')$freq
    if (length(tn)==0){
      tn=0
    }
    if (length(tp)==0){
      tp=0
    }
    fn=p-tp
    fp=n-tn
    dataset<-c(dataset,tag)
    cutoff<-c(cutoff,d$score[i])
    sensitivity<-c(sensitivity,tp/p)
    specificity<-c(specificity,tn/n)
    accuracy<-c(accuracy,(tp+tn)/(p+n))
    mcc<-c(mcc,(((tp*tn)-(fp*fn))/(sqrt(p)*sqrt(n)*sqrt(tp+fp)*sqrt(tn+fn))))
  }
  if (all(is.na(dat))){
    dat=data.frame(cutoff,sensitivity,specificity,accuracy,mcc,dataset)
  }else{
    dat=rbind(dat,data.frame(cutoff,sensitivity,specificity,accuracy,mcc,dataset))
  } 
}

#db queries
pdb=fetch(dbSendQuery(mydb,"select p.* from PdbInfo as p 
                          inner join Job as j on p.job_uid=j.uid 
                          where j.inputType=0;"),-1)

exp=fetch(dbSendQuery(mydb,"select p.expMethod,assembly(p.pdbCode) assembly,count(*)  count from PdbInfo as p
                      inner join Job as j on p.job_uid=j.uid
                      where p.expMethod is not NULL and
                      j.inputType=0 group by p.expMethod,assembly(p.pdbCode) order by count(*) desc;"),-1)

spacegroup=fetch(dbSendQuery(mydb,"select p.spaceGroup,assembly(p.pdbCode) assembly,count(*) count from PdbInfo as p
                      inner join Job as j on p.job_uid=j.uid
                      where p.spaceGroup is not NULL and
                      j.inputType=0 group by p.spaceGroup,assembly(p.pdbCode) order by count(*) desc;"),-1)

eppic=fetch(dbSendQuery(mydb,"select * from EppicTable;"),-1)

infinite=fetch(dbSendQuery(mydb,"select pdbCode,interfaceId,area 
                           from EppicTable where infinite=1 and area>350;"),-1)

op=fetch(dbSendQuery(mydb,"select operatorType,final,count(*) count 
                     from EppicTable where operatorType is not NULL 
                     group by operatorType,final;"),-1)
#NMR plot not required for paper
nmr=fetch(dbSendQuery(mydb,"select (length(c.memberChains)+1)/2+1 chains,count(*) count
  from ChainCluster as c 
  inner join PdbInfo as p on p.uid=c.pdbInfo_uid 
  inner join Job as j on j.uid=p.job_uid
  where p.expMethod='SOLUTION NMR' and length(j.jobId)=4 
  group by length(c.memberChains)
  union all select 1.00 chains,
                      (select count(*) from PdbInfo as p 
                      inner join Job as j on j.uid=p.job_uid 
                      where p.expMethod='SOLUTION NMR' and length(j.jobId)=4)-
                      (select count(*) from ChainCluster as c 
                      inner join PdbInfo as p on p.uid=c.pdbInfo_uid 
                      inner join Job as j on j.uid=p.job_uid 
                      where p.expMethod='SOLUTION NMR' and length(j.jobId)=4) count 
                      order by chains;"),-1)


ep=fetch(dbSendQuery(mydb,"select pdbCode,interfaceId,resolution,rfreeValue,area,gmScore core,gm,cr,cs,final eppic,
  pisa pisa_pdb,authors,pqs,pisaCall pisa_db from EppicvsPisa where resolution<2.5 and rfreeValue<0.3" ),-1)


ep$remark='No remark'
ep$remark[ep$pisa_db=='xtal' & ep$eppic=='xtal']<-'xtal xtal'
ep$remark[ep$pisa_db=='bio' & ep$eppic=='bio']<-'bio bio'
ep$remark[ep$pisa_db=='bio' & ep$eppic=='xtal']<-'xtal bio'
ep$remark[ep$pisa_db=='xtal' & ep$eppic=='bio']<-'bio xtal'
s<-length(subset(ep,remark=='xtal xtal' | remark=='bio bio' | remark=='xtal bio' | remark=='bio xtal')$area)

xx<-100*length(subset(ep,remark=='xtal xtal')$area)/s
bb<-100*length(subset(ep,remark=='bio bio')$area)/s
xb<-100*length(subset(ep,remark=='xtal bio')$area)/s
bx<-100*length(subset(ep,remark=='bio xtal')$area)/s
pdata=subset(ep,remark!='No remark')
pdata$remark<-factor(pdata$remark,levels=c("xtal xtal","bio bio","xtal bio","bio xtal"))
pdata$issame="different interface call"
pdata$issame[pdata$pisa_db==pdata$eppic]="same interface call"
pdata$issame<-factor(pdata$issame,levels=c("same interface call","different interface call"))


epvsaut=fetch(dbSendQuery(mydb,"select pdbCode,interfaceId,operatorType,area,gmScore,gm,crScore,
                       cr,csScore,cs,final,pisa,authors,pqs from EppicTable 
                       where resolution<2.5 and rfreeValue<0.3 and resolution>0 
                       and h1>30 and h2>30 and cs!='nopred' and cr!='nopred' and 
                       cs=cr and cs=gm and authors is not NULL 
                       and get_chainlength(pdbCode,chain1)>50 and 
                       get_chainlength(pdbCode,chain2)>50 order by csScore " ),-1)
ep2=rbind(epvsaut[1:10000,],epvsaut[(dim(epvsaut)[1]-10000):dim(epvsaut)[1],])

ep2$remark='No remark'
ep2$remark[ep2$authors=='xtal' & ep2$final=='xtal']<-'xtal xtal'
ep2$remark[ep2$authors=='bio' & ep2$final=='bio']<-'bio bio'
ep2$remark[ep2$authors=='bio' & ep2$final=='xtal']<-'xtal bio'
ep2$remark[ep2$authors=='xtal' & ep2$final=='bio']<-'bio xtal'
s2<-length(subset(ep2,remark=='xtal xtal' | remark=='bio bio' | remark=='xtal bio' | remark=='bio xtal')$area)

xx2<-100*length(subset(ep2,remark=='xtal xtal')$area)/s2
bb2<-100*length(subset(ep2,remark=='bio bio')$area)/s2
xb2<-100*length(subset(ep2,remark=='xtal bio')$area)/s2
bx2<-100*length(subset(ep2,remark=='bio xtal')$area)/s2
pdata2=subset(ep2,remark!='No remark')
pdata2$remark<-factor(pdata2$remark,levels=c("xtal xtal","bio bio","xtal bio","bio xtal"))
pdata2$issame="different interface call"
pdata2$issame[pdata2$pisa_db==pdata2$eppic]="same interface call"
pdata2$issame<-factor(pdata2$issame,levels=c("same interface call","different interface call"))


#creating data frames
janin<-function(x){0.016*exp(-(x)/260)}
janindata<-data.frame(area=0:2500,density=janin(0:2500))

jsum=integrate(janin,600,Inf)
janindata$density=janindata$density/jsum$value


#benchmark data
data=loadBenchmark("dc")
data=loadBenchmark("po",data=data)
data=loadBenchmark("many",data=data)
colnames(data)[61]='dataset'
d<-subset(data,select=c(area,dataset,truth))
d$dataset[d$dataset=='dc']<-sprintf("DC (%d,%d)",
                                    length(subset(d,dataset=='dc' & truth=='bio')$area),
                                    length(subset(d,dataset=='dc' & truth=='xtal')$area))
d$dataset[d$dataset=='po']<-sprintf("Ponstingl (%d,%d)",
                                    length(subset(d,dataset=='po' & truth=='bio')$area),
                                    length(subset(d,dataset=='po' & truth=='xtal')$area))
d$dataset[d$dataset=='many']<-sprintf("Many (%d,%d)",
                                      length(subset(d,dataset=='many' & truth=='bio')$area),
                                      length(subset(d,dataset=='many' & truth=='xtal')$area))

#ROC data
dc_cr<-subset(data,dataset=="dc" & cr!="nopred",select=c(crScore,truth,cr))
dc_cs<-subset(data,dataset=="dc" & cs!="nopred",select=c(csScore,truth,cs))
dc_gm<-subset(data,dataset=="dc" & gm!="nopred",select=c(gmScore,truth,gm))
po_cr<-subset(data,dataset=="po" & cr!="nopred",select=c(crScore,truth,cr))
po_cs<-subset(data,dataset=="po" & cs!="nopred",select=c(csScore,truth,cs))
po_gm<-subset(data,dataset=="po" & gm!="nopred",select=c(gmScore,truth,gm))
many_cr<-subset(data,dataset=="many" & cr!="nopred" & crScore<500,select=c(crScore,truth,cr))
many_cs<-subset(data,dataset=="many" & cs!="nopred" & crScore<500,select=c(csScore,truth,cs))
many_gm<-subset(data,dataset=="many" & gm!="nopred" & crScore<500,select=c(gmScore,truth,gm))

cs=roc(dc_cs$csScore,dc_cs$truth,'dc')
cs=roc(po_cs$csScore,po_cs$truth,'po',dat=cs)
cs=roc(many_cs$csScore,many_cs$truth,'many',dat=cs)
cr=roc(dc_cr$crScore,dc_cr$truth,'dc')
cr=roc(po_cr$crScore,po_cr$truth,'po',dat=cr)
cr=roc(many_cr$crScore,many_cr$truth,'many',dat=cr)
gm=roc_gm(dc_gm$gmScore,dc_gm$truth,'dc')
gm=roc_gm(po_gm$gmScore,po_gm$truth,'po',dat=gm)
gm=roc_gm(many_gm$gmScore,many_gm$truth,'many',dat=gm)


cs$method='CoreSurface'
cr$method='CoreRim'
gm$method='Geometry'

roc_data=rbind(gm,cr)
roc_data=rbind(roc_data,cs)

xtal_color="#fc8d62"
bio_color="#66c2a5"
font_size=20
alpha_value=0.75
#jpeg plots font size 20
setwd('~/publications/PDBwide_latex/figures/rplots')
areavscore=ggplot(subset(eppic,gmScore>0,select =c(area,gmScore,final)))+
  geom_density2d(aes(x=area,y=gmScore,color=final),bins=5000,alpha=alpha_value)+
  scale_color_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of core residues')+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

areaplot=ggplot(subset(eppic,area<=5000),aes(x=area))+
  geom_histogram(aes(fill=final),binwidth=100,alpha=alpha_value,position="identity")+
  scale_color_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  scale_fill_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of interfaces')+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

coreplot=ggplot(subset(eppic,area<=5000 & gmScore>0),aes(x=gmScore))+
  geom_histogram(aes(fill=final),binwidth=1,alpha=alpha_value,position="identity")+
  scale_color_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  scale_fill_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  xlab('Number of core residues')+
  ylab('Number of interfaces')+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

expplot=ggplot(transform(subset(exp,count>400), expMethod = reorder(expMethod, -count)))+
  geom_bar(aes(x=expMethod,y=count,fill=assembly),alpha=alpha_value,position="dodge",stat='identity')+
  scale_fill_manual(values=c(xtal_color,bio_color),name="Assembly")+
  scale_color_manual(values=c(xtal_color,bio_color),name="Assembly")+
  xlab('')+
  ylab('Number of PDBs')+
  geom_text(aes(color=assembly,group=assembly,x=expMethod,y=count,label=count),position=position_dodge(1.0),vjust=-0.5)+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        #axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');expplot

spacegroupplot=ggplot(transform(spacegroup, spaceGroup = reorder(spaceGroup, -count)),aes(x=spaceGroup,y=count))+
  geom_bar(aes(fill=assembly),alpha=alpha_value)+
  scale_color_manual(values=c(xtal_color,bio_color),name="Assembly")+
  scale_fill_manual(values=c(xtal_color,bio_color),name="Assembly")+
  xlab('Space group')+
  ylab('Number of PDBs')+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

opplot=ggplot(transform(op, operatorType = reorder(operatorType, -count)),aes(x=operatorType,y=count))+
  geom_bar(aes(fill=final),alpha=alpha_value)+
  scale_color_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  scale_fill_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  xlab('Operator type')+
  ylab('Count')+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');
jcolors<-c("#a6611a","#dfc27d","#80cdc1","#018571")
janinplot=ggplot()+scale_color_manual(values=jcolors)+ #scale_color_brewer(palette="cbPalette") +
   geom_line(data=subset(janindata,area>600),aes(x=area,y=density,color='Janin'),size=1.0)+
   geom_line(data=subset(infinite,area>600),aes(x=area,y=..density..,color='Infinite assemblies'),stat='bin',binwidth=25,drop=T,size=1.0)+
   geom_line(data=subset(eppic,cs=='xtal' & cr=='xtal' & area>600),aes(x=area,y=..density..,color='Xtal based on evolution'),stat='bin',binwidth=25,drop=T,size=1.0)+
   geom_line(data=subset(eppic,gm=='xtal' & area>600),aes(x=area,y=..density..,color='Xtal based on geometry'),stat='bin',binwidth=25,drop=T,size=1.0)+
#  stat_bin(data=infinite,aes(x=area,color='Infinite assemblies',y=..density..),geom="line",binwidth=25,drop=T,size=1.0) + 
  #geom_histogram(data=infinite,aes(x=area,y=..density..,fill='Infinite assemblies'),binwidth=25,alpha=.5) +
#  geom_line(data=subset(eppic,cs=='xtal' & cr=='xtal' & area>350),aes(x=area,y=..density..,color='Xtal based on evolution'),stat='bin',size=1.0,drop=T,binwidth=25)+
  #geom_histogram(data=subset(eppic,cs=='xtal' & cr=='xtal' & area>350),aes(x=area,y=..density..,fill='Xtal based on evolution'),binwidth=25,alpha=.5)+
#  geom_line(data=subset(eppic,gm=='xtal' & area>350),aes(x=area,y=..density..,color='Xtal based on geometry'),stat='bin',size=1.0,drop=T,binwidth=25)+
  #geom_histogram(data=subset(eppic,gm=='xtal' & area>350),aes(x=area,y=..density..,fill='Xtal based on geometry'),binwidth=25,alpha=.5)+
  ylim(0,0.006)+xlim(0,2500)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab("Probability")+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');janinplot

#Benchmark plots
benchmark_areaplot = ggplot(d) +
  facet_wrap(~dataset)+
  geom_histogram(aes(x=area,fill=truth),binwidth=100,position='identity',alpha=alpha_value)+
  scale_fill_manual(values=c(bio_color,xtal_color))+
  scale_color_manual(values=c(bio_color,xtal_color))+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of interfaces')+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.title=element_blank(),
        legend.position='bottom'); 
benchmark_area_free = ggplot(d) + 
  facet_wrap(~dataset,scale='free')+
  geom_histogram(aes(x=area,fill=truth),binwidth=100,position='identity',alpha=alpha_value)+
  scale_fill_manual(values=c(bio_color,xtal_color))+
  scale_color_manual(values=c(bio_color,xtal_color))+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of interfaces')+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.title=element_blank(),
        legend.position='bottom');

rocplot=ggplot(roc_data)+
  facet_wrap(~method)+
  geom_line(aes(x=1-specificity,y=sensitivity,color=dataset),size=1.0)+
  scale_color_manual(values=c("#1b9e77","#d95f02","#7570b3"),name="Data set",
                     breaks=c("dc", "po", "many"),
                     labels=c("DC", "Ponstingl", "Many"))+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

#NMR chains

nmrplot=ggplot(nmr)+
  geom_bar(aes(x=chains,y=count),stat='identity',fill='#1b9e77')+
  scale_x_continuous(breaks=1:15)+
  scale_y_log10(breaks=c(10,100,1000,5000,2500,10000))+
  geom_text(aes(x=chains,y=count,label=count),vjust=-0.5)+
  xlab('Number of chains')+
  ylab('Number of PDBs')+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');



pisaplot=ggplot(pdata)+scale_fill_manual(values=cbPalette)+
  geom_bar(aes(x=area,fill=remark),
            position=position_fill(height=100),stat='bin',binwidth=200)+
  #geom_line(aes(x=area,y=..count..,color=issame,ymax=1),
   #         position=position_fill(height=100),stat='bin',binwidth=200)+
  xlim(0,5000)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Ratio of the interface calls with in a bin')+
  annotate("text", label = sprintf("%.2f %%",xx), x = 500, y = 0.3)+
  annotate("text", label = sprintf("%.2f %%",bb), x = 3000, y = 0.5 )+
  annotate("text", label = sprintf("%.2f %%",xb), x = 1100, y = 0.85)+
  annotate("text", label = sprintf("%.2f %%",bx), x = 1200, y = 0.97)+
  #geom_hline(aes(yintercept=pisaavg,label='average'),linetype="dashed",show_guide=T)+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');pisaplot



autplot=ggplot(pdata2)+scale_fill_manual(values=cbPalette)+
  #geom_bar(aes(x=area,fill=remark),
          # position='identity',
          # stat='bin',binwidth=200,alpha=0.6)+
  geom_line(aes(x=area,fill=remark,color=remark),
            position='identity',
            stat='bin',binwidth=200,alpha=1.0,size=1)+
  xlim(0,5000)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Count')+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');autplot
p2=ggplot()+
  geom_bar(dat=epvsaut,aes(x=csScore,fill=cs),,position='identity',bin='stat',binwidth=0.1,alpha=.5)+
  geom_bar(dat=ep2,aes(x=csScore,fill=cs),,position='identity',bin='stat',binwidth=0.1,alpha=.5)+
  scale_color_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  scale_fill_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  xlab('Core surface score')+
  ylab('Count')+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');p2
#ggtitle(sprintf("xtal cutoff=%0.2f,biocutoff=%0.2f",min(subset(ep2,cs=='xtal')$csScore),max(subset(ep2,cs=='bio')$csScore)))
autplot2=




jpeg("pisa.jpg",width=1200,height=800)
pisaplot
dev.off()
jpeg("auth.jpg",width=1200,height=800)
autplot
dev.off()

jpeg("bench_area.jpg",width=1200,height=800)
benchmark_areaplot
dev.off()
jpeg("bench_area_free.jpg",width=1200,height=800)
benchmark_area_free
dev.off()
jpeg("roc.jpg",width=1200,height=600)
rocplot
dev.off()
jpeg("nmr_chains.jpg",width=1200,height=600)
nmrplot
dev.off()
jpeg("janin.jpg",width=800,height=600)
janinplot
dev.off()
jpeg("area_vs_core.jpg",width=1200,height=800)
areavscore
dev.off()
jpeg("area_hist.jpg",width=1200,height=800)
areaplot
dev.off()
jpeg("core_hist.jpg",width=1200,height=800)
coreplot
dev.off()
jpeg("exp_stat.jpg",width=1200,height=800)
expplot
dev.off()
jpeg("spacegroup.jpg",width=1200,height=800)
spacegroupplot
dev.off()
jpeg("operatortype.jpg",width=1200,height=800)
opplot
dev.off()


#pdf plot font size normal
setwd('~/publications/PDBwide_latex/figures/rplotspdf')
rocplot=ggplot(roc_data)+
  facet_wrap(~method)+
  geom_line(aes(x=1-specificity,y=sensitivity,color=dataset),size=1.0)+
  scale_color_manual(values=c("#1b9e77","#d95f02","#7570b3"),name="Data set",
                     breaks=c("dc", "po", "many"),
                     labels=c("DC", "Ponstingl", "Many"))+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');rocplot
benchmark_areaplot = ggplot(d) + 
  facet_wrap(~dataset)+
  geom_histogram(aes(x=area,fill=truth),binwidth=100,position='identity',alpha=alpha_value)+
  scale_fill_manual(values=c(bio_color,xtal_color))+
  scale_color_manual(values=c(bio_color,xtal_color))+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of interfaces')+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.title=element_blank(),
        legend.position='bottom'); benchmark_areaplot
benchmark_area_free = ggplot(d) + 
  facet_wrap(~dataset,scale='free')+
  geom_histogram(aes(x=area,fill=truth),binwidth=100,position='identity',alpha=alpha_value)+
  scale_fill_manual(values=c(bio_color,xtal_color))+
  scale_color_manual(values=c(bio_color,xtal_color))+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of interfaces')+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.title=element_blank(),
        legend.position='bottom'); benchmark_area_free
areavscore=ggplot(subset(eppic,gmScore>0,select =c(area,gmScore,final)))+
  geom_density2d(aes(x=area,y=gmScore,color=final),bins=5000,alpha=alpha_value)+
  scale_color_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of core residues')+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

areaplot=ggplot(subset(eppic,area<=5000),aes(x=area))+
  geom_histogram(aes(fill=final),binwidth=100,alpha=alpha_value,position="identity")+
  scale_color_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  scale_fill_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Number of interfaces')+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

coreplot=ggplot(subset(eppic,area<=5000 & gmScore>0),aes(x=gmScore))+
  geom_histogram(aes(fill=final),binwidth=1,alpha=alpha_value,position="identity")+
  scale_color_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  scale_fill_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  xlab('Number of core residues')+
  ylab('Number of interfaces')+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

expplot=ggplot(transform(subset(exp,count>400), expMethod = reorder(expMethod, -count)))+
  geom_bar(aes(x=expMethod,y=count,fill=assembly),alpha=alpha_value,position="dodge",stat='identity')+
  scale_fill_manual(values=c(xtal_color,bio_color),name="Assembly")+
  scale_color_manual(values=c(xtal_color,bio_color),name="Assembly")+
  xlab('')+
  ylab('Number of PDBs')+
  geom_text(aes(color=assembly,group=assembly,x=expMethod,y=count,label=count),position=position_dodge(1.0),vjust=-0.1,size=3)+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        #axis.text.x=element_text(color='black',angle=90,hjust=0.8,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');expplot

spacegroupplot=ggplot(transform(spacegroup, spaceGroup = reorder(spaceGroup, -count)),aes(x=spaceGroup,y=count))+
  geom_bar(aes(fill=assembly),alpha=alpha_value)+
  scale_color_manual(values=c(xtal_color,bio_color),name="Assembly")+
  scale_fill_manual(values=c(xtal_color,bio_color),name="Assembly")+
  xlab('Space group')+
  ylab('Number of PDBs')+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text.x=element_text(color='black',angle=90,hjust=1,vjust=0.5),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');

opplot=ggplot(transform(op, operatorType = reorder(operatorType, -count)),aes(x=operatorType,y=count))+
  geom_bar(aes(fill=final),alpha=alpha_value)+
  scale_color_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  scale_fill_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  xlab('Operator type')+
  ylab('Count')+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        legend.position='bottom');



jcolors<-c("#a6611a","#dfc27d","#80cdc1","#018571")
janinplot=ggplot()+scale_color_manual(values=jcolors)+ #scale_color_brewer(palette="cbPalette") +
  geom_line(data=subset(janindata,area>600),aes(x=area,y=density,color='Janin'),size=1.0)+
  geom_line(data=subset(infinite,area>600),aes(x=area,y=..density..,color='Infinite assemblies'),stat='bin',binwidth=25,drop=T,size=1.0)+
  geom_line(data=subset(eppic,cs=='xtal' & cr=='xtal' & area>600),aes(x=area,y=..density..,color='Xtal based on evolution'),stat='bin',binwidth=25,drop=T,size=1.0)+
  geom_line(data=subset(eppic,gm=='xtal' & area>600),aes(x=area,y=..density..,color='Xtal based on geometry'),stat='bin',binwidth=25,drop=T,size=1.0)+
  #  stat_bin(data=infinite,aes(x=area,color='Infinite assemblies',y=..density..),geom="line",binwidth=25,drop=T,size=1.0) + 
  #geom_histogram(data=infinite,aes(x=area,y=..density..,fill='Infinite assemblies'),binwidth=25,alpha=.5) +
  #  geom_line(data=subset(eppic,cs=='xtal' & cr=='xtal' & area>350),aes(x=area,y=..density..,color='Xtal based on evolution'),stat='bin',size=1.0,drop=T,binwidth=25)+
  #geom_histogram(data=subset(eppic,cs=='xtal' & cr=='xtal' & area>350),aes(x=area,y=..density..,fill='Xtal based on evolution'),binwidth=25,alpha=.5)+
  #  geom_line(data=subset(eppic,gm=='xtal' & area>350),aes(x=area,y=..density..,color='Xtal based on geometry'),stat='bin',size=1.0,drop=T,binwidth=25)+
  #geom_histogram(data=subset(eppic,gm=='xtal' & area>350),aes(x=area,y=..density..,fill='Xtal based on geometry'),binwidth=25,alpha=.5)+
  ylim(0,0.006)+xlim(0,2500)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab("Probability")+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');janinplot

nmrplot=ggplot(nmr)+
  geom_bar(aes(x=chains,y=count),stat='identity',fill='#1b9e77')+
  scale_x_continuous(breaks=1:15)+
  scale_y_log10(breaks=c(10,100,1000,5000,2500,10000))+
  geom_text(aes(x=chains,y=count,label=count),vjust=-0.5)+
  xlab('Number of chains')+
  ylab('Number of PDBs')+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');

pisaplot=ggplot(pdata)+scale_fill_manual(values=cbPalette)+
  geom_bar(aes(x=area,fill=remark),
           position=position_fill(height=100),stat='bin',binwidth=200)+
  #geom_line(aes(x=area,y=..count..,color=issame,ymax=1),
  #         position=position_fill(height=100),stat='bin',binwidth=200)+
  xlim(0,5000)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Ratio of the interface calls with in a bin')+
  annotate("text", label = sprintf("%.2f %%",xx), x = 500, y = 0.3)+
  annotate("text", label = sprintf("%.2f %%",bb), x = 3000, y = 0.5 )+
  annotate("text", label = sprintf("%.2f %%",xb), x = 1100, y = 0.85)+
  annotate("text", label = sprintf("%.2f %%",bx), x = 1200, y = 0.97)+
  #geom_hline(aes(yintercept=pisaavg,label='average'),linetype="dashed",show_guide=T)+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');pisaplot

autplot=ggplot(pdata2)+scale_fill_manual(values=cbPalette)+scale_color_manual(values=cbPalette)+
  #geom_bar(aes(x=area,fill=remark,color=remark),
           #position='identity',
          # stat='bin',binwidth=200,alpha=0.7)+
  geom_line(aes(x=area,fill=remark,color=remark),
           position='identity',
           stat='bin',binwidth=200,alpha=1.0,size=1)+
  xlim(0,5000)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Count')+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');autplot
p2=ggplot()+
  geom_bar(dat=epvsaut,aes(x=csScore,fill=cs),,position='identity',bin='stat',binwidth=0.1,alpha=.5)+
  geom_bar(dat=ep2,aes(x=csScore,fill=cs),,position='identity',bin='stat',binwidth=0.1,alpha=.5)+
  scale_color_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  scale_fill_manual(values=c(bio_color,xtal_color),name="Eppic final")+
  xlab('Core surface score')+
  ylab('Count')+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');p2
  #ggtitle(sprintf("xtal cutoff=%0.2f,biocutoff=%0.2f",min(subset(ep2,cs=='xtal')$csScore),max(subset(ep2,cs=='bio')$csScore)))
autplot2=grid.arrange(autplot, p2)

pdf("auth.pdf")
autplot
dev.off()

pdf("pisa.pdf")
pisaplot
dev.off()

pdf("bench_area.pdf")
benchmark_areaplot
dev.off()
pdf("bench_area_free.pdf")
benchmark_area_free
dev.off()
pdf("roc.pdf")
rocplot
dev.off()
pdf("janin.pdf")
janinplot
dev.off()
pdf("area_vs_core.pdf")
areavscore
dev.off()
pdf("area_hist.pdf")
areaplot
dev.off()
pdf("core_hist.pdf")
coreplot
dev.off()
pdf("exp_stat.pdf")
expplot
dev.off()
pdf("spacegroup.pdf")
spacegroupplot
dev.off()
pdf("operatortype.pdf")
opplot
dev.off()
pdf("nmr_chains.pdf")
nmrplot
dev.off()


janinplot2=ggplot()+  scale_color_brewer(palette="Dark2") +
  geom_line(data=infinite,aes(x=area,y=..count..,color='Infinite assemblies'),stat='bin',binwidth=25,drop=T,size=1.0)+
  geom_line(data=subset(eppic,cs=='xtal' & cr=='xtal' & area>0),aes(x=area,y=..count..,color='Xtal based on evolution'),stat='bin',binwidth=25,drop=T,size=1.0)+
  geom_line(data=subset(eppic,gm=='xtal' & area>0),aes(x=area,y=..count..,color='Xtal based on geometry'),stat='bin',binwidth=25,drop=T,size=1.0)+
  xlim(0,2500)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab("Probability")+
  theme(panel.background = element_blank(),
        text = element_text(size=font_size,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');janinplot2
