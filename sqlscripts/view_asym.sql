select a.pdbName,a.id,a.cr1,a.cr2,a.cr_diff from asym_interface as a where  cr1>0 and cr2>0  and cr1<10 and cr2 < 10 order by cr_diff desc limit 10;

SELECT 
a.pdbName,
a.id,
a.cr1,
a.cr2,
a.cr_diff,
get_core(i.id,1),
get_core(i.id,2)
FROM asym_interface as a 
INNER JOIN PdbScore as p on a.pdbName=p.pdbName 
INNER JOIN Interface as i on p.uid=i.pdbScoreItem_uid and a.id=i.id 
WHERE a.cr1>0 and a.cr2>0  and a.cr1<10 and a.cr2 < 10 order by cr_diff ;

DROP FUNCTION IF EXISTS get_core(id INT(11),s INT(11))
DELIMITER $$
CREATE FUNCTION get_core(id INT(11),s INT(11)) 
RETURNS INT(11)
BEGIN
DECLARE x INT(11);
SET x=(SELECT COUNT(*) FROM InterfaceResidue where interfaceItem_uid=id and assignment >=2 
and structure = s);
RETURN x;
END$$
DELIMITER ;




create view asym_interface as select pdbName,id,area,cr1,cr2,abs(cr1-cr2) cr_diff,cs1,cs2,abs(cs1-cs2) cs_diff from full_table where resolution<2.0 and (abs(cr1-cr2)>0.5 or abs(cs1-cs2)>2.0) and c=1 and RFree<0.3 and CoreRim!="nopred" and CoreSur!="nopred";

DROP VIEW IF EXISTS asym_score;
CREATE VIEW asym_score AS
SELECT
pdbName,
id,
cr1,
cr2,
abs(cr1-cr2) cr_diff,
cs1,
cs2,
abs(cs1-cs2) cs_diff,
operatorType,
isInfinite,
homologs1 h1,
homologs2 h2
FROM full_table
WHERE
resolution<2.0 AND
c=1 AND
RFree < 0.3 AND
CoreRim!="nopred" AND
CoreSur!="nopred";

DROP VIEW IF EXISTS cr_asym_score;
CREATE VIEW cr_asym_score AS
SELECT
a.pdbName,
a.id,
a.cr1,
a.cr2,
a.cr_diff,
a.operatorType,
a.isInfinite,
a.h1,
a.h2
FROM asym_score AS a
INNER JOIN PdbScore as p ON p.pdbName=a.pdbName 
INNER JOIN Interface as i ON i.pdbScoreItem_uid=p.uid AND i.id=a.id
where a.cr_diff>0.5 and cr1<01 and cr2<10 and get_core(i.uid,1)>=4 and get_core(i.uid,2)>=4; 


DROP VIEW IF EXISTS cs_asym_score;
CREATE VIEW cs_asym_score AS
SELECT
a.pdbName,
a.id,
a.cs1,
a.cs2,
a.cs_diff,
a.operatorType,
a.isInfinite,
a.h1,
a.h2
FROM asym_score AS a
INNER JOIN PdbScore as p ON p.pdbName=a.pdbName 
INNER JOIN Interface as i ON i.pdbScoreItem_uid=p.uid AND i.id=a.id
where a.cs_diff>2.0 and cs1<01 and cs2<10 and get_core(i.uid,1)>=4 and get_core(i.uid,2)>=4;



select * from cs_asym_score where operatorType!=3 and operatorType!=4 and operatorType!=5 and operatorType!=6 and operatorType!="3S" and operatorType!="4S" and operatorType!="5S" and operatorType!="6S" and h1>30 and ((cs1<-1 and cs2>-1) or (cs1>-1 and cs2<-1)) order by cs_diff into outfile '/tmp/cs_asym3.list';


select 
p.pdbName,
i.id,
s.unweightedRatio1Scores cr1,
s.unweightedRatio2Scores cr2,
abs(s.unweightedRatio1Scores-s.unweightedRatio2Scores) diff_cr,
get_core(i.uid,1) core1,
get_core(i.uid,2) core2
from PdbScore as p
inner join Interface as i on
i.pdbScoreItem_uid=p.uid
inner join InterfaceScore as s on 
s.interfaceItem_uid=i.uid 
where s.method="Entropy" and
get_core(i.uid,1)>=4 and
get_core(i.uid,2)>=4 and
abs(s.unweightedRatio1Scores-s.unweightedRatio2Scores)>0.5 and
s.unweightedRatio1Scores<10 and
s.unweightedRatio2Scores<10 
limit 10;

select * from cr_asym_score where operatorType!=3 and operatorType!=4 and operatorType!=5 and operatorType!=6 and operatorType!="3S" and operatorType!="4S" and operatorType!="5S" and operatorType!="6S" and h1>30 and ((cr1<0.75 and cr2>0.75) or (cr1>0.75 and cr2<0.75)) order by cr_diff into outfile '/tmp/cr_asym3.list';

select * from cs_asym_score where operatorType!=3 and operatorType!=4 and operatorType!=5 and operatorType!=6 and operatorType!="3S" and operatorType!="4S" and operatorType!="5S" and operatorType!="6S" and h1>30 and ((cs1<-1 and cs2>-1) or (cs1>-1 and cs2<-1)) order by cs_diff into outfile '/tmp/cs_asym3.list';





DROP VIEW IF EXISTS asymscore;
CREATE VIEW asymscore AS
SELECT
a.pdbName,
a.id,
a.cr1,
a.cr2,
a.cr_diff,
a.cs1,
a.cs2,
a.cs_diff,
a.operatorType,
a.isInfinite,
p.uid pdbScoreItem_uid,
h.uid homologsIforItem_uid,
h.uniprotId,
h.subInterval
FROM asym_score AS a
INNER JOIN PdbScore as p ON p.pdbName=a.pdbName 
INNER JOIN HomologsInfoItem as h ON p.uid=h.pdbScoreItem_uid
INNER JOIN Interface as i ON i.pdbScoreItem_uid=p.uid AND i.id=a.id
where 
a.cs_diff>2.0 and cs1<01 and cs2<10 and
a.cr_diff>0.5 and cr1<01 and cr2<10 and
get_core(i.uid,1)>=4 and get_core(i.uid,2)>=4 and 
a.h1>30 and a.h2>20 and
a.operatorType!=3 and a.operatorType!=4 and a.operatorType!=5 and a.operatorType!=6 and a.operatorType!="3S" and a.operatorType!="4S" and a.operatorType!="5S" and a.operatorType!="6S" and
((cr1<0.75 and cr2>0.75) or (cr1>0.75 and cr2<0.75)) and
((cs1<-1 and cs2>-1) or (cs1>-1 and cs2<-1));


DROP PROCEDURE IF EXISTS same_uniprot;
DELIMITER $$
CREATE PROCEDURE same_uniprot(uniprotid VARCHAR(255))
BEGIN
SELECT p.pdbName,h.uniprotId,h.subInterval,c.chains 
FROM HomologsInfoItem as h INNER JOIN PdbScore as p 
ON p.uid=h.pdbScoreItem_uid INNER JOIN PdbChains as c
on c.pdbName=p.pdbName WHERE
h.uniprotId=uniprotid;
END $$
DELIMITER ;

fs
DROP PROCEDURE IF EXISTS bm_kb_range;
DELIMITER $$
CREATE PROCEDURE bm_kb_range(s DOUBLE, e DOUBLE, d DOUBLE, mth VARCHAR(255))
BEGIN
DECLARE i DOUBLE;
DECLARE result VARCHAR(255);
SET i=s;
count_loop:LOOP
SET result=(SELECT bm_kb(i,mth));
SELECT result;
SET i=i+d;
IF i >=e THEN
LEAVE count_loop;
END IF;
END LOOP;
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS is_same_segment;
DELIMITER $$
CREATE FUNCTION is_same_segment(seg1 VARCHAR(255),seg2 VARCHAR(255),range int(11))
RETURNS INT(11)
BEGIN
DECLARE x1 int(11);
DECLARE x2 int(11);
DECLARE y1 int(11);
DECLARE y2 int(11);
DECLARE x int(11);
SET x1=substring_index(seg1,"-",1);
SET x2=substring_index(seg1,"-",-1);
SET y1=substring_index(seg2,"-",1);
SET y2=substring_index(seg2,"-",-1);
IF (x1>(y1-range) and x1<(y1+range) and x2>(y2-range) and x2<(y2+range)) or
(y1>(x1-range) and y1<(x1+range) and y2>(x2-range) and y2<(x2+range)) THEN
SET x = 1;
ELSE
SET x = 0;
END IF ;
RETURN x;
END $$
DELIMITER ;

SELECT 
a.pdbName,
a.id,
i.chain1,
i.chain2,
h.chains,
h.uniprotId,
h.subInterval
FROM asymscore AS a
INNER JOIN PdbScore AS p ON a.pdbName=p.pdbName 
INNER JOIN Interface AS i ON p.uid=i.pdbScoreItem_uid and a.id=i.id
INNER JOIN HomologsInfoItem AS h ON h.pdbScoreItem_uid=p.uid
limit 10;



SELECT
p.pdbName,
h.uniprotId,
h.subInterval,
h.chains
FROM PdbScore as p 
INNER JOIN HomologsInfoItem AS h ON p.uid=h.pdbScoreItem_uid
WHERE h.uniprotID="P00709";

SELECT
p.uid
FROM PdbScore as p 
INNER JOIN HomologsInfoItem AS h ON p.uid=h.pdbScoreItem_uid
WHERE h.uniprotID="P00709";

select p.pdbName,h.chains,h.uniprotId from HomologsInfoItem as h
inner join PdbScore as p on p.uid=h.pdbScoreItem_uid
where pdbScoreItem_uid in (SELECT
p.uid
FROM PdbScore as p 
INNER JOIN HomologsInfoItem AS h ON p.uid=h.pdbScoreItem_uid
WHERE h.uniprotID = (SELECT 
h.uniprotId
FROM asymscore AS a
INNER JOIN PdbScore AS p ON a.pdbName=p.pdbName 
INNER JOIN Interface AS i ON p.uid=i.pdbScoreItem_uid and a.id=i.id
INNER JOIN HomologsInfoItem AS h ON h.pdbScoreItem_uid=p.uid
limit 10));



select p.pdbNmae,



select 
a.pdbName,
h.uniprotId, 
h.chains,
h.pdbScoreItem_uid,
p.pdbName
from HomologsInfoItem as h inner join asymscore as a on h.uniprotId=a.uniprotId
inner join PdbScore as p on p.uid=h.pdbScoreItem_uid limit 10;



select p1.pdbName,h.uniprotId,h.subInterval
from PdbScore as p1 inner join
HomologsInfoItem as h on h.pdbScoreItem_uid=p.uid
where p.uid in (select p.uid
from HomologsInfoItem as h inner join asymscore as a on h.uniprotId=a.uniprotId
inner join PdbScore as p on p.uid=h.pdbScoreItem_uid limit 10);




select 
t.pdb,
t.target,
h.chains,
h.uniprotId
from target_set as t
inner join HomologsInfoItem as h 
on h.pdbScoreItem_uid=t.pdbScoreItem_uid limit 10;

drop view if exists target_set;
create view target_set as 
select a.pdbName pdb,a.uniprotId,a.subInterval,p.pdbName target,h.subInterval t_sub,h.uniprotId chaina,a.id sid,h2.chains,h2.uniprotId chainb,i.id tid
from asymscore as a
inner join HomologsInfoItem as h on a.uniprotID=h.uniprotId and is_same_segment(a.subInterval,h.subInterval,5)
inner join PdbScore as p on h.pdbScoreItem_uid=p.uid
inner join HomologsInfoItem as h2 on h2.pdbScoreItem_uid=p.uid 
inner join Interface as i on h2.pdbScoreItem_uid=i.pdbScoreItem_uid
where i.finalCallName="bio";


