#!/bin/bash

db="crk_2013_10"
highres="highres"
resolution=2.5
fullview="full"
xray="xray"
forstat="eppic"
mysql << EOF
USE $db;

DROP FUNCTION IF EXISTS get_homologs;
DELIMITER $$
CREATE FUNCTION get_homologs(pdbuid INT,chain VARCHAR(255)) RETURNS INT(12)
BEGIN
DECLARE x INT(12);
SET x=(SELECT numHomologs 
FROM HomologsInfoItem 
WHERE pdbScoreItem_uid=pdbuid 
AND chains LIKE BINARY CONCAT("%",chain,"%"));
RETURN x;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS get_idcutoff;
DELIMITER $$
CREATE FUNCTION get_idcutoff(pdbuid INT,chain VARCHAR(255)) 
RETURNS DOUBLE
BEGIN
DECLARE x DOUBLE;
SET x=(SELECT idCutoffUsed 
FROM HomologsInfoItem 
WHERE pdbScoreItem_uid=pdbuid 
AND chains LIKE BINARY CONCAT("%",chain,"%"));
RETURN x;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS pred;
DELIMITER $$
CREATE FUNCTION pred(i_uid int(11),m VARCHAR(15)) RETURNS varchar(6)
BEGIN
DECLARE res VARCHAR(6);
SET res=(SELECT callName 
FROM InterfaceScore
WHERE interfaceItem_uid=i_uid
AND method=m);
RETURN res;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS score;
DELIMITER $$
CREATE FUNCTION score(i_uid int(11),m VARCHAR(15),s varchar(255)) RETURNS DOUBLE
BEGIN
DECLARE res DOUBLE;
IF s = "ratio1" THEN
SET res=(SELECT unweightedRatio1Scores FROM InterfaceScore WHERE interfaceItem_uid=i_uid AND method=m);
ELSEIF s = "ratio2" THEN
SET res=(SELECT unweightedRatio2Scores FROM InterfaceScore WHERE interfaceItem_uid=i_uid AND method=m);
ELSE 
SET res=(SELECT unweightedFinalScores FROM InterfaceScore WHERE interfaceItem_uid=i_uid AND method=m);
END IF;
RETURN res;
END$$
DELIMITER ;


DROP VIEW IF EXISTS PdbChains;
CREATE VIEW PdbChains AS 
SELECT p.uid AS uid,p.pdbName AS pdbName,group_concat(h.chains separator',') AS chains from (PdbScore p join HomologsInfoItem h on((p.uid = h.pdbScoreItem_uid))) group by h.pdbScoreItem_uid; 
DROP FUNCTION IF EXISTS numberOfLetters;

DELIMITER $$

CREATE FUNCTION numberOfLetters(s VARCHAR(255)) RETURNS INT DETERMINISTIC NO SQL
BEGIN
    DECLARE c INT;
    DECLARE r INT DEFAULT 0;
    DECLARE n INT DEFAULT LENGTH(s);
    DECLARE i INT DEFAULT 1;

    WHILE i <= n DO
        SET c = ASCII(SUBSTRING(s, i, 1));
        IF (c >= 65 AND c <= 90) OR (c >= 97 AND c <= 122) OR (c >= 48 AND c <= 57)  THEN
            SET r = r + 1;
        END IF;
        SET i = i + 1;
    END WHILE;

    RETURN r;
END$$

DELIMITER ;

DROP VIEW IF EXISTS full_table;
CREATE VIEW full_table AS
SELECT
p.pdbName,
p.resolution,
p.rfreeValue RFree,
p.expMethod,
p.spaceGroup,
c.chains,
numberOfLetters(c.chains) c,
i.id,
i.chain1,
i.chain2,
i.area,
i.operator,
i.operatorType,
i.isInfinite,
get_homologs(p.uid,i.chain1) homologs1,
get_idcutoff(p.uid,i.chain1) idcutoff1,
get_homologs(p.uid,i.chain2) homologs2,
get_idcutoff(p.uid,i.chain2) idcutoff2,
i.size1,
i.size2,
(i.size1+i.size2) csize,
pred(i.uid,"Geometry") Geometry,
score(i.uid,"Entropy","ratio1") cr1,
score(i.uid,"Entropy","ratio2") cr2,
score(i.uid,"Entropy","final") cr,
pred(i.uid,"Entropy") CoreRim,
score(i.uid,"Z-scores","ratio1") cs1,
score(i.uid,"Z-scores","ratio2") cs2,
score(i.uid,"Z-scores","final") cs,
pred(i.uid,"Z-scores") CoreSur,
i.finalCallName final
FROM PdbScore as p
INNER JOIN Interface AS i ON p.uid=i.pdbScoreItem_uid
INNER JOIN PdbChains AS c ON c.uid=p.uid
INNER JOIN Job AS j ON j.uid=p.jobItem_uid AND length(j.jobId)=4 AND j.status="Finished";





