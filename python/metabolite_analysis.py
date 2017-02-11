import csv
import sys
from string import atof

def relative_con(fname):
    m = []
    with open(fname,'rb') as csvfile:
        con = csv.reader(csvfile,delimiter=',')
        for row in con:
            m.append([atof(i) for i in row])
    for i in range(len(m)):
        f = open("dat%d.dat"%(i+1),'w')
        for j in range(len(m[i])):
            for k in range(len(m[i])):
                if k+1!=len(m[i]):
                    f.write("%.4f,"%(m[i][j]/m[i][k]))
                else:
                    f.write("%.4f"%(m[i][j]/m[i][k]))
            f.write("\n")
        f.close()

if __name__=="__main__":
	fname = sys.argv[1]
	relative_con(fname)
