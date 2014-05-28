import sys,os
from string import atoi,atof
import commands
def get_stat(dbname):
	cmd="mysql %s -N -B -e 'select count(*) from Job where length(jobId)=4'"%(dbname)
	PdbCount=atof(commands.getoutput(cmd))
	cmd="mysql %s -N -B -e 'select count(*) from Job where length(jobId)=4 and status=\"Finished\"'"%(dbname) 
	EppiCcount=atof(commands.getoutput(cmd))
	cmd="mysql %s -N -B -e 'select count(*) from InterfaceScore as ic inner join Interface as i on i.uid=ic.interfaceItem_uid inner join InterfaceCluster as icl on i.interfaceCluster_uid=icl.uid inner join PdbInfo as p on p.uid=icl.pdbInfo_uid inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and ic.method=\"eppic\"'"%(dbname)
	InterfaceCount=atof(commands.getoutput(cmd))
	cmd="mysql %s -N -B -e 'select count(*) from InterfaceScore as ic inner join Interface as i on i.uid=ic.interfaceItem_uid inner join InterfaceCluster as icl on i.interfaceCluster_uid=icl.uid inner join PdbInfo as p on p.uid=icl.pdbInfo_uid inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and ic.method=\"eppic\" and ic.callName=\"bio\"'"%(dbname)
	BioCount=atof(commands.getoutput(cmd))
	cmd="mysql %s -N -B -e 'select count(*) from InterfaceScore as ic inner join Interface as i on i.uid=ic.interfaceItem_uid inner join InterfaceCluster as icl on i.interfaceCluster_uid=icl.uid inner join PdbInfo as p on p.uid=icl.pdbInfo_uid inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and ic.method=\"eppic\" and ic.callName=\"xtal\"'"%(dbname)
	XtalCount=atof(commands.getoutput(cmd))
	cmd="mysql %s -N -B -e 'select count(*) from ChainCluster as c inner join PdbInfo as p on p.uid=c.pdbInfo_uid inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4'"%(dbname)
	ChainCount=atof(commands.getoutput(cmd))
	cmd="mysql %s -N -B -e 'select count(*) from ChainCluster as c inner join PdbInfo as p on p.uid=c.pdbInfo_uid inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and c.hasUniProtRef'"%(dbname)
	ChainHasUniprot=atof(commands.getoutput(cmd))
	cmd="mysql %s -N -B -e 'select count(*) from ChainCluster as c inner join PdbInfo as p on p.uid=c.pdbInfo_uid inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and c.hasUniProtRef and c.seqIdCutoff>0.59 and c.numHomologs>=10'"%(dbname)
	ChainHas10H60P=atof(commands.getoutput(cmd))
	cmd="mysql %s -N -B -e 'select count(*) from ChainCluster as c inner join PdbInfo as p on p.uid=c.pdbInfo_uid inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and c.hasUniProtRef and c.seqIdCutoff>0.49 and c.numHomologs>=10'"%(dbname)
	ChainHas10H50P=atof(commands.getoutput(cmd))
	cmd="mysql %s -N -B -e 'select expMethod,count(*) from PdbInfo as p inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 group by p.expMethod order by count(*) desc'"%(dbname)
	ExpStat=commands.getoutput(cmd).split("\n")
	cmd="mysql %s -N -B -e 'select spaceGroup,count(*) from PdbInfo as p inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and p.spaceGroup is not NULL group by p.spaceGroup order by count(*) desc'"%(dbname)
	SpacegroupStat=commands.getoutput(cmd).split("\n")

	
	print 
	print "\t================================ Statistics on %s database==============================="%(dbname)
	print "\tTotal number of PDBs in the database\t\t\t\t\t=\t",PdbCount
	print "\tTotal number of PDBs with EPPIC results\t\t\t\t\t=\t",EppiCcount,"(",(EppiCcount/PdbCount)*100,"%)"
	print
	print "\t========================== Interface Statistics=================================================="
	print "\tTotal number of Interfaces\t\t\t\t\t\t=\t",InterfaceCount
	print "\tTotal number of Bio Interfaces\t\t\t\t\t\t=\t",BioCount,"(",(BioCount/InterfaceCount)*100,"%)"
	print "\tTotal number of Xtal Interfaces\t\t\t\t\t\t=\t",XtalCount,"(",(XtalCount/InterfaceCount)*100,"%)"
	print
	print "\t========================== Chain Statistics=================================================="
	print "\tTotal number of Chains\t\t\t\t\t\t\t=\t",ChainCount
	print "\tTotal number of Chains having Uniprot maping\t\t\t\t=\t",ChainHasUniprot,"(",(ChainHasUniprot/ChainCount)*100,"%)"
	print "\tTotal number of Chains having atleast 10 homologs and 60% seq identity\t=\t",ChainHas10H60P,"(",(ChainHas10H60P/ChainHasUniprot)*100,"%)"
	print "\tTotal number of Chains having atleast 10 homologs and 50% seq identity\t=\t",ChainHas10H50P,"(",(ChainHas10H50P/ChainHasUniprot)*100,"%)"
	print
	print "\t========================== Experiment Statistics=================================================="
	for i in ExpStat:
		w=i.split("\t")
		print "\t%30s\t\t\t=\t%f\t(%f)"%(w[0],atof(w[1]),100*(atof(w[1])/PdbCount))
	print
	print "\t========================== Space group Statistics=================================================="
	sume=sum([atof(i.split("\t")[1]) for i in SpacegroupStat])
	for i in SpacegroupStat:
		w=i.split("\t")
		print "\t%15s\t\t\t=\t%f\t(%f)"%(w[0],atof(w[1]),100*(atof(w[1])/sume))
	print
if __name__=="__main__":
	dbname=sys.argv[1]
	get_stat(dbname)	






