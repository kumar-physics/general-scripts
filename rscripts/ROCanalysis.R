setwd('~/pdbstatistics/')
library(RMySQL)
library(ggplot2)
library(plyr)
mydb=dbConnect(MySQL(),host="mpc1153",username="root",password="edb+1153",dbname="eppic_test_2_1_0")
on.exit(dbDisconnect(mydb))


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
data=loadBenchmark("dc")
data=loadBenchmark("po",data=data)
data=loadBenchmark("many",data=data)
head(data)
colnames(data)[55]='dataset'

dc_cr<-subset(data,dataset=="dc" & cr!="nopred",select=c(crScore,truth,cr))
dc_cs<-subset(data,dataset=="dc" & cs!="nopred",select=c(csScore,truth,cs))
po_cr<-subset(data,dataset=="po" & cr!="nopred",select=c(crScore,truth,cr))
po_cs<-subset(data,dataset=="po" & cs!="nopred",select=c(csScore,truth,cs))
many_cr<-subset(data,dataset=="many" & cr!="nopred" & crScore<500,select=c(crScore,truth,cr))
many_cs<-subset(data,dataset=="many" & cs!="nopred"& crScore<500,select=c(csScore,truth,cs))



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
    if (i==length(d$score)){
      tn=0
    }else{
      tn=subset(count(subset(d,score>d$score[i]),'truth'),truth=='xtal')$freq
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
cs=roc(dc_cs$csScore,dc_cs$truth,'dc')
cs=roc(po_cs$csScore,po_cs$truth,'po',dat=cs)
cs=roc(many_cs$csScore,many_cs$truth,'many',dat=cs)
cr=roc(dc_cr$crScore,dc_cr$truth,'dc')
cr=roc(po_cr$crScore,po_cr$truth,'po',dat=cr)
cr=roc(many_cr$crScore,many_cr$truth,'many',dat=cr)


tmp1<-subset(cs,select=c(cutoff,sensitivity,dataset))
colnames(tmp1)[2]='score'
tmp1$benchmark='sensitivity'
tmp2<-subset(cs,select=c(cutoff,specificity,dataset))
colnames(tmp2)[2]='score'
tmp2$benchmark='specificity'
cs1=rbind(tmp1,tmp2)

tmp1<-subset(cr,select=c(cutoff,sensitivity,dataset))
colnames(tmp1)[2]='score'
tmp1$benchmark='sensitivity'
tmp2<-subset(cr,select=c(cutoff,specificity,dataset))
colnames(tmp2)[2]='score'
tmp2$benchmark='specificity'
cr1=rbind(tmp1,tmp2)





plot1cr=ggplot(cr1,aes(cutoff))+geom_line(aes(y=score,color=dataset,linetype=benchmark))+xlim(0,3)+ggtitle('EPPIC core-rim');plot1cr
plot2cr=ggplot(cr)+geom_line(aes(x=cutoff,y=mcc,color=dataset,fill=dataset));plot2cr
plot3cr=ggplot(cr)+geom_line(aes(x=cutoff,y=accuracy,color=dataset));plot3cr
plot4cr=ggplot(cr)+geom_line(aes(x=1-specificity,y=sensitivity,color=dataset))+ggtitle('EPPIC core-rim');plot4cr

plot1cs=ggplot(cs1,aes(cutoff))+geom_line(aes(y=score,color=dataset,linetype=benchmark));plot1cs
plot2cs=ggplot(cs)+geom_line(aes(x=cutoff,y=mcc,color=dataset));plot2cs
plot3cs=ggplot(cs)+geom_line(aes(x=cutoff,y=accuracy,color=dataset));plot3cs
plot4cs=ggplot(cs)+geom_line(aes(x=1-specificity,y=sensitivity,color=dataset))+ggtitle('EPPIC core-surface');plot4cs

pdf('cr-ss.pdf')
plot1cr
dev.off()
pdf('cs-ss.pdf')
plot1cs
dev.off()
pdf('cr-mcc.pdf')
plot2cr
dev.off()
pdf('cs-mcc.pdf')
plot2cs
dev.off()
pdf('cr-acc.pdf')
plot3cr
dev.off()
pdf('cs-acc.pdf')
plot3cr
dev.off()
pdf('core-rim-roc.pdf')
plot4cr
dev.off()
pdf('core-surface-roc.pdf')
plot4cs
dev.off()


# roc_cr = function(dataset,
#                range,
#                tag,
#                dat=NA){
#   cutoff<-NULL
#   sensitivity<-NULL
#   specificity<-NULL
#   accuracy<-NULL
#   benchmark<-NULL
#   mcc<-NULL
#   p=length(subset(dataset,truth=="bio" & cr!="nopred")$truth)
#   n=length(subset(dataset,truth=="xtal" & cr!="nopred")$truth)
#   for(i in 1:length(range)){
#     tp=length(subset(dataset,truth=="bio"  & cr!="nopred" & crScore<=range[i])$truth)
#     tn=length(subset(dataset,truth=="xtal"  & cr!="nopred" & crScore>range[i])$truth)
#     fn=p-tp
#     fp=n-tn
#     benchmark<-c(benchmark,tag)
#     cutoff<-c(cutoff,range[i])
#     sensitivity<-c(sensitivity,tp/p)
#     specificity<-c(specificity,tn/n)
#     accuracy<-c(accuracy,(tp+tn)/(p+n))
#     mcc<-c(mcc,(((tp*tn)-(fp*fn))/(sqrt(p)*sqrt(n)*sqrt(tp+fp)*sqrt(tn+fn))))
#   }
#   if (all(is.na(dat))){
#     dat=data.frame(cutoff,sensitivity,specificity,accuracy,mcc,benchmark)
#   }else{
#     dat=rbind(dat,data.frame(cutoff,sensitivity,specificity,accuracy,mcc,benchmark))
#   }
# } 
# 
# roc_cs = function(dataset,
#                   range,
#                   tag,
#                   dat=NA){
#   cutoff<-NULL
#   sensitivity<-NULL
#   specificity<-NULL
#   accuracy<-NULL
#   benchmark<-NULL
#   mcc<-NULL
#   p=length(subset(dataset,truth=="bio" & cs!="nopred")$truth)
#   n=length(subset(dataset,truth=="xtal" & cs!="nopred")$truth)
#   for(i in 1:length(range)){
#     tp=length(subset(dataset,truth=="bio"  & cs!="nopred" & csScore<=range[i])$truth)
#     tn=length(subset(dataset,truth=="xtal"  & cs!="nopred" & csScore>range[i])$truth)
#     fn=p-tp
#     fp=n-tn
#     benchmark<-c(benchmark,tag)
#     cutoff<-c(cutoff,range[i])
#     sensitivity<-c(sensitivity,tp/p)
#     specificity<-c(specificity,tn/n)
#     accuracy<-c(accuracy,(tp+tn)/(p+n))
#     mcc<-c(mcc,(((tp*tn)-(fp*fn))/(sqrt(p)*sqrt(n)*sqrt(tp+fp)*sqrt(tn+fn))))
#   }
#   if (all(is.na(dat))){
#     dat=data.frame(cutoff,sensitivity,specificity,accuracy,mcc,benchmark)
#   }else{
#     dat=rbind(dat,data.frame(cutoff,sensitivity,specificity,accuracy,mcc,benchmark))
#   }
# } 
# 
# cs=roc_cs(dc_cs,cs_range,"dc")
# cs=roc_cs(po_cs,cs_range,"po",dat=cs)
# cs=roc_cs(many_cs,cs_range,"many",dat=cs)
# cr=roc_cr(dc_cr,cr_range,"dc")
# cr=roc_cr(po_cr,cr_range,"po",dat=cr)
# cr=roc_cr(many_cr,cr_range,"many",dat=cr)
# 
# 
# plot1cr=ggplot(cr)+geom_line(aes(x=cutoff,y=sensitivity,color=benchmark,fill=benchmark))+geom_line(aes(x=cutoff,y=specificity,color=benchmark,fill=benchmark));plot1cr
# plot2cr=ggplot(cr)+geom_line(aes(x=cutoff,y=mcc,color=benchmark,fill=benchmark));plot2cr
# plot3cr=ggplot(cr)+geom_line(aes(x=cutoff,y=accuracy,color=benchmark,fill=benchmark));plot3cr
# plot4cr=ggplot(cr)+geom_line(aes(x=1-specificity,y=sensitivity,color=benchmark,fill=benchmark));plot4cr
# 
# plot1cs=ggplot(cs)+geom_line(aes(x=cutoff,y=sensitivity,color=benchmark,fill=benchmark))+geom_line(aes(x=cutoff,y=specificity,color=benchmark,fill=benchmark));plot1cs
# plot2cs=ggplot(cs)+geom_line(aes(x=cutoff,y=mcc,color=benchmark,fill=benchmark));plot2cs
# plot3cs=ggplot(cs)+geom_line(aes(x=cutoff,y=accuracy,color=benchmark,fill=benchmark));plot3cs
# plot4cs=ggplot(cs)+geom_line(aes(x=1-specificity,y=sensitivity,color=benchmark,fill=benchmark));plot4cs
# 
