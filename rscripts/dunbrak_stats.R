setwd('~/pdbstatistics/')
library(RMySQL)
library(ggplot2)


mydb=dbConnect(MySQL(),host="mpc1153",username="root",password="edb+1153",dbname="dunbrack")
on.exit(dbDisconnect(mydb))
dbListTables(mydb)

allpdb=dbSendQuery(mydb,"select * from pfam_80_stat;")
pdbdat=fetch(allpdb,-1)

head(pdbdat)

plot1=ggplot(pdbdat)+geom_point(aes(x=members,y=clusters,size=max_cluster_size,color=max_cluster_size))+scale_colour_gradientn(colours=rainbow(7));plot1
plot1a=ggplot(pdbdat)+geom_point(aes(x=members,y=max_cluster_size,size=clusters,color=max_cluster_size))+scale_colour_gradientn(colours=rainbow(7));plot1a

plot2=ggplot(pdbdat)+geom_histogram(aes(x=max_cluster_size));plot2
plot3=ggplot(pdbdat)+geom_histogram(aes(x=min_cluster_size));plot3
plot4=ggplot(pdbdat)+geom_histogram(aes(x=members),binwidth=5);plot4
plot5=ggplot(pdbdat)+geom_histogram(aes(x=clusters),binwidth=5);plot5
plot6=ggplot(pdbdat)+geom_density2d(aes(x=clusters,y=members));plot6
