setwd('~/test/plots')
library(RMySQL)
library(ggplot2)
library(plyr)
library(reshape2)
#dbconnection
mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05")
on.exit(dbDisconnect(mydb))


ep=fetch(dbSendQuery(mydb,"select pdbCode,interfaceId,area,gmScore core,gm,cr,cs,final eppic,
  pisa,authors,pqs,pisaCall pisa_db from EppicvsPisa"),-1)
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
pisaplot=ggplot(pdata)+
  geom_bar(aes(x=area,y=(..count..),fill=remark),
           position=position_fill(height=100),stat='bin',binwidth=200)+
  xlim(0,5000)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Interface ratio with in the area bin')+
  annotate("text", label = sprintf("%.2f %%",xx), x = 500, y = 0.3)+
  annotate("text", label = sprintf("%.2f %%",bb), x = 3000, y = 0.5 )+
  annotate("text", label = sprintf("%.2f %%",xb), x = 1100, y = 0.8)+
  annotate("text", label = sprintf("%.2f %%",bx), x = 1300, y = 0.97)+
  #geom_hline(aes(yintercept=pisaavg,label='average'),linetype="dashed",show_guide=T)+
  ggtitle('Eppic final vs Pisa db')+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');pisaplot
jpeg("eppicfinal_vs_pisa.jpg",width=1200,height=800)
pisaplot
dev.off()


ep=fetch(dbSendQuery(mydb,"select pdbCode,interfaceId,area,gmScore core,gm,cr,cs eppic,final,
  pisa,authors,pqs,pisaCall pisa_db from EppicvsPisa"),-1)
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
pisaplot=ggplot(pdata)+
  geom_bar(aes(x=area,y=(..count..),fill=remark),
           position=position_fill(height=100),stat='bin',binwidth=200)+
  xlim(0,5000)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Interface ratio with in the area bin')+
  annotate("text", label = sprintf("%.2f %%",xx), x = 500, y = 0.3)+
  annotate("text", label = sprintf("%.2f %%",bb), x = 3000, y = 0.5 )+
  annotate("text", label = sprintf("%.2f %%",xb), x = 1100, y = 0.8)+
  annotate("text", label = sprintf("%.2f %%",bx), x = 1300, y = 0.97)+
  #geom_hline(aes(yintercept=pisaavg,label='average'),linetype="dashed",show_guide=T)+
  ggtitle('Eppic core surface vs Pisa db')+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');pisaplot
jpeg("eppiccs_vs_pisa.jpg",width=1200,height=800)
pisaplot
dev.off()



ep=fetch(dbSendQuery(mydb,"select pdbCode,interfaceId,area,gmScore core,gm,cr eppic,cs,final,
  pisa,authors,pqs,pisaCall pisa_db from EppicvsPisa"),-1)
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
pisaplot=ggplot(pdata)+
  geom_bar(aes(x=area,y=(..count..),fill=remark),
           position=position_fill(height=100),stat='bin',binwidth=200)+
  xlim(0,5000)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Interface ratio with in the area bin')+
  annotate("text", label = sprintf("%.2f %%",xx), x = 500, y = 0.3)+
  annotate("text", label = sprintf("%.2f %%",bb), x = 3000, y = 0.5 )+
  annotate("text", label = sprintf("%.2f %%",xb), x = 1100, y = 0.8)+
  annotate("text", label = sprintf("%.2f %%",bx), x = 1300, y = 0.97)+
  #geom_hline(aes(yintercept=pisaavg,label='average'),linetype="dashed",show_guide=T)+
  ggtitle('Eppic core rim vs Pisa db')+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');pisaplot
jpeg("eppiccr_vs_pisa.jpg",width=1200,height=800)
pisaplot
dev.off()


ep=fetch(dbSendQuery(mydb,"select pdbCode,interfaceId,area,gmScore core,gm,cr,cs,final,
  pisa eppic,authors,pqs,pisaCall pisa_db from EppicvsPisa"),-1)
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
pisaplot=ggplot(pdata)+
  geom_bar(aes(x=area,y=(..count..),fill=remark),
           position=position_fill(height=100),stat='bin',binwidth=200)+
  xlim(0,5000)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Interface ratio with in the area bin')+
  annotate("text", label = sprintf("%.2f %%",xx), x = 500, y = 0.3)+
  annotate("text", label = sprintf("%.2f %%",bb), x = 3000, y = 0.5 )+
  annotate("text", label = sprintf("%.2f %%",xb), x = 900, y = 0.94)+
  annotate("text", label = sprintf("%.2f %%",bx), x = 950, y = 0.98)+
  #geom_hline(aes(yintercept=pisaavg,label='average'),linetype="dashed",show_guide=T)+
  ggtitle('Pisa pdb rim vs Pisa db')+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');pisaplot
jpeg("pisa_vs_pisa.jpg",width=1200,height=800)
pisaplot
dev.off()


ep=fetch(dbSendQuery(mydb,"select pdbCode,interfaceId,area,gmScore core,gm eppic,cr,cs,final,
                     pisa,authors,pqs,pisaCall pisa_db from EppicvsPisa"),-1)
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
pisaplot=ggplot(pdata)+
  geom_bar(aes(x=area,y=(..count..),fill=remark),
           position=position_fill(height=100),stat='bin',binwidth=200)+
  xlim(0,5000)+
  xlab(expression(paste("Interface area (",ring(A)^"2",")")))+
  ylab('Interface ratio with in the area bin')+
  annotate("text", label = sprintf("%.2f %%",xx), x = 500, y = 0.3)+
  annotate("text", label = sprintf("%.2f %%",bb), x = 3000, y = 0.5 )+
  annotate("text", label = sprintf("%.2f %%",xb), x = 1100, y = 0.8)+
  annotate("text", label = sprintf("%.2f %%",bx), x = 1300, y = 0.97)+
  #geom_hline(aes(yintercept=pisaavg,label='average'),linetype="dashed",show_guide=T)+
  ggtitle('Eppic geometry vs Pisa db')+
  theme(panel.background = element_blank(),
        text = element_text(size=20,color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');pisaplot
jpeg("eppicgm_vs_pisa.jpg",width=1200,height=800)
pisaplot
dev.off()
