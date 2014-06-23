import sys,os,commands
from numpy import mean
from string import atof
def get_data(db):
	cmd="mysql %s -N -B -e 'select pdbCode,interfaceId,area,gmScore,gm,crScore,cr,csScore,cs,final,pisa,pisaCall,pqs from EppicvsPisa where resolution<2.5 and rfreeValue<0.3 and h1>30 and h2>30 and cs!=\"nopred\" and cr!=\"nopred\" and pisaCall!=\"nopred\" and cs=cr order by area desc'"%(db)
	dat=commands.getoutput(cmd).split("\n")
	print "datapoints\tpercentage\tcall\txmin\txmax\txmean\tbmin\tbmax\tbmean"
	r=range(0,len(dat)/2,100)
	#for i in range(100,len(dat)/2,100):
		#dat2=dat[:i]+dat[-i:]
		#xt=get_values(dat[-i:])
		#bo=get_values(dat[:i])
	for i in range(1,len(r)):
		dat2=dat[r[i-1]:r[i]]+dat[-r[i]:(len(dat)-r[i-1])]
		bo=get_values(dat[r[i-1]:r[i]])
		xt=get_values(dat[-r[i]:(len(dat)-r[i-1])])
		out=get_comparison(set(dat2))
		print "%d\t%.2f\txtal-xtal\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f"%(r[i]*2,out[0],xt[0],xt[1],xt[2],bo[0],bo[1],bo[2])
		print "%d\t%.2f\tbio-bio\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f"%(r[i]*2,out[1],xt[0],xt[1],xt[2],bo[0],bo[1],bo[2])
		print "%d\t%.2f\txtal-bio\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f"%(r[i]*2,out[2],xt[0],xt[1],xt[2],bo[0],bo[1],bo[2])
		print "%d\t%.2f\tbio-xtal\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f"%(r[i]*2,out[3],xt[0],xt[1],xt[2],bo[0],bo[1],bo[2])
		print "%d\t%.2f\tsame\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f"%(r[i]*2,out[4],xt[0],xt[1],xt[2],bo[0],bo[1],bo[2])
		print "%d\t%.2f\tdifferent\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f"%(r[i]*2,out[5],xt[0],xt[1],xt[2],bo[0],bo[1],bo[2])

def get_values(dat):
	v=[atof(w.split("\t")[-6]) for w in dat]
	return [min(v),max(v),mean(v)]

def get_comparison(dat):
	n=len(dat)
	xx=0.0
	xb=0.0
	bx=0.0
	bb=0.0
	for i in dat:
		w=i.split("\t")
		a=w[-2]
		e=w[-5]
		if e=='xtal' and a=='xtal':
			xx+=1
		elif e=='xtal' and a== 'bio':
			xb+=1
		elif e=='bio' and a=='xtal':
			bx+=1
		elif e=='bio' and a=='bio':
			bb+=1
		else:
			print 'error'
	return [(xx/n)*100,(bb/n)*100,(xb/n)*100,(bx/n)*100,((xx+bb)/n)*100,((xb+bx)/n)*100]

if __name__=="__main__":
	get_data("eppic_2_1_0_2014_05")

