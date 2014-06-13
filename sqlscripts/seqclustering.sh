mysql -e "

DROP TABLE IF EXISTS SeqCluster;
CREATE TABLE SeqCluster(
uid INT NOT NULL AUTO_INCREMENT,
pdbCode varchar(4),
repChain varchar(4),
c100 int(11),
c95 int(11),
c90 int(11),
c80 int(11),
c70 int(11),
c60 int(11),
c50 int(11),
chainCluster_uid int(11),
PRIMARY KEY (uid)
);

load data local infile '~/tmp.tab' into table SeqClusters(pdbCode,repChain,c100,c95,c90,c80,c70,c60,c50,chainCluster_uid);

drop function if exists IsSameSegment;
DELIMITER $$
create function IsSameSegment(s1 INT,e1 INT, s2 INT, e2 INT,n INT) returns bool
BEGIN
declare res bool;
if (((s2>=(s1-n) and s2<=(s1+n)) or (s1>=(s2-n) and s1<=(s2+n))) and ((e2>=(e1-n) and e2<=(e1+n)) or (e1>=(e2-n) and e1<=(e2+n)))) then
set res=1;
else
set res=0;
end if;
return res;
end $$
DELIMITER ;


drop function if exists IsSameCrystalForm;
DELIMITER $$
create function IsSameCrystalForm(pdb1 varchar(255),pdb2 varchar(255),c double) returns bool
BEGIN
declare res bool;
declare s1,s2 varchar(255);
declare uid1,uid2 int(11);
declare a1,a2,b1,b2,c1,c2,alpha1,beta1,gamma1,alpha2,beta2,gamma2 double;
set uid1=(select uid from PdbInfo where pdbCode=pdb1);
set uid2=(select uid from PdbInfo where pdbCode=pdb2);
set s1=(select spaceGroup from PdbInfo where uid=uid1);
set a1=(select cellA from PdbInfo where uid=uid1);
set b1=(select cellB from PdbInfo where uid=uid1);
set c1=(select cellC from PdbInfo where uid=uid1);
set alpha1=(select cellAlpha from PdbInfo where uid=uid1);
set beta1=(select cellBeta from PdbInfo where uid=uid1);
set gamma1=(select cellGamma from PdbInfo where uid=uid1);
set s2=(select spaceGroup from PdbInfo where uid=uid2);
set a2=(select cellA from PdbInfo where uid=uid2);
set b2=(select cellB from PdbInfo where uid=uid2);
set c2=(select cellC from PdbInfo where uid=uid2);
set alpha2=(select cellAlpha from PdbInfo where uid=uid2);
set beta2=(select cellBeta from PdbInfo where uid=uid2);
set gamma2=(select cellGamma from PdbInfo where uid=uid2);
if ((s1=s2) and IsSameValue(a1,a2,c) and IsSameValue(b1,b2,c) and IsSameValue(c1,c2,c) and IsSameValue(alpha1,alpha2,c) and IsSameValue(beta1,beta2,c) and IsSameValue(gamma1,gamma2,c)) then
set res=1;
else
set res=0;
end if;
return res;
end $$
DELIMITER ;


drop function if exists IsSameValue;
DELIMITER $$
create function IsSameValue(x double,y double,t double) returns bool
BEGIN 
declare res bool;
declare dx,dy double;
set dx=x*(t/100.00);
set dy=y*(t/100.00);
if ((y<=(x+dx) and y>=(x-dx)) or (x<=(y+dy) and x>=(y-dy))) then
set res=1;
else
set res=0;
end if;
return res;
end $$
DELIMITER ;


create view HIVProtease as select s.*,c.pdbInfo_uid from SeqClusters as s inner join ChainCluster as c on c.uid=s.chainCluster_uid where s.c100=828 group by c.pdbCode having count(c.pdbCode)=1 ;



select v1.pdbCode,v2.pdbCode,IsSameCrystalForm(v1.pdbInfo_uid,v2.pdbInfo_uid,1) from HIVProtease as v1 inner join HIVProtease as v2 on v1.c100=v2.c100 group by v1.pdbCode,v2.pdbCode;


drop procedure if exists test;
DELIMITER $$
create procedure test()
BLOCK1
end; $$
DELIMITER ;


drop function if exists IsSameCrystalForm2;
DELIMITER $$
create function IsSameCrystalForm2(pdb1 varchar(255),pdb2 varchar(255),c double) returns bool
BEGIN
declare res bool;
declare s1,s2 varchar(255);
declare uid1,uid2 int(11);
declare a1,a2,b1,b2,c1,c2,alpha1,beta1,gamma1,alpha2,beta2,gamma2 double;
set uid1=(select uid from PdbInfo where pdbCode=pdb1);
set uid2=(select uid from PdbInfo where pdbCode=pdb2);
select spaceGroup,cellA,cellB,cellC,cellAlpha,cellBeta,cellGamma into s1,a1,b1,c1,alpha1,beta1,gamma1 from PdbInfo where uid=uid1;
select spaceGroup,cellA,cellB,cellC,cellAlpha,cellBeta,cellGamma into s2,a2,b2,c2,alpha2,beta2,gamma2 from PdbInfo where uid=uid2;
if ((s1=s2) and IsSameValue(a1,a2,c) and IsSameValue(b1,b2,c) and IsSameValue(c1,c2,c) and IsSameValue(alpha1,alpha2,c) and IsSameValue(beta1,beta2,c) and IsSameValue(gamma1,gamma2,c)) then
set res=1;
else
set res=0;
end if;
return res;
end $$
DELIMITER ;







