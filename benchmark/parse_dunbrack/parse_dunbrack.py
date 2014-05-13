import tarfile,re
import os
import commands
workpath='/media/baskaran_k/data/protcid/protcid/clusters/'


def parse_dunbrack(fname):
	t=tarfile.open(fname,'r:gz')
	base=fname.split(".tar.gz")[0].split("/")[-1].replace("(","").replace(")","").replace(";","")
	#foname="%s.parsed"%(base)
	#fo=open(foname,'w')
	for f in t.getmembers():
		if "cryst" in f.name:
			pdb=f.name.split(".cryst")[0].split("_")[0]
			ifaceid=f.name.split(".cryst")[0].split("_")[1]
			dat=t.extractfile(f).read()
			opdat=dat.split("Remark 300 Interface")
			l1=opdat[1].split("\n")[0]
			l2=opdat[2].split("\n")[0]
			#print l1
			#print l2
			try:
				d=re.findall(r'[\s\S]+Author\sChain\s(\w)[\s\S]+\s+(\S+,\S+\S+)\s+[\s\S]+Author\sChain\s(\w)[\s\S]+\s+(\S+,\S+,\S+)\s+[\S\s]+surface\s+\S+\s+(\d+[\.\d]+)\s+[\s\S]+',dat)[0]
				#fo.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\n"%(pdb,ifaceid,d[0],d[1],d[2],d[3],d[4]))
				res=[pdb,ifaceid,d[0],d[1],d[2],d[3],d[4]]
			except IndexError:
				print l1,l2
	#fo.close()
	return res



def do_all(fname):
	f=open(fname,'r').read().split("\n")[:-1]
	for fl in f:
		p=workpath+fl+"/"
		try:
			cmd="ls %s*.tar.gz"%(p)
			c1=cmd.replace("(","\(")
			c2=c1.replace(")","\)")
			c3=c2.replace(";","\;")
			flist=commands.getoutput(c3).split("\n")
			for f1 in flist:
				print "working on ",p
				parse_dunbrack(f1)
		except IOError:
			print cmd	
		




if __name__=="__main__":
	#parse_dunbrack("(4HBT)_1.tar.gz")
	do_all("folder.list")
