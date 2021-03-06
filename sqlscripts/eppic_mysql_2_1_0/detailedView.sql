

/* to get the results from InterfaceScore table */
DROP FUNCTION IF EXISTS get_result;
DELIMITER $$
CREATE FUNCTION get_result(interfaceid INT,met VARCHAR(255)) RETURNS VARCHAR(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT callName FROM InterfaceScore WHERE interfaceItem_uid=interfaceid and method = met);
RETURN res;
END $$
DELIMITER ;

/*to get the eppic scores from InterfaceScore table*/
DROP FUNCTION IF EXISTS get_score;
DELIMITER $$
CREATE FUNCTION get_score(interfaceid INT,met VARCHAR(255)) RETURNS DOUBLE
BEGIN
DECLARE res DOUBLE;
SET res=(SELECT score FROM InterfaceScore WHERE interfaceItem_uid=interfaceid and method = met);
RETURN res;
END $$
DELIMITER ;

/*to get the eppic scores of each side from InterfaceScore table*/
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

/* to get the number of homologs */
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

/* to get the representative chain */
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


/* to get the uniprot id */
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

/* to get the uniprot id cutoff used */
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


/* to get the uniprot start */

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


/* to get the uniprot end */
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


/* after creating the view, its better to create table in order to get faster results */
drop table if exists detailedTable;
create table detailedTable as select * from detailedView;

create index pdbidx on detailedTable(pdbCode,c1,c2);





