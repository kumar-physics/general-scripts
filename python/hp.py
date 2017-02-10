import sys
from math import sqrt
from string import atoi
def hp(n):
    for a in range(1,n):
        for b in range(1,a):
            p=sqrt((a*a)+(b*b))
            #if a<b:
            h=(a/2.0)+(7.0*b/8.0)
            #else:
            #    h=(b/2.0)+(7.0*a/8.0)
            print a,b,p,h,p-h

if __name__=="__main__":
    n=atoi(sys.argv[1])
    hp(n)
