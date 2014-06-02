drop function if exists get_uniprot_id;
DELIMITER $$
create function get_uniprot_id(interfaceid INT,chain varchar(255)) returns varchar(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT uniprotid FROM HomologsInfoItem WHERE pdbScoreItem_uid=interfaceid and chains like BINARY CONCAT("%",chain,"%"));
RETURN res;
END $$
DELIMITER ;




drop function if exists get_taxonomy;
DELIMITER $$
create function get_taxonomy(uniprot varchar(255)) returns varchar(255)
BEGIN
DECLARE tax varchar(255);
DECLARE loc int(11);
select locate(";",t.lineage) into loc from taxonomy as t 
inner join uniprot_clusters as u on u.tax_id=t.tax_id where u.member=uniprot;
if (loc=0) then
select lineage into tax from taxonomy as t 
inner join uniprot as u on u.tax_id=t.tax_id where u.uniprot_id=uniprot;
else
select substring(lineage,1,(locate(";",lineage))-1) into tax from taxonomy as t 
inner join uniprot_clusters as u on u.tax_id=t.tax_id where u.member=uniprot;
end if;
if tax not in ("Archaea","Bacteria","Eukaryota","Viroids","Viruses") then
set tax="Plasmids, uncultured organisms, etc";
end if;
return tax;
END $$
DELIMITER ;


select uniprot_2014_05.get_taxonomy(uniprotId),count(*) count from HomologsInfoItem as h inner join PdbScore as p on p.uid=h.pdbScoreItem_uid inner join Job as j on j.uid=p.jobItem_uid where length(jobId)=4 and h.hasQueryMatch group by  uniprot_2014_05.get_taxonomy(uniprotId) order by count(*) desc;


select p.pdbName,i.clusterId,count(*) count from Interface as i inner join PdbScore as p on p.uid=i.pdbScoreItem_uid inner join Job as j on j.uid=p.jobItem_uid where length(jobId)=4 group by i.pdbScoreItem_uid,i.clusterId order by count(*) desc limit 10;


select p.pdbName,uniprot_2014_05.get_taxonomy(uniprotId) from HomologsInfoItem as h inner join PdbScore as p on p.uid=h.pdbScoreItem_uid inner join Job as j on j.uid=p.jobItem_uid where length(jobId)=4 and h.hasQueryMatch and uniprot_2014_05.get_taxonomy(uniprotId)="Not applicable";
