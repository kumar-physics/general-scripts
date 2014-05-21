setwd('~/pdb_statistics/')
library(RMySQL)
library(ggplot2)


mydb=dbConnect(MySQL(),dbname="eppic_test_2_1_0")
on.exit(dbDisconnect(mydb))

pdb=fetch(dbSendQuery(mydb,"select p.* from PdbInfo as p 
                          inner join Job as j on p.job_uid=j.uid 
                          where j.inputType=0;"),-1)

interface=fetch(dbSendQuery(mydb,"select * detailedTable"),-1)