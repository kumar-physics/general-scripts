import random
import sys
from string import atoi
def powerball(n):
	p1 = random.randint(1,35)
	p2 = random.randint(36,52)
	p3 = random.randint(53,60)
	p4 = random.randint(61,65)
	p5 = random.randint(66,69)
	p = random.randint(1,26)
	x = ([p1,p2,p3,p4,p5],10)	
	#print p1,p2,p3,p4,p5,p
	p1 = random.randint(36,69)
	p2 = random.randint(1,16)
	p3 = random.randint(17,25)
	p4 = random.randint(25,30)
	p5 = random.randint(31,35)
	p = random.randint(1,26)
	y = ([p1,p2,p3,p4,p5],10)
	#print p1,p2,p3,p4,p5,p
	return [x,y]

def compare(x1,x2):
	n=0
	for i in x1[0]:
		if i in x2[0]: n+=1
	if x1[1] == x2[1]:
		n1=1
	else:
		n1=0
	return [n,n1]
def money(t1):
	if t1[1] == 1 :
		if t1[0] == 1:
			x = 4
		elif t1[0] == 2:
			x= 7
		elif t1[0] == 3:
			x = 100
		elif t1[0] == 4:
			x = 50000
		elif t1[0] == 5:
			x = 999999999999
		else:
			x = 4
	else:
		if t1[0] == 1:
			x = 0
		elif t1[0] == 1:
			x = 4
		elif t1[0] == 2:
			x = 0
		elif t1[0] == 3:
			x = 7
		elif t1[0] == 4:
			x = 100
		elif t1[0] == 5:
			x = 1000000
		else:
			x = 0
	
	return x
if __name__=="__main__":
	n = atoi(sys.argv[1])
	d = ([9,43,57,60,64],10)
	for i in range(n):
		t = powerball(2)
		t1 = compare(t[0],d)
		t2 = compare(t[1],d)
		if t1[0] or t1[1] or t2[0] or t2[1]:
			print money(t1)+money(t2),d,t[0],t[1],t1,t2
			
