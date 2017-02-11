'''
Created on Sep 25, 2015

@author: kbaskaran
'''

class suduko:
    '''
    classdocs
    '''
    print "done"

    def __init__(self):
        '''
        Constructor
        '''
        puzzle='809060100006470000703009006004150060650000031030027400400700302000034600007010804'
        print len(puzzle)
        if len(puzzle)!=81:
            print "Missing values"
            exit(0)
        else:
            x=[0,0,0,0,0,0,0,0,0]
            y=[x,x,x,x,x,x,x,x,x]
            z=[y,y,y,y,y,y,y,y,y]
            self.s=[z,z,z,z,z,z,z,z,z]
            self.s[0][0][0][0]=puzzle[0]
            self.s[1][0][0][1]=puzzle[1]
            self.s[2][0][0][2]=puzzle[2]
            self.s[3][0][1][0]=puzzle[3]
            self.s[4][0][1][1]=puzzle[4]
            self.s[5][0][1][2]=puzzle[5]
            self.s[6][0][2][0]=puzzle[6]
            self.s[7][0][2][1]=puzzle[7]
            self.s[8][0][2][2]=puzzle[8]
            self.s[0][1][0][3]=puzzle[9]
            self.s[1][1][0][4]=puzzle[10]
            self.s[2][1][0][5]=puzzle[11]
            self.s[3][1][1][3]=puzzle[12]
            self.s[4][1][1][4]=puzzle[13]
            self.s[5][1][1][5]=puzzle[14]
            self.s[6][1][2][3]=puzzle[15]
            self.s[7][1][2][4]=puzzle[16]
            self.s[8][1][2][5]=puzzle[17]
            self.s[0][2][0][6]=puzzle[18]
            self.s[1][2][0][7]=puzzle[19]
            self.s[2][2][0][8]=puzzle[20]
            self.s[3][2][1][6]=puzzle[21]
            self.s[4][2][1][7]=puzzle[22]
            self.s[5][2][1][8]=puzzle[23]
            self.s[6][2][2][6]=puzzle[24]
            self.s[7][2][2][7]=puzzle[25]
            self.s[8][2][2][8]=puzzle[26]
            self.s[0][3][3][0]=puzzle[27]
            self.s[1][3][3][1]=puzzle[28]
            self.s[2][3][3][2]=puzzle[29]
            self.s[3][3][4][0]=puzzle[30]
            self.s[4][3][4][1]=puzzle[31]
            self.s[5][3][4][2]=puzzle[32]
            self.s[6][3][5][0]=puzzle[33]
            self.s[7][3][5][1]=puzzle[34]
            self.s[8][3][5][2]=puzzle[35]
            self.s[0][4][3][3]=puzzle[36]
            self.s[1][4][3][4]=puzzle[37]
            self.s[2][4][3][5]=puzzle[38]
            self.s[3][4][4][3]=puzzle[39]
            self.s[4][4][4][4]=puzzle[40]
            self.s[5][4][4][5]=puzzle[41]
            self.s[6][4][5][3]=puzzle[42]
            self.s[7][4][5][4]=puzzle[43]
            self.s[8][4][5][5]=puzzle[44]
            self.s[0][5][3][6]=puzzle[45]
            self.s[1][5][3][7]=puzzle[46]
            self.s[2][5][3][8]=puzzle[47]
            self.s[3][5][4][6]=puzzle[48]
            self.s[4][5][4][7]=puzzle[49]
            self.s[5][5][4][8]=puzzle[50]
            self.s[6][5][5][6]=puzzle[51]
            self.s[7][5][5][7]=puzzle[52]
            self.s[8][5][5][8]=puzzle[53]
            self.s[0][6][6][0]=puzzle[54]
            self.s[1][6][6][1]=puzzle[55]
            self.s[2][6][6][2]=puzzle[56]
            self.s[3][6][7][0]=puzzle[57]
            self.s[4][6][7][1]=puzzle[58]
            self.s[5][6][7][2]=puzzle[59]
            self.s[6][6][8][0]=puzzle[60]
            self.s[7][6][8][1]=puzzle[61]
            self.s[8][6][8][2]=puzzle[62]
            self.s[0][7][6][3]=puzzle[63]
            self.s[1][7][6][4]=puzzle[64]
            self.s[2][7][6][5]=puzzle[65]
            self.s[3][7][7][3]=puzzle[66]
            self.s[4][7][7][4]=puzzle[67]
            self.s[5][7][7][5]=puzzle[68]
            self.s[6][7][8][3]=puzzle[69]
            self.s[7][7][8][4]=puzzle[70]
            self.s[8][7][8][4]=puzzle[71]
            self.s[0][8][6][6]=puzzle[72]
            self.s[1][8][6][7]=puzzle[73]
            self.s[2][8][6][8]=puzzle[74]
            self.s[3][8][7][6]=puzzle[75]
            self.s[4][8][7][7]=puzzle[76]
            self.s[5][8][7][8]=puzzle[77]
            self.s[6][8][8][6]=puzzle[78]
            self.s[7][8][8][7]=puzzle[79]
            self.s[8][8][8][8]=puzzle[80]
            for jj in self.s:
                for ii in jj:
                    for kk in ii:
                        print 
                        for ss in kk:
                            print ss,kk.index(ss),ii.index(kk),jj.index(ii),self.s.index(jj)
            print self.s
if __name__=="__main__":
    f=suduko()
                            