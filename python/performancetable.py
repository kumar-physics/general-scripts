import sys,os,commands
from string import atoi,atof
from math import sqrt

def scores(tp,tn,fp,fn):
	p=tp+fn
	n=tn+fp
	sen=tp/p
	spe=tn/n
	acc=(tp+tn)/(p+n)
	mcc=((tp*tn)-(fp*fn))/sqrt(p*n*(tp+fp)*(tn+fn))
	return [sen,spe,acc,mcc]


def prepare_table():
	dcgm=get_score("dc","gm",0)
	dccr=get_score("dc","cr",0)
	dccs=get_score("dc","cs",0)
	dcfinal=get_score("dc","final",0)
	dcgm50=get_score("dc","gm",50)
	dccr50=get_score("dc","cr",50)
	dccs50=get_score("dc","cs",50)
	dcfinal50=get_score("dc","final",50)
	pogm=get_score("po","gm",0)
	pocr=get_score("po","cr",0)
	pocs=get_score("po","cs",0)
	pofinal=get_score("po","final",0)
	pogm50=get_score("po","gm",50)
	pocr50=get_score("po","cr",50)
	pocs50=get_score("po","cs",50)
	pofinal50=get_score("po","final",50)
	manygm=get_score("many","gm",0)
	manycr=get_score("many","cr",0)
	manycs=get_score("many","cs",0)
	manyfinal=get_score("many","final",0)
	manygm50=get_score("many","gm",50)
	manycr50=get_score("many","cr",50)
	manycs50=get_score("many","cs",50)
	manyfinal50=get_score("many","final",50)
	#print dcgm,dccr,dccs,dcgm50,dccr50,dccs50
	#print pogm,pocr,pocs,pogm50,pocr50,pocs50
	#print manygm,manycr,manycs,manygm50,manycr50,manycs50
	#print dcgm,dcgm50
	cmd="mysql eppic_2_1_0_2014_05 -N -B -e 'select chainCount chains,count(*) count from chainCount where expMethod=\"SOLUTION NMR\" group by chainCount union all select 1 chains, (select count(*) from PdbInfo as p inner join Job as j on j.uid=p.job_uid where p.expMethod=\"SOLUTION NMR\" and length(j.jobId)=4) - (select count(*) from chainCount where expMethod=\"SOLUTION NMR\") count order by chains; '"
	nmr=commands.getoutput(cmd).split("\n")
	
	fo=open("../tables.tex",'w')
	fo.write("\n\\begin{table}[h!]\n\t\\caption{Eppic performance}\n\t\label{benchmark}\n\t\\begin{scriptsize}\n\t\\begin{tabular}{|l|l|l|l|l|l|l|l|l|l|l|}\n\t\hline\n")
	fo.write("\t\tDataSet & N & Method & Sensitivity & Sensitivity & Specificity & Specificity &  Accuracy & Accuracy & MCC & MCC\\\\\n")
	fo.write("\t\t &($>$50 homo.)& & & $>$50 homo. & &  $>$50 homo.& & $>$ 50 homo. & &$>$50 homo. \\\\ \hline\n")

	fo.write("\t\tDC & & Geometry & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n"%(dcgm[0],dcgm50[0],dcgm[1],dcgm50[1],dcgm[2],dcgm50[2],dcgm[3],dcgm50[3]))
	fo.write("\t\tBio& %d(%d)&Core Rim & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n"%(dcgm[4],dcgm50[4],dccr[0],dccr50[0],dccr[1],dccr50[1],dccr[2],dccr50[2],dccr[3],dccr50[3]))
	fo.write("\t\tXtal& %d(%d)&Core Sur & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n"%(dcgm[5],dcgm50[5],dccs[0],dccs50[0],dccs[1],dccs50[1],dccs[2],dccs50[2],dccs[3],dccs50[3]))
	fo.write("\t\t& & Final & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\ \hline\n"%(dcfinal[0],dcfinal50[0],dcfinal[1],dcfinal50[1],dcfinal[2],dcfinal50[2],dcfinal[3],dcfinal50[3]))	

	fo.write("\t\tPonstingl & & Geometry & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n"%(pogm[0],pogm50[0],pogm[1],pogm50[1],pogm[2],pogm50[2],pogm[3],pogm50[3]))
	fo.write("\t\tBio& %d(%d)&Core Rim & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n"%(pogm[4],pogm50[4],pocr[0],pocr50[0],pocr[1],pocr50[1],pocr[2],pocr50[2],pocr[3],pocr50[3]))
	fo.write("\t\tXtal& %d(%d)&Core Sur & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n"%(pogm[5],pogm50[5],pocs[0],pocs50[0],pocs[1],pocs50[1],pocs[2],pocs50[2],pocs[3],pocs50[3]))
	fo.write("\t\t& & Final & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\ \hline\n"%(pofinal[0],pofinal50[0],pofinal[1],pofinal50[1],pofinal[2],pofinal50[2],pofinal[3],pofinal50[3]))	


	fo.write("\t\tMany & & Geometry & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n"%(manygm[0],manygm50[0],manygm[1],manygm50[1],manygm[2],manygm50[2],manygm[3],manygm50[3]))
	fo.write("\t\tBio& %d(%d)&Core Rim & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n"%(manygm[4],manygm50[4],manycr[0],manycr50[0],manycr[1],manycr50[1],manycr[2],manycr50[2],manycr[3],manycr50[3]))
	fo.write("\t\tXtal& %d(%d)&Core Sur & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n"%(manygm[5],manygm50[5],manycs[0],manycs50[0],manycs[1],manycs50[1],manycs[2],manycs50[2],manycs[3],manycs50[3]))
	fo.write("\t\t& & Final & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f & %.4f \\\\ \hline\n"%(manyfinal[0],manyfinal50[0],manyfinal[1],manyfinal50[1],manyfinal[2],manyfinal50[2],manyfinal[3],dcfinal50[3]))	

	fo.write("\n\t\end{tabular}\n\t\end{scriptsize}\n\end{table}\n")
	
	ss=sum([atof(xx.split("\t")[1]) for xx in nmr])
	fo.write("\n\\begin{table}[h!]\n\caption{NMR statistics as of May 27, 2014}\n\t\label{nmrtable}\n\t\t\\begin{tabular}{|r|r|c|}\n\hline")
	fo.write("\n\t\t Chains &  PDBs & Percentage \\\\ \hline ")
	fo.write("\n\t\t %d & %d & %.2f \%%\\\\ "%(atof(nmr[0].split("\t")[0]),atof(nmr[0].split("\t")[1]),(atof(nmr[0].split("\t")[1])/ss)*100 ))
	fo.write("\n\t\t %d & %d & %.2f \%%\\\\ "%(atof(nmr[2].split("\t")[0]),atof(nmr[1].split("\t")[1])+atof(nmr[2].split("\t")[1]),((atof(nmr[1].split("\t")[1])+atof(nmr[2].split("\t")[1]))/ss)*100))
	for nn in range(3,len(nmr)):
		#w=nn.split("\t")
		fo.write("\n\t\t %d & %d & %.2f \%%\\\\ "%(atof(nmr[nn].split("\t")[0]),atof(nmr[nn].split("\t")[1]),(atof(nmr[nn].split("\t")[1])/ss)*100))
	fo.write("\hline\n\t\t\end{tabular}\n\end{table}")
	fo.close()
	


def get_score(db,method,h):
	cmd="mysql eppic_2_1_0_2014_05 -N -B -e 'select count(*) from %s_bio where h1>=%d and h2>=%d and  %s=\"bio\"'"%(db,h,h,method)
	tp=atof(commands.getoutput(cmd))
	cmd="mysql eppic_2_1_0_2014_05 -N -B -e 'select count(*) from %s_xtal where h1>=%d and h2>=%d and  %s=\"xtal\"'"%(db,h,h,method)
	tn=atof(commands.getoutput(cmd))
	cmd="mysql eppic_2_1_0_2014_05 -N -B -e 'select count(*) from %s_xtal where h1>=%d and h2>=%d and  %s=\"bio\"'"%(db,h,h,method)
	fp=atof(commands.getoutput(cmd))
	cmd="mysql eppic_2_1_0_2014_05 -N -B -e 'select count(*) from %s_bio where h1>=%d and h2>=%d and  %s=\"xtal\"'"%(db,h,h,method)
	fn=atof(commands.getoutput(cmd))
	cmd="mysql eppic_2_1_0_2014_05 -N -B -e 'select count(*) from %s_bio where h1>=%d and h2>=%d'"%(db,h,h)
	bn=atoi(commands.getoutput(cmd))
	cmd="mysql eppic_2_1_0_2014_05 -N -B -e 'select count(*) from %s_xtal where h1>=%d and h2>=%d'"%(db,h,h)
	xn=atoi(commands.getoutput(cmd))
	x=scores(tp,tn,fp,fn)
	x.append(bn)
	x.append(xn)
	return x

if __name__=="__main__":
	#db=sys.argv[1]
	#h=atoi(sys.argv[3])
	#method=sys.argv[2]
	#get_score(db,method,h)
	prepare_table()
