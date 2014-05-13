setwd('~/pdbstatistics/')
library(RMySQL)
library(ggplot2)


mydb=dbConnect(MySQL(),host="mpc1153",username="root",password="edb+1153",dbname="crk_2014_02")
on.exit(dbDisconnect(mydb))

dbListTables(mydb)

#result = dbSendQuery(mydb, "select count(*) from many_xtal2;")
#fetch(result)
loadBenchmark = function(db, #database name
                         method, #method cr or cs 
                         db_bio=paste(db,"_bio",sep=""), # bio db name
                         db_xtal=paste(db,"_xtal",sep=""), # xtal db name
                         data=NA #dataframe returned from previous call
                         )
{
  columns = sprintf("pdbName,size1,size2,resolution,area,%sScore,%s outcome",method,method)
  where = sprintf(" where %s != 'nopred' and %sScore is not NULL and h1>10 and h2>10",method,method)
  result=dbSendQuery(mydb,sprintf("select %s from %s%s;",columns,db_bio,where))
  bio=fetch(result,n=-1)
  result=dbSendQuery(mydb,sprintf("select %s from %s%s;",columns,db_xtal,where))
  xtal=fetch(result,n=-1)
  
  bio$benchmark=db
  xtal$benchmark=db
#  bio$met=method
#  xtal$met=method
  bio$truth="bio"
  xtal$truth="xtal"
  
  if (all(is.na(data))){
    data = rbind(bio,xtal)
  }else{
    data = rbind(data,bio,xtal)
  }
}
data=loadBenchmark("dc","cr")
#data=loadBenchmark("dc","cs",data=data)
data=loadBenchmark("po","cr",data=data)
data=loadBenchmark("many","cr",data=data)
#data=loadBenchmark("many","cs",data=data)
# Figure from paper
#data=loadBenchmark("many","cs")
plot1 = ggplot(data) + geom_boxplot(aes(x=benchmark,y=area,facet=benchmark, color=truth)); plot1

# Jitter plot, also highlighting false positives
plot2 = ggplot(data) + geom_jitter( aes(x=benchmark,y=area,facet=benchmark, color=outcome,shape=truth,size=3.5),alpha=.5 ); plot2

# Distributions
plot3 = ggplot(data,aes(facet=benchmark)) + ggtitle("Interface Area") + geom_density( aes(x=area, color=benchmark,linetype=truth, fill = benchmark), alpha=.2 ) + geom_vline(xintercept=1000, color="red",linetype=2,alpha=.5) + geom_vline(xintercept=2000, color="red",linetype=1,alpha=.5); plot3 #all plots together


plot3 = ggplot(data) + facet_grid(benchmark ~ .) + ggtitle("Interface Area") + geom_density( aes(x=area, color=truth,linetype=truth, fill = truth), alpha=.2, kernel="opt") + geom_vline(aes(xintercept=x),linetype=2,alpha=.5,data=data.frame(x=1000,benchmark="many")) + geom_vline(aes(xintercept=x), linetype=1,alpha=.5, data=data.frame(x=2000,benchmark="many") ) ; plot3 #individual plots


plot3 = ggplot(data) + facet_grid(benchmark ~ .) + ggtitle("Interface Area") + geom_line( aes(x=area, color=truth,linetype=truth,fill=truth), stat="density") + geom_histogram(aes(x=area,y=..density..,fill=truth), alpha=.2,binwidth=100,position="Identity") + geom_vline(aes(xintercept=x,color=truth),alpha=1,data=data.frame(x=1000,benchmark="many",truth="xtal")) + geom_vline(aes(xintercept=x,color=truth), linetype=1, data=data.frame(x=2000,benchmark="many",truth="bio") ) + xlab(expression(paste("Interface Area ",group("(",ring(A)^2,")")))); plot3 #hist/line


# Core size
plot5 = ggplot(data) + facet_grid(truth ~ .) + ggtitle("Interface Size") + geom_histogram( aes(x=size1+size2, y=..density.., color=benchmark, fill = benchmark), alpha=.2,binwidth=1 ,position="dodge") ; plot5

plot5 = ggplot(data) + facet_grid(benchmark ~ .) + ggtitle("Interface Size") + geom_density( aes(x=size1+size2, color=truth,linetype=truth, fill = truth), alpha=.2, kernel="opt") ; plot5

plot5 = ggplot(data, aes(x=size1+size2,fill=truth)) + facet_grid(benchmark ~ .) + ggtitle("Interface Size") + geom_line( aes( color=truth,linetype=truth), stat="Density") + geom_histogram(aes(y=..density..),position="Identity",alpha=.5,binwidth=1); plot5

plot6 = ggplot(data) + facet_grid(benchmark ~ .) + ggtitle("Core size vs. Interface area") + geom_point(aes(x=area,y=size1+size2,color=truth),size=1); plot6

plot7 = ggplot(data) + facet_grid(benchmark ~ .) + ggtitle("Resolution distribution") + geom_density( aes(x=resolution, color=truth,linetype=truth, fill = truth), alpha=.2, kernel="opt") ; plot7

plot7 = ggplot(data,aes(x=resolution,fill=truth)) + facet_grid(benchmark ~ .) + ggtitle("Resolution distribution") + geom_line( aes(linetype=truth,color=truth), stat="Density") + geom_histogram(aes(y=..density..),position="Identity",alpha=.5,binwidth=.1); plot7

plot8 = ggplot(data) + facet_grid(. ~ benchmark) + ggtitle("Size vs resolution") + geom_point(aes(x=resolution,y=size1+size2,color=truth),alpha=.5); plot8

