'''
Created on Oct 26, 2015

@author: kbaskaran
'''
import re
from string import atoi,atof
from scipy.spatial import  Delaunay
from numpy import array
from pylab import *
class Interpolate3D:
    '''
    classdocs
    '''
    
    def readPDB(self,fname):
        f=open(fname,'r').read()
        dat=re.findall(r'\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\S+\s*\n',f)
        #datdict={"%s-%s-%s-%s"%(i[0],i[1],i[2],i[3]):array([atof(i[4]),atof(i[5]),atof(i[6])]) for i in dat}
        #revdict={"%s/%s/%s"%(i[4],i[5],i[6]):"%s-%s-%s-%s"%(i[0],i[1],i[2],i[3]) for i in dat}
        dlist=["%s-%s-%s-%s"%(i[0],i[1],i[2],i[3]) for i in dat]
        coords=[[atof(i[4]),atof(i[5]),atof(i[6])] for i in dat]
        dens=[i[7] for i in dat]
        return [coords,dlist,dens]
        
    def readnn(self,fname):
        f=open(fname,'r').read()
        dat=re.findall(r'(\S+)\s*(\S+)\s+\S+\s+\S+\s+\S+\n',f)
        a=[]
        n=[]
        a2=[]
        for i in dat:
            a.append(i[0])
            n.append(i[1])
            a2.append(atoi(i[0]))
        aa=[[] for i in range(max(a2))]
        for i in range(len(a)):
            #print a[i]-1,n[i]
            aa[atoi(a[i])-1].append(n[i])
            aa[atoi(n[i])-1].append(a[i])
        return aa
    def readMapping(self,fname):
        f=open(fname,'r').read()
        dat=re.findall(r'(\d+)\s+(\d+)\n',f)
        red=[i[0] for i in dat]
        alla=[i[1] for i in dat]
        return [red,alla]
    def __init__(self,allatm,redstart,refined,allatmnn,mapfile):
        self.allatoms=self.readPDB(allatm)
        self.redatoms=self.readPDB(redstart)
        self.refined=self.readPDB(refined)
        self.nn=self.readnn(allatmnn)
        self.map=self.readMapping(mapfile)
        '''
        Constructor
        '''
    def main(self):
        #self.allatoms=self.readPDB('/kbaskaran/density/allatom.pdb')
        #self.redatoms=self.readPDB('/kbaskaran/density/reduced_start.pdb')
        #self.refined=self.readPDB('/kbaskaran/density/reduced_refined.pdb')
        #self.nn=self.readnn('/kbaskaran/density/allatom-nn.dat')
        #self.map=self.readMapping('/kbaskaran/density/reduced-map-allatom.pdb')
        for i in range(len(self.allatoms[0])):
            if self.allatoms[0][i] not in self.redatoms[0]:
                allnn=self.nn[i]
                rednn=[ x for x in allnn if x in self.map[1]]
                redco=[self.refined[0][atoi(self.map[0][self.map[1].index(y)])-1] for y in rednn]
                #print redco,len(redco)
                #print i+1,self.allatoms[i],allnn,rednn,self.findmean(redco)
                #print i+1,self.allatoms[0][i],self.findmean(redco),array(self.allatoms[0][i])-array(self.findmean(redco)),len(rednn)
                try:
                    predco=self.findmean(redco)
                    #print "ATOM\t%s\t%s\t%s"%("\t".join(self.allatoms[1][i].split("-")),self.allatoms[1][i].split("-")[0],"\t".join(["%f"%(t) for t in self.findmean(redco)]))
                    print i+1,"\t".join(["%f"%(t) for t in predco]),self.allatoms[2][i]
                except ZeroDivisionError:
                    print i+1,"No nn",self.allatoms[2][i]
            else:
                #print i,self.map[1].index("%d"%(i+1))
                #print i,atoi(self.map[0][self.map[1].index(i+1)])-1
                #print "ATOM\t%s\t%s\t%s"%("\t".join(self.allatoms[1][i].split("-")),self.allatoms[1][i].split("-")[0],"\t".join(["%f"%(t) for t in self.refined[0][atoi(self.map[0][self.map[1].index("%d"%(i+1))])-1]]))
                print i+1,"\t".join(["%f"%(t) for t in self.refined[0][atoi(self.map[0][self.map[1].index("%d"%(i+1))])-1]]),self.allatoms[2][i]
        #for i in self.map:
         #   print i,self.allatoms[atoi(i[1])-1],self.redatoms[atoi(i[0])-1]
        #print self.nn[0],self.nn[1],self.nn[2]
        #for i,j in self.allatoms[1].iteritems():
         #   print i,j,self.allatoms[2].index(j),
          #  nnall=self.nn[self.allatoms[2].index(j)-1]
            
        
    def findmean(self,npoints):
        n=len(npoints)
        x=0.0
        y=0.0
        z=0.0
        for i in range(n):
            x+=npoints[i][0]
            y+=npoints[i][1]
            z+=npoints[i][2]
        return [x/n,y/n,z/n]
            
    
  
if __name__=="__main__":
    allatm=sys.argv[1]
    redstart=sys.argv[2]
    refined=sys.argv[3]
    allatmnn=sys.argv[4]
    mapfile=sys.argv[5]
    p=Interpolate3D(allatm,redstart,refined,allatmnn,mapfile)
    #[d1,d2]=p.readPDB('/kbaskaran/density/reduced_start.pdb')
    p.main()
    #print d1[d2[0]]