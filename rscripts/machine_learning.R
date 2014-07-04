library(RMySQL)
library(ggplot2)
library(plyr)
library(reshape2)

mydb=dbConnect(MySQL(),dbname="eppic_2_1_0_2014_05") #~/.my.cnf file configured with right username and passwd
on.exit(dbDisconnect(mydb))

ep=fetch(dbSendQuery(mydb,"select * from EppicTable where
                     crScore>=0 and crScore<40 and
                     csScore>-40 and csScore<-40"),-1)
xt=fetch(dbSendQuery(mydb,"select * from many_xtal where
                     crScore>=0 and crScore<40 and
                     csScore>-40 and csScore<40 and
                     h1>30 and h2>30"),-1)
bo=fetch(dbSendQuery(mydb,"select * from many_bio where
                     crScore>=0 and crScore<40 and
                     csScore>-40 and csScore<40 and
                     h1>30 and h2>30"),-1)

xt$truth=0
bo$truth=1
xt$dat='xtal'
bo$dat='bio'
train=rbind(xt,bo)

mylogit <- glm(truth ~ gmScore + crScore + csScore, data = train, family = "binomial")
summary(mylogit)
confint(mylogit)
