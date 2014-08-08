library(RMySQL)
library(ggplot2)
library(stats)
mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05")

ep=fetch(dbSendQuery(mydb,"select * from detailedTable group by c1_90"),-1)


ep$res[ep$resolution<1.4]='(a)higher than 1.4 A'
ep$res[ep$resolution>=1.4 & ep$resolution<2.0]='(b)between 1.4 A and 2A'
ep$res[ep$resolution>=2.0 & ep$resolution<2.33]='(c)between 2.0 A and 2.33A'
ep$res[ep$resolution>=2.33 & ep$resolution<2.66]='(d)between 2.33 A and 2.66A'
ep$res[ep$resolution>=2.66 & ep$resolution<3]='(e)between 2.6 A and 3.0A'
ep$res[ep$resolution>=3.0]='(f)lower than 3 A'

ep$arealabel[ep$area<2000]='a.less than 2000'
ep$arealabel[ep$area>=2000 & ep$area<3000]='b.between 2000 and 3000'
ep$arealabel[ep$area>=3000 & ep$area<4000]='c.between 3000 and 4000'
ep$arealabel[ep$area>=4000 & ep$area<5000]='d.between 4000 and 5000'
ep$arealabel[ep$area>=5000 & ep$area<6000]='e.between 5000 and 6000'
ep$arealabel[ep$area>=6000 & ep$area<7000]='f.between 6000 and 7000'
ep$arealabel[ep$area>=7000 & ep$area<8000]='g.between 7000 and 8000'
ep$arealabel[ep$area>=8000 & ep$area<9000]='h.between 8000 and 9000'
ep$arealabel[ep$area>=9000 & ep$area<10000]='i.between 9000 and 10000'
ep$arealabel[ep$area>=10000]='j.more than 10000'

ggplot(subset(ep,area>3000 & csScore >-1000 & resolution>0 & resolution<10 & h1>50 & h2>50))+
  geom_point(aes(x=arealabel,y=csScore,color=res))


ggplot(subset(ep,area>3000 & area<10000 & csScore >-1000 & resolution>0 & resolution<10 & h1>50 & h2>50))+
  geom_density2d(aes(x=area,y=csScore,color=res),bins=500,alpha=0.33)

ggplot(subset(ep,area>3500 & area<10000 & csScore >-1000 & resolution>0 & resolution<10 & h1>50 & h2>50))+
  geom_point(aes(x=area,y=csScore,color=res),bins=500,alpha=0.33,size=5.0)+geom_smooth()

ggplot(subset(ep,area>3500 & area<10000 & csScore >-1000 & resolution>0 & resolution<10 & h1>50 & h2>50))+
  geom_point(aes(x=resolution,y=csScore,color=area),bins=500,alpha=0.33,size=5.0)

qplot(x=resolution,y=csScore,
      data=subset(ep,area>3500 & area<10000 & csScore >-1000 & resolution>0 & resolution<10 & h1>50 & h2>50))+
  stat_smooth(geom='smooth',method = nls,formula="y ~ a * x*x")

give.n <- function(x){
  return(c(y = median(x)*1.1, label = length(x))) 
  # experiment with the multiplier to find the perfect position
}
mean.n <- function(x){
  return(c(y = median(x)*0.9, label = round(mean(x),2))) 
  # experiment with the multiplier to find the perfect position
}


ggplot(subset(ep3,area>3500 & area<8000 & csScore >-1000 & resolution>0 & resolution<10 & h1>50 & h2>50),
       aes(x=reslab,y=csScore))+
  geom_boxplot()+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red")


ggplot(subset(ep,area>3500 & area<10000 & csScore >-1000 & resolution>0 & resolution<10 & h1>50 & h2>50))+
  geom_boxplot(aes(x=res,y=csScore))


ep2=subset(ep,area>3500 & area<8000 & csScore >-1000 & resolution>0 & resolution<10 & h1>50 & h2>50)

ep3=ep2[with(ep2,order(resolution)),]
ep3$reslab='no lab'
n=100
for (i in seq(1,length(ep3$resolution),n)){
  maxn=i+n-1
  if (maxn>length(ep3$resolution)){
    maxn=length(ep3$resolution)
  }
  minr=min(ep3$resolution[i:maxn])
  maxr=max(ep3$resolution[i:maxn])
  lab=sprintf("%.2f to %.2f",minr,maxr)
  ep3$reslab[i:maxn]=lab
}
plotres=ggplot(ep3,
       aes(x=reslab,y=csScore))+
  geom_boxplot(notch=TRUE)+
  stat_summary(fun.data = give.n, geom = "text", fun.y = median) +
  stat_summary(fun.data = mean.n, geom = "text", fun.y = mean, colour = "red")+
  xlab("Resolution")+
  ylab("Core-surface score")+
  ggtitle("Area btw. 3500 to 8000 homologs > 50 resolution < 10")+
  theme(panel.background = element_blank(),
        text = element_text(color='black'),
        axis.text=element_text(color='black'),
        panel.border =element_rect(colour = "black",fill=NA),
        panel.grid.major = element_line(colour = "gray"),
        panel.grid.minor = element_line(colour = "gray",linetype="dashed"),
        legend.title=element_blank(),
        legend.position='bottom');
setwd('/home/baskaran_k/publications/Structure_validation_analysis')
pdf('res_vs_csscore.pdf')
plotres
dev.off()

