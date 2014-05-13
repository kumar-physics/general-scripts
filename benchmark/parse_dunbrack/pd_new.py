import sys,os,gzip,commands
from string import atoi,atof
import re,tarfile
from pyparsing import *
from fractions import Fraction
from numpy import *
import sys
from string import atoi



def parse(base):
	w=base.split("/")
	p="/".join(w[:-1])
	p1=atoi(base.split("_")[-1])
	#print p1
	tsv_file="%s/%s.tsv"%(p,w[-2])
	fname="%s.tar.gz"%(base)
	tsv=parse_tsv(tsv_file)
	targz2=parse_targz(fname)
	for targz in targz2:
		print base,"\t","\t".join(targz),"\t%d\t%d\t%.4f"%(tsv[1][tsv[0].index(p1)][0],tsv[1][tsv[0].index(p1)][1],tsv[1][tsv[0].index(p1)][2])
	
	

def parse_targz(fname):
	try:
		t=tarfile.open(fname,'r:gz')
		base=fname.split(".tar.gz")[0].split("/")[-1].replace("(","").replace(")","").replace(";","")
		#foname="%s.parsed"%(base)
		#fo=open(foname,'w')
		#print base
		res=[]
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
					res.append([pdb,ifaceid,d[0],d[1],d[2],d[3],d[4]])
				except IndexError:
					pass
		#fo.close()
	except IOError:
		res=[]
	return res

	



def parse_tsv(fname):
	f=open(fname,'r').read().split("\n")
	x=[]
	x.append([])
	x.append([])
	for l in f:
		d=re.findall(r'(\d+)\s+(\d+)\s+[(](\S+)[)]\s+\S+',l)
		if len(d):
			x[0].append(atoi(d[0][0]))
			x[1].append([atoi(d[0][1]),round(atoi(d[0][1])/atof(d[0][2])),atof(d[0][2])])
	return x


if __name__=="__main__":
	f=open("missing_input.txt",'r').read().split("\n")[:-1]
	for base in f:
		parse(base)
