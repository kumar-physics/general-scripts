from pyparsing import *
from fractions import Fraction
from numpy import *
import sys
from string import atoi



class XtalOperator:
	def parser(self,op):
		plus = Literal("+")
		minus = Literal("-")
		sign = plus | minus
		x = CaselessLiteral("X")
		y = CaselessLiteral("Y")
		z = CaselessLiteral("Z")
		var = x | y | z
		integer =  (Optional(sign)+Word( nums )).setParseAction(lambda s,l,t: [ int(t[0]) if len(t)==1 else atoi("%s%s"%(t[0],t[1])) ])
		trans=(integer+Optional("/")+Optional(integer)).setParseAction(lambda s,l,t: Fraction(t[0],t[2] if len(t)==3 else 1))
		variable=(Optional(sign)+var+Optional(sign+var)).setParseAction(self.vartermAction)
		opr=(variable+Optional(trans) ^ Optional(trans)+variable).setParseAction(self.oprtermAction)
		return opr.parseString(op)[0]

	def vartermAction(self,s,l,t):
		order=['X','Y','Z']
		vector=array([0,0,0])
		if len(t)==1:
			vector[order.index(t[0])]=1
		elif len(t)==2 and t[0]=="-":
			vector[order.index(t[1])]=-1
		elif len(t)==2 and t[0]=="+":
			vector[order.index(t[1])]=1
		elif len(t)==3 and t[1]=="-":
			vector[order.index(t[0])]=1
			vector[order.index(t[2])]=-1
		elif len(t)==3 and t[1]=="+":
			vector[order.index(t[0])]=1
			vector[order.index(t[2])]=1
		elif len(t)==4 and t[0]=="+" and t[2]=="+":
			vector[order.index(t[1])]=1
			vector[order.index(t[3])]=1
		elif len(t)==4 and t[0]=="+" and t[2]=="-":
			vector[order.index(t[1])]=1
			vector[order.index(t[3])]=-1
		elif len(t)==4 and t[0]=="-" and t[2]=="+":
			vector[order.index(t[1])]=-1
			vector[order.index(t[3])]=1
		elif len(t)==4 and t[0]=="-" and t[2]=="-":
			vector[order.index(t[1])]=-1
			vector[order.index(t[3])]=-1
		else:
			raise TypeError("Expects operator of the form -x+y")
		return vector

	def oprtermAction(self,s,l,t):
		if type(t[0]) is Fraction:
			s=append(t[1],t[0])
		elif len(t)==2:
			s=append(t[0],t[1])
		else:
			s=append(t[0],Fraction(0,1))
		return s


	def op2matrix(self,op):
		m=[]
		for term in op.split(","):
			m.append(self.parser(term))
		m.append([0,0,0,Fraction(1,1)])
		return array(m)

	def get_third(self,op1,op2):
		'''
		This is to find the operator which takes B to C where op1 takes A to B and op2 takes A to C
		'''
		m1=self.op2matrix(op1)
		m2=self.op2matrix(op2)
		m1inv=self.op2matrix(self.inverse(op1))
		m=dot(m1inv,m2)
		return self.matrix2op(m)
	

	def inverse(self,op):
		m=self.op2matrix(op)
		minv=linalg.inv(m)
		return self.matrix2op(minv)
	def productof(self,op1,op2):
		m1=self.op2matrix(op1)
		m2=self.op2matrix(op2)
		m=dot(m1,m2)
		return self.matrix2op(m)

	def parse(self,op):
		return self.matrix2op(self.op2matrix(op))

	def matrix2op(self,m):
		order=["X","Y","Z"]
		op=[]
		for r in m:
			o=[]
			v=list(r)
			for i in range(len(v)):
				if v[i]!=0:
					if i<3:
						if v[i]>0: 
							if len(o)==0:
								o.append(order[i])
							else:
								o.append("+%s"%(order[i]))
						else:
							o.append("-%s"%(order[i]))
					else:
						if v[i]>0:
							o.append("+%s"%(Fraction(v[i]).limit_denominator(10)))
						else:
							o.append("%s"%(Fraction(v[i]).limit_denominator(10)))
			op.append("".join(o))
		return ",".join(op[:-1])


