


DROP FUNCTION IF EXISTS get_result;
DELIMITER $$
CREATE FUNCTION get_result(interfaceid INT,met VARCHAR(255)) RETURNS VARCHAR(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT callName FROM InterfaceScore WHERE interfaceItem_uid=interfaceid and method = met);
RETURN res;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS get_result2;
DELIMITER $$
CREATE FUNCTION get_result2(interfaceid INT,met VARCHAR(255)) RETURNS VARCHAR(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT callName FROM InterfaceClusterScore WHERE interfaceCluster_uid=interfaceid and method = met group by callName);
RETURN res;
END $$
DELIMITER ;



DROP FUNCTION IF EXISTS get_score;
DELIMITER $$
CREATE FUNCTION get_score(interfaceid INT,met VARCHAR(255)) RETURNS DOUBLE
BEGIN
DECLARE res DOUBLE;
SET res=(SELECT score FROM InterfaceScore WHERE interfaceItem_uid=interfaceid and method = met);
RETURN res;
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS get_score2;
DELIMITER $$
CREATE FUNCTION get_score2(interfaceid INT,met VARCHAR(255)) RETURNS DOUBLE
BEGIN
DECLARE res DOUBLE;
SET res=(SELECT score FROM InterfaceClusterScore WHERE interfaceCluster_uid=interfaceid and method = met);
RETURN res;
END $$
DELIMITER ;



DROP FUNCTION IF EXISTS get_side_score;
DELIMITER $$
CREATE FUNCTION get_side_score(interfaceid INT,met VARCHAR(255),side INT) RETURNS DOUBLE
BEGIN
DECLARE res DOUBLE;
if (side=1) then
SET res=(SELECT score1 FROM InterfaceScore WHERE interfaceItem_uid=interfaceid and method = met);
else
SET res=(SELECT score2 FROM InterfaceScore WHERE interfaceItem_uid=interfaceid and method = met);
end if;
RETURN res;
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS get_homologs;
DELIMITER $$
CREATE FUNCTION get_homologs(pdb varchar(4),chain VARCHAR(255)) RETURNS INT(12)
BEGIN
DECLARE x INT(12);
SET x=(SELECT numHomologs 
FROM ChainCluster 
WHERE pdbCode=pdb 
AND (repChain LIKE BINARY CONCAT("%",chain,"%") or memberChains LIKE BINARY CONCAT("%",chain,"%")) );
RETURN x;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS get_repchain;
DELIMITER $$
CREATE FUNCTION get_repchain(pdb varchar(4),chain VARCHAR(255)) RETURNS varchar(255)
BEGIN
DECLARE x varchar(255);
SET x=(SELECT repChain 
FROM ChainCluster 
WHERE pdbCode=pdb 
AND (repChain LIKE BINARY CONCAT("%",chain,"%") or memberChains LIKE BINARY CONCAT("%",chain,"%")) );
RETURN x;
END$$
DELIMITER ;



drop function if exists get_uniprot_id;
DELIMITER $$
create function get_uniprot_id(pdb varchar(4),chain varchar(255)) returns varchar(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT refUniProtId FROM ChainCluster 
WHERE pdbCode=pdb 
AND (repChain LIKE BINARY CONCAT("%",chain,"%") or memberChains LIKE BINARY CONCAT("%",chain,"%")) );
RETURN res;
END $$
DELIMITER ;


drop function if exists get_uniprot_id_cutoff;
DELIMITER $$
create function get_uniprot_id_cutoff(pdb varchar(4),chain varchar(255)) returns varchar(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT seqIdCutoff FROM ChainCluster 
WHERE pdbCode=pdb 
AND (repChain LIKE BINARY CONCAT("%",chain,"%") or memberChains LIKE BINARY CONCAT("%",chain,"%")) );
RETURN res;
END $$
DELIMITER ;




drop function if exists get_uniprot_start;
DELIMITER $$
create function get_uniprot_start(pdb varchar(4),chain varchar(255)) returns varchar(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT refUniProtStart FROM  ChainCluster 
WHERE pdbCode=pdb 
AND (repChain LIKE BINARY CONCAT("%",chain,"%") or memberChains LIKE BINARY CONCAT("%",chain,"%")) );
RETURN res;
END $$
DELIMITER ;

drop function if exists get_uniprot_end;
DELIMITER $$
create function get_uniprot_end(pdb varchar(4),chain varchar(255)) returns varchar(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT refUniProtEnd FROM  ChainCluster 
WHERE pdbCode=pdb 
AND (repChain LIKE BINARY CONCAT("%",chain,"%") or memberChains LIKE BINARY CONCAT("%",chain,"%")) );
RETURN res;
END $$
DELIMITER ;


DROP VIEW IF EXISTS detailedView;
CREATE VIEW detailedView as
SELECT 
p.pdbCode,
p.expMethod,
p.resolution,
p.rfreeValue,
p.spaceGroup,
get_uniprot_id(p.pdbCode,i.chain1) c1,
get_uniprot_start(p.pdbCode,i.chain1) s1,
get_uniprot_end(p.pdbCode,i.chain1) e1,
get_uniprot_id_cutoff(p.pdbCode,i.chain1) co1,
get_uniprot_id(p.pdbCode,i.chain2) c2,
get_uniprot_start(p.pdbCode,i.chain2) s2,
get_uniprot_end(p.pdbCode,i.chain2) e2,
get_uniprot_id_cutoff(p.pdbCode,i.chain2) co2,
get_homologs(p.pdbCode,i.chain1) h1,
get_homologs(p.pdbCode,i.chain2) h2,
get_repchain(p.pdbCode,i.chain1) repchain1,
get_repchain(p.pdbCode,i.chain2) repchain2,
i.chain1,
i.chain2,
i.interfaceId,
i.area,
i.infinite,
i.operator,
i.operatorType,
i.clusterId,
get_result(i.uid,"eppic-gm") gm,
get_side_score(i.uid,"eppic-gm",1) gm1,
get_side_score(i.uid,"eppic-gm",2) gm2,
get_score(i.uid,"eppic-gm") gmScore,
get_result(i.uid,"eppic-cr") cr,
get_side_score(i.uid,"eppic-cr",1) cr1,
get_side_score(i.uid,"eppic-cr",2) cr2,
get_score(i.uid,"eppic-cr") crScore,
get_result(i.uid,"eppic-cs") cs,
get_side_score(i.uid,"eppic-cs",1) cs1,
get_side_score(i.uid,"eppic-cs",2) cs2,
get_score(i.uid,"eppic-cs") csScore,
get_result(i.uid,"eppic") final,
get_result2(i.interfaceCluster_uid,"pisa") pisa,
get_result2(i.interfaceCluster_uid,"authors") authors,
get_result2(i.interfaceCluster_uid,"pqs") pqs,
s1.c100 c1_100,
s1.c95 c1_95,
s1.c90 c1_90,
s1.c80 c1_80,
s1.c70 c1_70,
s1.c60 c1_60,
s1.c50 c1_50,
s2.c100 c2_100,
s2.c95 c2_95,
s2.c90 c2_90,
s2.c80 c2_80,
s2.c70 c2_70,
s2.c60 c2_60,
s2.c50 c2_50
from Interface as i 
inner join PdbInfo as p on i.pdbCode = p.pdbCode 
inner join SeqCluster as s1 on s1.pdbCode=i.pdbCode and s1.repChain = get_repchain(p.pdbCode,i.chain1)
inner join SeqCluster as s2 on s2.pdbCode=i.pdbCode and s2.repChain = get_repchain(p.pdbCode,i.chain2)
inner join Job as j on j.inputName = i.pdbCode and j.uid= p.job_uid where length(j.jobId)=4;

drop table if exists detailedTable;
create table detailedTable as select * from detailedView;









#dunbrack stuff

create table dunbrack_10_60(
pfam varchar(255),
pdbCode varchar(4),
interfaceId int(11),
chain1 varchar(4),
chain2 varchar(4),
dn_op1 varchar(255),
dn_op2 varchar(255),
dn_area double,
m int(11),
n int(11),
ratio double,
ep_op1 varchar(255),
ep_op2 varchar(255),
ep_op3 varchar(255),
ep_op4 varchar(255)
)

drop view eppic_dunbrack;
create view eppic_dunbrack as
select e.*,d.interfaceId du_id,d.chain1 dn_chain1,d.chain2 dn_chain2,d.dn_op1,d.dn_op2,d.ep_op1,d.ep_op2,d.ep_op3,d.ep_op4,d.dn_area,d.m,d.n,d.ratio,d.pfam from eppic_test_2_1_0.detailedTable as e inner join dunbrack_10_60 as d on d.pdbCode=e.pdbCode
where ((binary e.chain1 = d.chain1 and binary e.chain2 = d.chain2) or (binary e.chain1 = d.chain2 and binary e.chain2 = d.chain1)) and (
(d.ep_op1 = 'X,Y,Z' and d.ep_op2 = 'X,Y,Z' and e.operator = 'X,Y,Z' ) or
(d.ep_op1 = 'X,Y,Z' and d.ep_op2 != 'X,Y,Z' and e.operator != 'X,Y,Z' and (e.operator = d.ep_op1 or e.operator = d.ep_op2 or e.operator = d.ep_op3 or e.operator = d.ep_op4)) or
(d.ep_op1 != 'X,Y,Z' and d.ep_op2 = 'X,Y,Z' and e.operator != 'X,Y,Z' and (e.operator = d.ep_op1 or e.operator = d.ep_op2 or e.operator = d.ep_op3 or e.operator = d.ep_op4))) group by e.pdbCode,e.interfaceId;






select e.*,d.interfaceId du_id,d.chain1 dn_chain1,d.chain2 dn_chain2,d.dn_op1,d.dn_op2,d.ep_op1,d.ep_op2,d.ep_op3,d.ep_op4,d.dn_area,d.m,d.n,d.ratio,d.pfam from eppic_test_2_1_0.detailedTable as e inner join dunbrack_10_60 as d on d.pdbCode=e.pdbCode
where ((binary e.chain1 = d.chain1 and binary e.chain2 = d.chain2) or (binary e.chain1 = d.chain2 and binary e.chain2 = d.chain1)) and (
(d.ep_op1 = 'X,Y,Z' and d.ep_op2 = 'X,Y,Z' and e.operator = 'X,Y,Z' ) or
(d.ep_op1 = 'X,Y,Z' and d.ep_op2 != 'X,Y,Z' and e.operator != 'X,Y,Z' and (e.operator = d.ep_op1 or e.operator = d.ep_op2 or e.operator = d.ep_op3 or e.operator = d.ep_op4)) or
(d.ep_op1 != 'X,Y,Z' and d.ep_op2 = 'X,Y,Z' and e.operator != 'X,Y,Z' and (e.operator = d.ep_op1 or e.operator = d.ep_op2 or e.operator = d.ep_op3 or e.operator = d.ep_op4))) and e.pdbCode='1ftj';





DROP FUNCTION IF EXISTS IsMultimer;
DELIMITER $$
CREATE FUNCTION IsMultimer(pdb VARCHAR(255)) RETURNS bool
BEGIN
DECLARE res1 bool;
DECLARE res int(11);
SET res=(SELECT count(*) FROM detailedTable WHERE pdbCode=pdb and final = "bio");
if (res=0) then
set res1=False;
else
set res1=True;
end if;
return res1;
END $$
DELIMITER ; 




alter table detailedTable add  assembly varchar(255) default "Monomer";
update detailedTable set assembly="Multimer" where IsMultimer(pdbCode);

alter table PdbInfo add assembly varchar(255) default "Monomer";
update PdbInfo set assembly="Multimer" where IsMultimer(pdbCode);





DROP TABLE IF EXISTS EppicTable;
CREATE Table EppicTable as
SELECT 
p.pdbCode,
p.expMethod,
p.resolution,
p.rfreeValue,
p.spaceGroup,
get_uniprot_id(p.pdbCode,i.chain1) c1,
get_uniprot_start(p.pdbCode,i.chain1) s1,
get_uniprot_end(p.pdbCode,i.chain1) e1,
get_uniprot_id_cutoff(p.pdbCode,i.chain1) co1,
get_uniprot_id(p.pdbCode,i.chain2) c2,
get_uniprot_start(p.pdbCode,i.chain2) s2,
get_uniprot_end(p.pdbCode,i.chain2) e2,
get_uniprot_id_cutoff(p.pdbCode,i.chain2) co2,
get_homologs(p.pdbCode,i.chain1) h1,
get_homologs(p.pdbCode,i.chain2) h2,
get_repchain(p.pdbCode,i.chain1) repchain1,
get_repchain(p.pdbCode,i.chain2) repchain2,
i.chain1,
i.chain2,
i.interfaceId,
i.area,
i.infinite,
i.operator,
i.operatorType,
i.clusterId,
get_result(i.uid,"eppic-gm") gm,
get_side_score(i.uid,"eppic-gm",1) gm1,
get_side_score(i.uid,"eppic-gm",2) gm2,
get_score(i.uid,"eppic-gm") gmScore,
get_result(i.uid,"eppic-cr") cr,
get_side_score(i.uid,"eppic-cr",1) cr1,
get_side_score(i.uid,"eppic-cr",2) cr2,
get_score(i.uid,"eppic-cr") crScore,
get_result(i.uid,"eppic-cs") cs,
get_side_score(i.uid,"eppic-cs",1) cs1,
get_side_score(i.uid,"eppic-cs",2) cs2,
get_score(i.uid,"eppic-cs") csScore,
get_result(i.uid,"eppic") final,
get_result2(i.interfaceCluster_uid,"pisa") pisa,
get_result2(i.interfaceCluster_uid,"authors") authors,
get_result2(i.interfaceCluster_uid,"pqs") pqs
from Interface as i 
inner join PdbInfo as p on i.pdbCode = p.pdbCode 
inner join Job as j on j.inputName = i.pdbCode and j.uid= p.job_uid where length(j.jobId)=4;












