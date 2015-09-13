DROP VIEW IF EXISTS asym_score;
CREATE VIEW asym_score AS
SELECT
pdbCode,
interfaceId,
cr1,
cr2,
abs(cr1-cr2) cr_diff,
cs1,
cs2,
abs(cs1-cs2) cs_diff,
operatorType,
infinite,
h1,
h2,
get_seq_clusterid(pdbCode,chain1,95) c95,
get_seq_clusterid(pdbCode,chain1,100) c100
FROM EppicTable
WHERE
resolution<2.0 AND
rfreeValue < 0.3 AND
crcall!="nopred" AND
abs(cs1-cs2) < 300 AND
numChainClusters=1 AND
cscall!="nopred" order by cs_diff desc;


select a.*,e.pdbCode,e.cr1,e.cr2,e.cs1,e.cs2 from asym_score as a
inner join EppicView2 as e on (a.c100=e.c1_100 or c100=e.c2_100) and e.numChainClusters>1 limit 10;


DROP FUNCTION IF EXISTS get_core;
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

DROP VIEW IF EXISTS asymscore;
CREATE VIEW asymscore AS
SELECT
a.pdbName,
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




drop view if exists target_set;
create view target_set as 
select a.pdbName pdb,
a.uniprotId,
a.subInterval,
p.pdbName target,
h.subInterval t_sub,
h.uniprotId chaina,
a.id sid,
h2.chains,
h2.uniprotId chainb,
i.id tid
from asymscore as a
inner join HomologsInfoItem as h on a.uniprotID=h.uniprotId and is_same_segment(a.subInterval,h.subInterval,5)
inner join PdbScore as p on h.pdbScoreItem_uid=p.uid
inner join HomologsInfoItem as h2 on h2.pdbScoreItem_uid=p.uid 
inner join Interface as i on h2.pdbScoreItem_uid=i.pdbScoreItem_uid
inner join InterfaceScore as j on j.interfaceItem_uid=i.uid
where i.finalCallName="bio" and j.unweightedRatio1Scores is not null and j.unweightedRatio2Scores is not null;

