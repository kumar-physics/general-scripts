#Parser for crystal operators

from pyparsing import *
from fractions import Fraction
import numpy as np
from numpy import *
from numpy.linalg import inv
import unittest
import sys,os

class Operation(object):
    """Defines a crystallographic operation, such as a rotation or screw axis.

    Operations can be easily constructed from a string description:

        op = Operation("X, Y+1/2, Z")

    The operation can be applied to a 3D point (in fractional coordinates)
    using the apply() or by simply calling it like a function:

        p1 = array([.1,.2,.3]) #numpy array
        p2 = op(p1)
        p2 = op.apply(p1)

    The Operation is represented internally as a 4x4 rotation matrix (m), which
    is pre-multiplied with a point (x,y,z,1).

    The inverse operation can be constructed using the ~ sign (or the inverse() function):

        (~op)(p2) == p1
        op.inverse().apply(p2) == p1

    Operations can be composed with * or the compose() function:

        op12 = op1.compose(op2)
        op12 = op1 * op2

    """
    def __init__(self,*args):
        """Create an Operation from the specified arguments:

        Operation()             Construct the identity operation
        Operation(string)       Parse from the string, e.g. "(X,Y+1/2,Z)"
        Operation(4x4array)     Create based on a 4x4 rotation matrix

        """

        if len(args) == 0:
            m = eye(4)
        elif len(args) == 1:
            if type(args[0]) is str:
                # parse from string
                parser = self.__class__.getParser()
                m = parser.parseString(args[0])[0]
            else:
                m = array(args[0]) #copy
                if m.shape != (4,4):
                    raise ValueError("Expected 4x4 rotation matrix")
                #if any( abs( dot(m[:3,:3].T,m[:3,:3]) - eye(3) ) > 1e-9 ):
                #    raise ValueError("Non-orthogonal matrix")
                if any( abs(m[3,] - array([[0,0,0,1]])) > 1e-9 ):
                    raise ValueError("Not a 3D rotation")
        else:
            raise TypeError("this constructor expects 0 or 1 arguments")

        self.m = m

    def __str__(self):
        # Permute "XYZ" based on 
        exprs = []
        for row in self.m[:3]:
            # get non-zero coeficients
            rowstr = ""
            for coef,var in zip(row,["X","Y","Z",""]):
                rational = Fraction(coef).limit_denominator()
                if rational != 0:
                    if rational < 0:
                        rowstr += "-"
                    else:
                        rowstr += "+"
                    if abs(rational) != 1:
                        rowstr += str(abs(rational))
                        if var != "":
                            rowstr += "*"
                    elif var == "":
                        rowstr += str(abs(rational))
                    rowstr += var

            # special cases
            if len(rowstr) == 0:
                #shouldn't happen in 3D
                exprs.append("0")
            else:
                if rowstr[0] == '+':
                    exprs.append(rowstr[1:])
                else:
                    exprs.append(rowstr)

        return ",".join(exprs)

    def __repr__(self):
        return "Operation( %s )" % (repr(self.m))

    def apply(self,pt):
        """Apply the operation to a point (x,y,z) in fractional coordinates.

        op.apply(point) -> point

        The point may be a 3 or 4 element tuple, list, or numpy 1D array.
        The function returns a 3 element numpy array.

        Operations can also be applied using function-like sytax, e.g. self(x,y,z)

        Examples:
        op = Operation("z,x,y")
        op.apply(array([.1,.2,.3]))
        op( [.1,.2,.3] )
        """
        oldpt = asarray(pt)
        oldpt = oldpt.flatten()
        if oldpt.size == 3:
            oldpt = concatenate((oldpt,(1,)))
        if oldpt.size != 4:
            raise TypeError("Expected 3 or 4 elements")
        newpt = dot(self.m,oldpt)
        return newpt[:3]

    def __call__(self,pt):
        """Apply the operation to a point in fractional coordinates.

        See self.apply(point) for details.

        Returns a 3 element numpy array
        """
        return self.apply(pt)


    def inverse(self):
        """return the inverse operation.
        If a = op(b), then b == op.inverse()(a)

        Equivalent to (~self).
        """
        return Operation( inv(self.m) )

    def __invert__(self):
        """return the inverse operation. If a = op(b), then b == (~op)(a).

        Equivalent to self.inverse()
        """
        return self.inverse()

    def compose(self,other):
        """Compose this operation with another.

        This is equivalent to the '*' operator: (self*other)

        For all points,

            (self*other)(pt) == self.compose(other)(pt)
                == self( other(pt) ) == dot( dot(self.m,other.m),pt )

        Note that this is consistent with the normal right-presidence of
        functions and matrices.
        """
        return Operation( dot(self.m,other.m) )

    def __mul__(self,other):
        if not isinstance(other, Operation):
            raise TypeError("unsupported operand type(s) for *: 'Operation' and '%s'"%type(other))
        return self.compose(other)

    def rdivide(self,other):
        """Returns the operator which maps from the image of self to the image
        of other. Named by analogy to matlab's B/A operator, which solves Ax=B.

        Equivalent to (other * ~self)
        """
        return other * (~self)

    def ldivide(self,other):
        """Returns the operator which applies other and then undos self. Named
        by analogy to matlab's A\B operator, which solves xA=B.

        Equivalent to (~self * other)
        """
        return (~self) * other


    def equivalent(self,other,tol=1e-9):
        """Return true if the two operators are equivalent, e.g. they are
        either the same operator (within tolerance) or one is the inverse of the other.
        """
        return all(self.m-other.m <= tol) or all(self.m - (~other).m <= tol)

    def __eq__(self,other):
        "Check if two operators are exactly the same"
        return all(self.m == other.m)

    def __hash__(self):
        return hash(self.m)

    _parser = None
    @classmethod
    def getParser(cls):
        """
        Returns a pyparsing ParseResult which can parse the following grammar:

        operation   :: '('? expr ',' expr ',' expr ')'?
        expr        :: term | term binop expr
        term        :: varterm | rational
        varterm     :: rational '*'? var | '-' var | '+'? var
        var         :: 'X' | 'Y' | 'Z'
        binop       :: '+' | '-'

        The instance returned is a singleton.

        Parsing a valid string yields a tuple with the rotation matrix and
        shift vector for the specified operation.
        """

        if not cls._parser:
            #Define parse actions to convert tags to structured data
            def vartermAction(s,l,t):
                "convert 'X' or '-Y' into an array of coefficients for (x,y,z,b)"
                # extract variable and coefficient
                #print "varterm %s"%t
                var = t[-1]
                coef = 1
                if len(t) == 2:
                    if t[0] == '-':
                        coef = -1
                    elif type(t[0]) is Fraction:
                        coef = t[0]

                varpos = "xyz".index(var.lower())

                row = zeros(4)
                row[varpos] = coef
                return row

            def termAction(s,l,t):
                "convert terms to an array of coefficient for (x,y,z,b)"
                if type(t[0]) is Fraction:
                    return array([0,0,0,t[0]])
                else: #already an array
                    return t[0]

            def exprAction(string,location,tags):
                "sum all terms to give the full (x,y,z,b) coefficients"
                if len(tags) == 1:
                    return tags[0]
                else: # term binop expr
                    a = tags[0]
                    op = tags[1]
                    b = tags[2]
                    if op == '-':
                        b = -b
                    return a+b

            def operationAction(string,location,tags):
                "get the 4x4 matrix representing an operation"
                return [array( tags.asList() + [array([0,0,0,1])] )]

            # Define the grammar
            integer = Regex( "[+-]?[0-9]+" ).setParseAction(lambda s,l,t: [ int(t[0]) ])
            rational = (integer + '/' + integer ^ integer).setParseAction(
                    lambda s,l,t: Fraction(t[0],t[2] if len(t)==3 else 1) )

            binop = oneOf('+ -')

            var = oneOf( "x y z", caseless=True)
            varterm = (rational + Optional('*').suppress() + var ) ^ (Optional(binop)+var)
            varterm.setParseAction(vartermAction)

            term = (varterm ^ rational).setParseAction(termAction)


            expr = Forward()
            expr << ((term + binop + expr) ^ term )
            expr.setParseAction(exprAction)

            operation = Optional('(').suppress() + \
                    expr + Suppress(',') + expr + Suppress(',') + expr + \
                    Optional(')').suppress()
            operation.setParseAction(operationAction)

            cls._parser = operation
        return cls._parser

class OpTests(unittest.TestCase):

    def arrayEquals(self,a,b,msg=None,tol=1e-9):
        self.assertTrue( all( a-b < tol ) ,msg)

    def testSome(self):
        tests = [ "x,y,z",
                "y,z,x",
                "-x,y+1/2,1/2-z",
                "Z-1/4,-4+X,-1/6-y",
                "Y-X,Y, 1/2-Z",
                "+x,-y,+z",
                ]
        #print "Input\tOperation\tInverse"
        for opstr in tests:
            op = Operation(opstr)
            #print "%s\t%s\t%s"%(opstr, op ,~ op)

    def testCompose(self):
        op1 = Operation( "z,x,y" )
        op2 = Operation( "-x,y+1/2,1/2-z")
        op21 = op2 * op1

        pt1 = [.1,.2,.3]
        self.arrayEquals( op1(pt1) , [.3,.1,.2] )
        self.arrayEquals( op2(pt1) , [-.1,.7,.2] )
        self.arrayEquals( op2( op1( pt1)) , op21(pt1) )
        self.arrayEquals( op21(pt1) , [-.3, .6, .3] )

    def testEquivalence(self):
        tests = [ "y,z,x", #non 2-fold rotations
                "-x,y+1/2,1/2-z",
                "Z-1/4,-4+X,-1/6-y",
                ]
        for opstr in tests:
            op = Operation(opstr)
            iop = ~op
            self.assertTrue( op.equivalent(iop) )
            self.assertFalse( op == iop )

    def test2ej5(self):
        eppic = Operation("(z-1/2, -x-1/2, -y)")
        xuLeft = Operation("(-1/2-Y,-Z,1/2+X)")
        xuRight = Operation("(X,Y,Z)")
        protCidLeft = Operation("(-Y,1/2+Z,-1/2-X)")
        protCidRight = Operation("(1/2+X,1/2-Y,-Z)")

        xu = xuLeft.ldivide(xuRight)
        protCid = protCidLeft.ldivide(protCidRight)

        #N-term of protein
        cell = 117.008
        b = array([-47.855, 41.533, 10.318])/cell
        # Eppic chain C
        ec = array([-48.186, -10.649, -41.533])/cell
        # ProtCid chain A
        pa = array([-41.533, 68.824,-10.651])/cell
        # ProtCid chain B
        pb = array([10.651, 16.973,-10.318])/cell

        self.arrayEquals(eppic(b), ec,"Eppic operator wrong",1e-4)
        self.arrayEquals(protCidLeft(b), pa,"ProtCid left operator wrong",1e-4)
        self.arrayEquals(protCidRight(b), pb,"ProtCid right operator wrong",1e-4)
        self.arrayEquals(protCid(b), ec, "ProtCid ldivide wrong",1e-4)
        self.arrayEquals(protCidLeft.rdivide(protCidRight)(pa),pb, "ProtCid rdivide wrong",1e-4)


        self.assertTrue(eppic.equivalent(xu),"Eppic != Xu")
        self.assertTrue(eppic.equivalent(protCid),"Eppic != ProtCid")
        self.assertTrue(xu.equivalent(protCid),"Xu != ProtCid")



    # Run on all 719 operators from spacegroups.txt
    # This mostly tests parsing, without actually checking for accuracy
    def _testFile(self,filename="spacegroups.txt"):
        self.assertTrue( os.path.isfile(filename))
        with open(filename,'r') as file:
            #print "Input\tOperation\tInverse"
            for line in file:
                opstr = line.strip()
                op = Operation(opstr)
                #print "%s\t%s\t%s" %(opstr,op,~op)

if __name__ == "__main__":
    unittest.main()


