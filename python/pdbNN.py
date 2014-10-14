import sys
from string import atoi,atof
from math import sqrt



class pdbNearestNeighbour:
	
	def readDirexOutput(self,fname):
		self.fname=fname
		f=open(self.fname,'r').read().split("\n")[:-1]
		coord=[]
		for l in f:
			w=[i for i in l.split(" ") if i!=""]
			id=atoi(w[1])
			x=atof(w[6])
			y=atof(w[7])
			z=atof(w[8])
			coord.append([id,x,y,z])
		return coord
	def distanceMatrix(self,fname):
		self.fname=fname
		s=self.readDirexOutput(self.fname)
		n=len(s)
		dmatrix=[]
		for i in range(n):
			dmatrix.append([])
			for j in range(n):
				d=self.distance(s[i],s[j])
				dmatrix[-1].append([d,s[j][0]])
		return dmatrix
					
	def neibhour(self,dmat,n1):
		foname="%s_%d.dist"%(self.fname.split(".pdb")[0],n1)
		self.dmat=dmat
		self.n1=n1+1
		n=len(dmat)
		fo=open(foname,'w')
		for i in range(n):
			nn=sorted(dmat[i])[:self.n1]
			print "Nearest neighbour for atom %d is"%(nn[0][1])
			for j in range(1,len(nn)):
				fo.write("%d\t%d\t%f\t1.00\t1.00\n"%(nn[0][1],nn[j][1],nn[j][0]))
				print "%d\t%f"%(nn[j][1],nn[j][0])
		fo.close()
					
					
	def distance(self,a,b):
		self.a=a
		self.b=b
		dis=sqrt(((self.a[1]-self.b[1])**2)+((self.a[2]-self.b[2])**2)+((self.a[3]-self.b[3])**2))
		return dis
		


if __name__=="__main__":
	fname=sys.argv[1]
	n1=atoi(sys.argv[2])
	x=pdbNearestNeighbour()
	m=x.distanceMatrix(fname)
	x.neibhour(m,n1)
