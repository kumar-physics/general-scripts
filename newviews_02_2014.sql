


DROP FUNCTION IF EXISTS get_result;
DELIMITER $$
CREATE FUNCTION get_result(interfaceid INT,met VARCHAR(255)) RETURNS VARCHAR(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT callName FROM InterfaceScore WHERE interfaceItem_uid=interfaceid and method like met);
RETURN res;
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS get_score;
DELIMITER $$
CREATE FUNCTION get_score(interfaceid INT,met VARCHAR(255)) RETURNS DOUBLE
BEGIN
DECLARE res DOUBLE;
SET res=(SELECT unweightedFinalScores FROM InterfaceScore WHERE interfaceItem_uid=interfaceid and method like met);
RETURN res;
END $$
DELIMITER ;


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

DROP VIEW IF EXISTS webview;
CREATE VIEW webview as
SELECT 
p.pdbName,
p.expMethod,
p.resolution,
get_homologs(p.uid,i.chain1) h1,
get_homologs(p.uid,i.chain2) h2,
i.id,
i.area,
i.isInfinite,
i.size1,
i.size2,
get_result(i.uid,"Geometry") geometry,
get_score(i.uid,"Entropy") crScore,
get_result(i.uid,"Entropy") cr,
get_score(i.uid,"Z-scores") csScore,
get_result(i.uid,"Z-scores") cs,
i.finalCallName final
from PdbScore as p inner join Interface as i
on i.pdbScoreItem_uid=p.uid inner join Job as j on length(j.jobId)=4 and j.uid=p.jobItem_uid;

drop view if exists dc_bio;
create view dc_bio as 
select w.* from webview as w inner join benchmark.dc_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;
drop view if exists dc_xtal;
create view dc_xtal as 
select w.* from webview as w inner join benchmark.dc_xtal as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid; 

drop view if exists po_bio;
create view po_bio as 
select w.* from webview as w inner join benchmark.ponstingl_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;
drop view if exists po_xtal;
create view po_xtal as 
select w.* from webview as w inner join benchmark.ponstingl_xtal as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid; 

drop view if exists many_bio;
create view many_bio as
select * from webview where size1>10 and size2>10 and resolution<2.5 and area>1000 and area<2000;

drop view if exists many_xtal;
create view many_xtal as
select * from webview where resolution<2.5 and isInfinite=1 and area>1000;



DROP VIEW IF EXISTS fulldata;
CREATE VIEW fulldata as
SELECT 
p.pdbName,
p.expMethod,
p.resolution,
get_homologs(p.uid,i.chain1) h1,
get_homologs(p.uid,i.chain2) h2,
get_uniprot_id(i.pdbScoreItem_uid,chain1) chain1,
get_uniprot_id(i.pdbScoreItem_uid,chain2) chain2,
i.id,
i.area,
i.isInfinite,
i.size1,
i.size2,
get_result(i.uid,"Geometry") geometry,
get_score(i.uid,"Entropy") crScore,
get_result(i.uid,"Entropy") cr,
get_score(i.uid,"Z-scores") csScore,
get_result(i.uid,"Z-scores") cs,
i.finalCallName final
from PdbScore as p inner join Interface as i
on i.pdbScoreItem_uid=p.uid inner join Job as j on length(j.jobId)=4 and j.uid=p.jobItem_uid;

drop function if exists get_uniprot_id;
DELIMITER $$
create function get_uniprot_id(interfaceid INT,chain varchar(255)) returns varchar(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT uniprotid FROM HomologsInfoItem WHERE pdbScoreItem_uid=interfaceid and chains like BINARY CONCAT("%",chain,"%"));
RETURN res;
END $$
DELIMITER ;

drop function if exists get_uniprot_start;
DELIMITER $$
create function get_uniprot_start(interfaceid INT,chain varchar(255)) returns varchar(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT refUniProtStart FROM HomologsInfoItem WHERE pdbScoreItem_uid=interfaceid and chains like BINARY CONCAT("%",chain,"%"));
RETURN res;
END $$
DELIMITER ;

drop function if exists get_uniprot_end;
DELIMITER $$
create function get_uniprot_end(interfaceid INT,chain varchar(255)) returns varchar(255)
BEGIN
DECLARE res VARCHAR(255);
SET res=(SELECT refUniProtEnd FROM HomologsInfoItem WHERE pdbScoreItem_uid=interfaceid and chains like BINARY CONCAT("%",chain,"%"));
RETURN res;
END $$
DELIMITER ;


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


drop function if exists IsSameArea;
DELIMITER $$
create function IsSameArea(a1 DOUBLE, a2 DOUBLE,da DOUBLE) returns bool
BEGIN
declare res bool;
if ((a2>=(a1-da) and a2<=(a1+da)) or (a1>=(a2-da) and a1<=(a2+da))) then
set res=1;
else
set res=0;
end if;
return res;
end $$
DELIMITER ;


drop table if exists full_table;
create table full_table as 
SELECT 
p.pdbName,
p.expMethod,
p.resolution,
get_homologs(p.uid,i.chain1) h1,
get_homologs(p.uid,i.chain2) h2,
get_uniprot_id(i.pdbScoreItem_uid,chain1) chain1,
get_uniprot_start(i.pdbScoreItem_uid,chain1) s1,
get_uniprot_end(i.pdbScoreItem_uid,chain1) e1,
get_uniprot_id(i.pdbScoreItem_uid,chain2) chain2,
get_uniprot_start(i.pdbScoreItem_uid,chain2) s2,
get_uniprot_end(i.pdbScoreItem_uid,chain2) e2,
i.id,
i.area,
i.clusterId,
i.isInfinite,
i.size1,
i.size2,
get_result(i.uid,"Geometry") geometry,
get_score(i.uid,"Entropy") crScore,
get_result(i.uid,"Entropy") cr,
get_score(i.uid,"Z-scores") csScore,
get_result(i.uid,"Z-scores") cs,
i.finalCallName final
from PdbScore as p inner join Interface as i
on i.pdbScoreItem_uid=p.uid inner join Job as j on length(j.jobId)=4 and j.uid=p.jobItem_uid;




drop table if exists nmr_table;
create table nmr_table as select * from detailedView where expMethod like "%NMR%";
drop table if exists xray_table;
create table xray_table as select * from detailedView where expMethod like "%X-RAY%";

create index chainidx on xray_table(chain1,chain2);
create index chainidx on nmr_table(chain1,chain2);

drop table if exists nmr_xray_table;
create table nmr_xray_table as select n.pdbName pdbn,f.pdbName pdbx,n.chain1 chain1n,n.s1 s1n,n.e1 e1n,f.chain1 chain1x,f.s1 s1x,f.e1 e1x,n.chain2 chain2n,n.s2 s2n,n.e2 e2n,f.chain2 chain2x,f.s2 s2x,f.e2 e2x,n.area arean,f.area areax, f.resolution,n.final finaln,f.final finalx from nmr_table as n inner join full_table as f on 
((n.chain1=f.chain1 and n.chain2=f.chain2 and IsSameSegment(n.s1,n.e1,f.s1,f.e1,5) and IsSameSegment(n.s2,n.e2,f.s2,f.e2,5)) or 
(n.chain1=f.chain2 and n.chain2=f.chain1 and IsSameSegment(n.s1,n.e1,f.s2,f.e2,5) and IsSameSegment(n.s2,n.e2,f.s1,f.e1,5))) and IsSameArea(n.area,f.area,100)
where f.expMethod not like "%NMR%";




DROP VIEW IF EXISTS detailedView;
CREATE VIEW detailedView as
SELECT 
p.pdbName,
p.expMethod,
p.resolution,
get_uniprot_id(i.pdbScoreItem_uid,i.chain1) chain1,
get_uniprot_start(i.pdbScoreItem_uid,i.chain1) s1,
get_uniprot_end(i.pdbScoreItem_uid,i.chain1) e1,
get_uniprot_id(i.pdbScoreItem_uid,i.chain2) chain2,
get_uniprot_start(i.pdbScoreItem_uid,i.chain2) s2,
get_uniprot_end(i.pdbScoreItem_uid,i.chain2) e2,
get_homologs(p.uid,i.chain1) h1,
get_homologs(p.uid,i.chain2) h2,
i.id,
i.area,
i.isInfinite,
i.clusterId,
i.size1,
i.size2,
get_result(i.uid,"Geometry") geometry,
get_score(i.uid,"Entropy") crScore,
get_result(i.uid,"Entropy") cr,
get_score(i.uid,"Z-scores") csScore,
get_result(i.uid,"Z-scores") cs,
i.finalCallName final
from PdbScore as p inner join Interface as i
on i.pdbScoreItem_uid=p.uid inner join Job as j on length(j.jobId)=4 and j.uid=p.jobItem_uid;


drop table if exists nmr_xray_table;
create table nmr_xray_table as 
select x.pdbName pdbx,
x.id idx,
x.clusterId clusterIdx,
x.area areax,
x.chain1 chain1x,
x.chain2 chain2x,
n.pdbName pdbn,
n.id idn,
n.clusterId clusterIdn,
n.area arean,
n.chain1 chain1n,
n.chain2 chain2n,
(n.size1+n.size2) sizen,
(x.size1+x.size2) sizex,
n.final finaln,
x.final finalx 
from xray_table as x 
inner join nmr_table as n on 
((n.chain1=x.chain1 and n.chain2=x.chain2 and IsSameSegment(n.s1,n.e1,x.s1,x.e1,5) and IsSameSegment(n.s2,n.e2,x.s2,x.e2,5)) or 
(n.chain1=x.chain2 and n.chain2=x.chain1 and IsSameSegment(n.s1,n.e1,x.s2,x.e2,5) and IsSameSegment(n.s2,n.e2,x.s1,x.e1,5))) and 
IsSameArea(n.area,x.area,300)  
where x.h1>10 and x.h2>10;



drop view if exists nmr_bio2;
create view nmr_bio2 as 
select w.* from detailedView as w inner join benchmark.nmr_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;




drop view if exists dc_bio2;
create view dc_bio2 as 
select w.* from detailedView as w inner join benchmark.dc_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;
drop view if exists dc_xtal2;
create view dc_xtal2 as 
select w.* from detailedView as w inner join benchmark.dc_xtal as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid; 

drop view if exists po_bio2;
create view po_bio2 as 
select w.* from detailedView as w inner join benchmark.ponstingl_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;
drop view if exists po_xtal2;
create view po_xtal2 as 
select w.* from detailedView as w inner join benchmark.ponstingl_xtal as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid; 

drop view if exists many_bio2;
create view many_bio2 as
select * from detailedView where size1>10 and size2>10 and resolution<2.5 and area>1000 and area<2000 and chain1 is not NULL and chain2 is not NULL group by chain1,chain2,pdbName,clusterId union select * from nmr_bio2 where resolution<2.5;

drop view if exists many_xtal2;
create view many_xtal2 as
select * from detailedView where resolution<2.5 and isInfinite=1 and area>1000 and chain1 is not NULL and chain2 is not NULL group by chain1,chain2,pdbName,clusterId;





select x.pdbName pdbx, x.id idx, x.clusterId clusterIdx, x.area areax, x.chain1 chain1x, x.chain2 chain2x, n.pdbName pdbn, n.id idn, n.clusterId clusterIdn, n.area arean, n.chain1 chain1n, n.chain2 chain2n, (n.size1+n.size2) sizen, (x.size1+x.size2) sizex, n.final finaln, x.final finalx,IsSameSegment(n.s1,n.e1,x.s1,x.e1,5),IsSameSegment(n.s2,n.e2,x.s2,x.e2,5),IsSameSegment(n.s1,n.e1,x.s2,x.e2,5),IsSameSegment(n.s2,n.e2,x.s1,x.e1,5)  from xray_table as x  inner join nmr_table as n on  ((n.chain1=x.chain1 and n.chain2=x.chain2 and IsSameSegment(n.s1,n.e1,x.s1,x.e1,5) and IsSameSegment(n.s2,n.e2,x.s2,x.e2,5)) or  (n.chain1=x.chain2 and n.chain2=x.chain1 and IsSameSegment(n.s1,n.e1,x.s2,x.e2,5) and IsSameSegment(n.s2,n.e2,x.s1,x.e1,5))) and  IsSameArea(n.area,x.area,100)   where x.h1>10 and x.h2>10 and x.pdbName="3p2x" and n.pdbName="1ai0"\G




