


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

DROP FUNCTION IF EXISTS get_side_score;
DELIMITER $$
CREATE FUNCTION get_side_score(interfaceid INT,met VARCHAR(255),side INT) RETURNS DOUBLE
BEGIN
DECLARE res DOUBLE;
if (side=1) then
SET res=(SELECT unweightedRatio1Scores FROM InterfaceScore WHERE interfaceItem_uid=interfaceid and method like met);
else
SET res=(SELECT unweightedRatio2Scores FROM InterfaceScore WHERE interfaceItem_uid=interfaceid and method like met);
end if;
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
p.spaceGroup,
i.operator,
i.operatorType,
i.clusterId,
i.size1,
i.size2,
get_result(i.uid,"Geometry") geometry,
get_side_score(i.uid,"Entropy",1) cr1,
get_side_score(i.uid,"Entropy",2) cr2,
get_score(i.uid,"Entropy") crScore,
get_result(i.uid,"Entropy") cr,
get_side_score(i.uid,"Z-scores",1) cs1,
get_side_score(i.uid,"Z-scores",2) cs2,
get_score(i.uid,"Z-scores") csScore,
get_result(i.uid,"Z-scores") cs,
i.finalCallName final,
get_final_call(p.uid) overall
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
select * from detailedView where size1>10 and size2>10 and resolution<2.5 and area>1000 and area<2000 and chain1 is not NULL and chain2 is not NULL  union select * from nmr_bio2 where resolution<2.5;

drop view if exists many_xtal2;
create view many_xtal2 as
select * from detailedView where resolution<2.5 and isInfinite=1 and area>1000 and chain1 is not NULL and chain2 is not NULL;





select x.pdbName pdbx, x.id idx, x.clusterId clusterIdx, x.area areax, x.chain1 chain1x, x.chain2 chain2x, n.pdbName pdbn, n.id idn, n.clusterId clusterIdn, n.area arean, n.chain1 chain1n, n.chain2 chain2n, (n.size1+n.size2) sizen, (x.size1+x.size2) sizex, n.final finaln, x.final finalx,IsSameSegment(n.s1,n.e1,x.s1,x.e1,5),IsSameSegment(n.s2,n.e2,x.s2,x.e2,5),IsSameSegment(n.s1,n.e1,x.s2,x.e2,5),IsSameSegment(n.s2,n.e2,x.s1,x.e1,5)  from xray_table as x  inner join nmr_table as n on  ((n.chain1=x.chain1 and n.chain2=x.chain2 and IsSameSegment(n.s1,n.e1,x.s1,x.e1,5) and IsSameSegment(n.s2,n.e2,x.s2,x.e2,5)) or  (n.chain1=x.chain2 and n.chain2=x.chain1 and IsSameSegment(n.s1,n.e1,x.s2,x.e2,5) and IsSameSegment(n.s2,n.e2,x.s1,x.e1,5))) and  IsSameArea(n.area,x.area,100)   where x.h1>10 and x.h2>10 and x.pdbName="3p2x" and n.pdbName="1ai0"\G





drop table if exists xtal_xtal_table;
create table xtal_xtal_table as 
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
from many_xtal2 as x 
inner join many_xtal2 as n on 
((n.chain1=x.chain1 and n.chain2=x.chain2 and IsSameSegment(n.s1,n.e1,x.s1,x.e1,5) and IsSameSegment(n.s2,n.e2,x.s2,x.e2,5)) or 
(n.chain1=x.chain2 and n.chain2=x.chain1 and IsSameSegment(n.s1,n.e1,x.s2,x.e2,5) and IsSameSegment(n.s2,n.e2,x.s1,x.e1,5))) and 
IsSameArea(n.area,x.area,300)  and not (x.pdbName=n.pdbName and x.id=n.id);



drop table if exists bio_bio_table;
create table bio_bio_table as 
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
from many_bio2 as x 
inner join many_bio2 as n on 
((n.chain1=x.chain1 and n.chain2=x.chain2 and IsSameSegment(n.s1,n.e1,x.s1,x.e1,5) and IsSameSegment(n.s2,n.e2,x.s2,x.e2,5)) or 
(n.chain1=x.chain2 and n.chain2=x.chain1 and IsSameSegment(n.s1,n.e1,x.s2,x.e2,5) and IsSameSegment(n.s2,n.e2,x.s1,x.e1,5))) and 
IsSameArea(n.area,x.area,300)  and not (x.pdbName=n.pdbName and x.id=n.id);


drop view if exists dc_bio3;
create view dc_bio3 as 
select w.* from detailedView as w inner join benchmark.dc_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;
drop view if exists dc_xtal3;
create view dc_xtal3 as 
select w.* from detailedView as w inner join benchmark.dc_xtal as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid; 

drop view if exists po_bio3;
create view po_bio3 as 
select w.* from detailedView as w inner join benchmark.ponstingl_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;
drop view if exists po_xtal3;
create view po_xtal3 as 
select w.* from detailedView as w inner join benchmark.ponstingl_xtal as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid; 

drop view if exists many_bio3;
create view many_bio3 as
select w.* from detailedView as w inner join benchmark.many_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;

drop view if exists many_xtal3;
create view many_xtal3 as
select w.* from detailedView as w inner join benchmark.many_xtal as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid; 







drop view if exists dc_bio4;
create view dc_bio4 as 
select w.* from detailedView as w inner join benchmark.dc_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;
drop view if exists dc_xtal4;
create view dc_xtal4 as 
select w.* from detailedView as w inner join benchmark.dc_xtal as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid; 

drop view if exists po_bio4;
create view po_bio4 as 
select w.* from detailedView as w inner join benchmark.ponstingl_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;
drop view if exists po_xtal4;
create view po_xtal4 as 
select w.* from detailedView as w inner join benchmark.ponstingl_xtal as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid; 
drop view if exists many_bio4;
create view many_bio4 as
select w.* from detailedView as w inner join benchmark.many_bio as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid;

drop view if exists many_xtal4;
create view many_xtal4 as
select w.* from detailedView as w inner join benchmark.many_xtal as dc on w.pdbName=dc.pdb and w.id=dc.interfaceid; 




drop function if exists IsSameChain;
DELIMITER $$
create function IsSameChain(c1 varchar(255),s1 INT,e1 INT,c2 varchar(255),s2 INT,e2 INT,n INT) returns bool
BEGIN
declare res bool;
if ((c1 like c2) and IsSameSegment(s1,e1,s2,e2,n)) then
set res=1;
else
set res=0;
end if;
return res;
end $$
DELIMITER ;

drop function if exists CheckChains;
DELIMITER $$
create function CheckChains(xa varchar(255),xas INT,xae INT,xb varchar(255),xbs INT,xbe INT,na varchar(255),nas INT,nae INT,nb varchar(255),nbs INT,nbe INT, n INT) returns bool
BEGIN
declare res bool;
if ((IsSameChain(xa,xas,xae,na,nas,nae,n) and IsSameChain(xb,xbs,xbe,nb,nbs,nbe,n)) or (IsSameChain(xa,xas,xae,nb,nbs,nbe,n) and IsSameChain(xb,xbs,xbe,na,nas,nae,n))) then
set res=1;
else
set res=0;
end if;
return res;
end $$
DELIMITER ;


create table nmrTable as select * from detailedTable where expMethod like "SOLUTION NMR";

create table xrayTable as select * from detailedTable where expMethod like "X-RAY DIFFRACTION" and resolution<2.5;

create view nmr_xray as select 
n.pdbName nmr_pdb,
n.id nmr_id,
n.area nmr_area,
x.pdbName xray_pdb,
x.id xray_id,
x.area xray_area,
x.clusterId
from xrayTable as x
inner join nmrTable as n on CheckChains(n.chain1,n.s1,n.e1,n.chain2,n.s2,n.e2,x.chain1,x.s1,x.e1,x.chain2,x.s2,x.e2,5) and IsSameArea(n.area,x.area,((n.area+x.area)/2)*0.25);



create view nmr_bio as select d.* from detailedTable as d inner join benchmark.nmr_xray as n on n.pdbx=d.pdbName and n.idx=d.id and n.seqiden>0.9 and n.rmsd<3.0;


create view dun_bio as select d.* from detailedTable as d inner join benchmark.dunbr_old as n on  n.pdb=d.pdbName and n.interfaceid=d.id;


drop view if exists many_bio;
create view many_bio as select * from dun_bio where area<2500 and resolution<2.5 group by chain1,s1,e1,chain2,s2,e2 union all select * from nmr_bio where area<2500 and resolution<2.5 group by chain1,s1,e1,chain2,s2,e2;



select * from detailedTable where isInfinite=T and area>400 and resolution<2.5;

create view many_xtal as select * from detailedTable where isInfinite=True and area>1000 and resolution<2.5 group by pdbName,clusterId;


create view dc_bio as select * from detailedTable as d inner join benchmark.dc_bio as n on  n.pdb=d.pdbName and n.interfaceid=d.id;
create view dc_xtal as select * from detailedTable as d inner join benchmark.dc_xtal as n on  n.pdb=d.pdbName and n.interfaceid=d.id;
create view po_bio as select * from detailedTable as d inner join benchmark.ponstingl_bio as n on  n.pdb=d.pdbName and n.interfaceid=d.id;
create view po_xtal as select * from detailedTable as d inner join benchmark.ponstingl_xtal as n on  n.pdb=d.pdbName and n.interfaceid=d.id;




create view SeqCluster2 as select 
s.*,


drop view if exists dun_new;
create view dun_new as select 
d.*,s1.c100 c1_100,s1.c95 c1_95,s1.c90 c1_90,s1.c80 c1_80,s1.c70 c1_70,
s2.c100 c2_100,s2.c95 c2_95,s2.c90 c2_90,s2.c80 c2_80,s2.c70 c2_70 from dunbrack_new as d 
inner join eppic_test_2_1_0.Interface as i on i.pdbCode=d.pdb and i.interfaceId=d.id_eppic 
inner join eppic_test_2_1_0.ChainCluster as c1 on c1.pdbCode=i.pdbCode and ( c1.repChain like concat("%",i.chain1,"%") or c1.memberChains like concat("%",i.chain1,"%"))
inner join eppic_test_2_1_0.SeqCluster as s1 on s1.pdbCode=i.pdbCode and s1.repChain=c1.repchain
inner join eppic_test_2_1_0.ChainCluster as c2 on c2.pdbCode=i.pdbCode and ( c2.repChain like concat("%",i.chain2,"%") or  c2.memberChains like concat("%",i.chain2,"%") )
inner join eppic_test_2_1_0.SeqCluster as s2 on s2.pdbCode=i.pdbCode and s2.repChain=c1.repchain;


select i.* from eppic_test_2_1_0.Interface as i 
inner join eppic_test_2_1_0.ChainCluster as c1 on c1.pdbCode=i.pdbCode and (concat("%",i.chain1,"%") like c1.repChain or concat("%",i.chain1,"%") like c1.memberChains) limit 10;




