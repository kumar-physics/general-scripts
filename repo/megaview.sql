drop function if exists get_uniprot_id;
DELIMITER $$
create function get_uniprot_id(interfaceid INT,chain varchar(255)) returns varchar(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT uniprotid FROM HomologsInfoItem WHERE pdbScoreItem_uid=interfaceid and chains like BINARY CONCAT("%",chain,"%"));
RETURN res;
END $$
DELIMITER ;
