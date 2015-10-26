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
        dat=re.findall(r'\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+\S+\s+\S*\n',f)
        #datdict={"%s-%s-%s-%s"%(i[0],i[1],i[2],i[3]):array([atof(i[4]),atof(i[5]),atof(i[6])]) for i in dat}
        #revdict={"%s/%s/%s"%(i[4],i[5],i[6]):"%s-%s-%s-%s"%(i[0],i[1],i[2],i[3]) for i in dat}
        #dlist=["%s-%s-%s-%s"%(i[0],i[1],i[2],i[3]) for i in dat]
        coords=[[atof(i[4]),atof(i[5]),atof(i[6])] for i in dat]
        return coords
        
    def readnn(self,fname):
        f=open(fname,'r').read()
        dat=re.findall(r'(\S+)\s*(\S+)\s+\S+\s+\S+\s+\S+\n',f)
        a=[]
        n=[]
        for i in dat:
            a.append(atoi(i[0]))
            n.append(i[1])
        aa=[[] for i in range(max(a))]
        for i in range(len(a)):
            #print a[i]-1,n[i]
            aa[a[i]-1].append(n[i])
        return aa
    def readMapping(self,fname):
        f=open(fname,'r').read()
        dat=re.findall(r'(\d+)\s+(\d+)\n',f)
        r1=[i[0] for i in dat]
        a1=[i[1] for i in dat]
        return [r1,a1]
    def __init__(self):
        '''
        Constructor
        '''
    def main(self):
        self.allatoms=self.readPDB('/kbaskaran/density/allatom.pdb')
        self.redatoms=self.readPDB('/kbaskaran/density/reduced_start.pdb')
        self.nn=self.readnn('/kbaskaran/density/allatom-nn.dat')
        self.map=self.readMapping('/kbaskaran/density/reduced-map-allatom.pdb')
        for i in range(len(self.allatoms)):
            if self.allatoms[i] not in self.redatoms:
                allnn=self.nn[i]
                rednn=[ x for x in allnn if x in self.map[1]]
                redco=[self.redatoms[atoi(self.map[0][self.map[1].index(y)])-1] for y in rednn]
                #print redco,len(redco)
                print i,self.allatoms[i],allnn,rednn,self.findmean(redco)
            
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
            
    
    def check(self,p1,p2,p3,p4,p5):
        print p1,p2,p3
        [d1,d2]=self.readPDB('/kbaskaran/density/allatom.pdb')
        tri=array([d1[d2[p1-1]],d1[d2[p2-1]],d1[d2[p3-1]],d1[d2[p4-1]],d1[d2[p5-1]]])
        x=Delaunay(tri)
        p=x.points[x.vertices]
        print tri
        print p
        plot(tri)
    
if __name__=="__main__":
    p=Interpolate3D()
    #[d1,d2]=p.readPDB('/kbaskaran/density/reduced_start.pdb')
    p.main()
    #print d1[d2[0]]