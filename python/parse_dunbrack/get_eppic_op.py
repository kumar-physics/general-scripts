import os,sys
from Xtal_Op import *
from string import atoi,atof




def get_eppic_op(fname):
	f=open(fname).read().split("\n")[:-1]
	x=XtalOperator()
	for l in f:
		w=l.split("\t")
		op1=x.parse(w[4])
		op2=x.parse(w[6])
		op=x.get_third(op1,op2)
		opinv=x.inverse(op)
		out="%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(w[0],w[1],w[2],w[3],w[5],w[4],w[6],w[7],w[8],w[9],w[10],op1,op2,op,opinv)
		print out
if __name__=="__main__":
	get_eppic_op("missing_out.dat")
