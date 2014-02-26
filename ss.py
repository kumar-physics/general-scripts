from string import atoi,atof
import sys,os,commands


def get_interface(pdb,interfaceid):
	cmd="curl --compressed http://eppic-web.org/ewui/ewui/fileDownload?type=interface\&id=%s\&interface=%s > %s-%s.%s.pdb"%(pdb,interfaceid,pdb,pdb,interfaceid)
	os.system(cmd)
	chains=commands.getoutput("cat %s-%s.%s.pdb | grep SEQRES | awk '{print $3}' | sort | uniq"%(pdb,pdb,interfaceid)).split("\n")
	return chains

def get_pdbinterfaces(pdb1,interfaceid1,pdb2,interfaceid2):
	chain1=get_interface(pdb1,interfaceid1)
	chain2=get_interface(pdb2,interfaceid2)
	fname="%s_%s-%s_%s.pml"%(pdb1,interfaceid1,pdb2,interfaceid2)
	f=open(fname,'w')
	f.write("reinitialize\n")
	f.write("cd /home/baskaran_k/asym\n")
	f.write("load %s-%s.%s.pdb\n"%(pdb1,pdb1,interfaceid1))
	f.write("load %s-%s.%s.pdb\n"%(pdb2,pdb2,interfaceid2))
	f.write("show cartoon\n")
	f.write("hide lines\n")
	f.write("align %s-%s.%s//%s//, %s-%s.%s//%s//\n"%(pdb1,pdb1,interfaceid1,chain1[0],pdb2,pdb2,interfaceid2,chain2[0]))
	f.write("center\n")
	f.write("color cyan, %s-%s.%s//%s//\n"%(pdb1,pdb1,interfaceid1,chain1[0]))
	f.write("color yellow, %s-%s.%s//%s//\n"%(pdb1,pdb1,interfaceid1,chain1[1]))
	f.write("color green, %s-%s.%s//%s//\n"%(pdb2,pdb2,interfaceid2,chain2[0]))
	f.write("color red, %s-%s.%s//%s//\n"%(pdb2,pdb2,interfaceid2,chain2[1]))
	f.close()
	os.system("pymol %s"%(fname))
	


if __name__=="__main__":
	pdb1=sys.argv[1]
	interfaceid1=sys.argv[2]
	pdb2=sys.argv[3]
	interfaceid2=sys.argv[4]
	get_pdbinterfaces(pdb1,interfaceid1,pdb2,interfaceid2)
