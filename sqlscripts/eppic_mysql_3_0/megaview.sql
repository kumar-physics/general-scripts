
/*First index the tables*/

create index pdbidx on Assembly(pdbCode,method);
create index pdbidx on ChainCluster(pdbCode,refUniProtId);
create index pdbidx on Interface(pdbCode);
create index pdbidx on InterfaceCluster(pdbCode);
create index pdbidx on InterfaceClusterScore(pdbCode,method);
create index pdbidx on InterfaceScore(pdbCode,method);
create index pdbidx on PdbInfo(pdbCode,spaceGroup);
create index pdbidx on SeqCluster(pdbCode);

/*Functions to create view*/

drop function if exists get_score;
delimiter $$
create function get_score(pdb varchar(4), iid INT, met varchar(255),s INT) returns double
begin
declare res double;
if (s=1) then
set res=(select score1 from InterfaceScore where pdbCode=pdb and interfaceId=iid and method=met);
elseif (s=2) then
set res=(select score2 from InterfaceScore where pdbCode=pdb and interfaceId=iid and method=met);
else
set res=(select score from InterfaceScore where pdbCode=pdb and interfaceId=iid and method=met);
end if;
return res;
end $$
delimiter ;







drop function if exists get_call;
delimiter $$
create function get_call(pdb varchar(4), iid INT, met varchar(255)) returns varchar(255)
begin
declare res varchar(255);
set res=(select callName from InterfaceScore where pdbCode=pdb and interfaceId=iid and method=met);
return res;
end $$
delimiter ;


drop function if exists get_clustercall;
delimiter $$
create function get_clustercall(pdb varchar(4), iid INT, met varchar(255)) returns varchar(255)
begin
declare res varchar(255);
set res=(select callName from InterfaceClusterScore where pdbCode=pdb and clusterId=iid and method=met);
return res;
end $$
delimiter ;







drop function if exists get_numhomologs;
delimiter $$
create function get_numhomologs(pdb varchar(4), chain varchar(4)) returns INT
begin
declare res INT;
set res=(select numHomologs from ChainCluster where pdbCode=pdb and memberChains like binary CONCAT("%",chain,"%"));
return res;
end $$
delimiter ;

drop function if exists get_firsttaxon;
delimiter $$
create function get_firsttaxon(pdb varchar(4), chain varchar(4)) returns varchar(255)
begin
declare res varchar(255);
set res=(select firstTaxon from ChainCluster where pdbCode=pdb and memberChains like binary CONCAT("%",chain,"%"));
return res;
end $$
delimiter ;

 
drop function if exists get_lasttaxon;
delimiter $$
create function get_lasttaxon(pdb varchar(4), chain varchar(4)) returns varchar(255)
begin
declare res varchar(255);
set res=(select lastTaxon from ChainCluster where pdbCode=pdb and memberChains like binary CONCAT("%",chain,"%"));
return res;
end $$
delimiter ;


drop function if exists get_refuniprotid;
delimiter $$
create function get_refuniprotid(pdb varchar(4), chain varchar(4)) returns varchar(255)
begin
declare res varchar(255);
set res=(select refUniProtId from ChainCluster where pdbCode=pdb and memberChains like binary CONCAT("%",chain,"%"));
return res;
end $$
delimiter ;

drop function if exists get_refchain;
delimiter $$
create function get_refchain(pdb varchar(4), chain varchar(4)) returns varchar(4)
begin
declare res varchar(4);
set res=(select repChain from ChainCluster where pdbCode=pdb and memberChains like binary CONCAT("%",chain,"%"));
return res;
end $$
delimiter ;

drop function if exists get_seq_clusterid;
delimiter $$
create function get_seq_clusterid(pdb varchar(4), chain varchar(4),cl varchar(25)) returns INT
begin
declare res varchar(4);
declare res2 int(11);
set res=(select repChain from ChainCluster where pdbCode=pdb and memberChains like binary CONCAT("%",chain,"%"));
if (cl=30) then 
set res2=(select c30 from SeqCluster where pdbCode=pdb and binary repChain=res);
elseif (cl=40) then
set res2=(select c40 from SeqCluster where pdbCode=pdb and binary repChain=res);
elseif (cl=50) then
set res2=(select c50 from SeqCluster where pdbCode=pdb and binary repChain=res);
elseif (cl=60) then
set res2=(select c60 from SeqCluster where pdbCode=pdb and binary repChain=res);
elseif (cl=70) then
set res2=(select c70 from SeqCluster where pdbCode=pdb and binary repChain=res);
elseif (cl=80) then
set res2=(select c80 from SeqCluster where pdbCode=pdb and binary repChain=res);
elseif (cl=90) then
set res2=(select c90 from SeqCluster where pdbCode=pdb and binary repChain=res);
elseif (cl=95) then
set res2=(select c95 from SeqCluster where pdbCode=pdb and binary repChain=res);
elseif (cl=100) then
set res2=(select c100 from SeqCluster where pdbCode=pdb and binary repChain=res);
else
set res2=NULL;
end if;
return res2;
end $$
delimiter ;

drop function if exists get_assembly_mmSize;
delimiter $$
create function get_assembly_mmSize(pdb varchar(4),m varchar(255)) returns int(11)
begin
declare res int(11);
set res=(select mmSize from Assembly where pdbCode=pdb and method=m);
return res;
end $$
delimiter ;

drop function if exists get_assembly_stoichiometry;
delimiter $$
create function get_assembly_stoichiometry(pdb varchar(4),m varchar(255)) returns varchar(255)
begin
declare res varchar(255);
set res=(select stoichiometry from Assembly where pdbCode=pdb and method=m);
return res;
end $$
delimiter ;


drop function if exists get_assembly_pseudoStoichiometry;
delimiter $$
create function get_assembly_pseudoStoichiometry(pdb varchar(4),m varchar(255)) returns varchar(255)
begin
declare res varchar(255);
set res=(select pseudoStoichiometry from Assembly where pdbCode=pdb and method=m);
return res;
end $$
delimiter ;

drop function if exists get_assembly_pseudoSymmetry;
delimiter $$
create function get_assembly_pseudoSymmetry(pdb varchar(4),m varchar(255)) returns varchar(255)
begin
declare res varchar(255);
set res=(select pseudoSymmetry from Assembly where pdbCode=pdb and method=m);
return res;
end $$
delimiter ;


drop function if exists get_assembly_symmetry;
delimiter $$
create function get_assembly_symmetry(pdb varchar(4),m varchar(255)) returns varchar(255)
begin
declare res varchar(255);
set res=(select symmetry from Assembly where pdbCode=pdb and method=m);
return res;
end $$
delimiter ;

drop function if exists get_assembly_stoichiometry;
delimiter $$
create function get_assembly_stoichiometry(pdb varchar(4),m varchar(255)) returns varchar(255)
begin
declare res varchar(255);
set res=(select stoichiometry from Assembly where pdbCode=pdb and method=m);
return res;
end $$
delimiter ;


drop view EppicView2;
create view EppicView2 as
select 
p.pdbCode,
p.expMethod,
p.numChainClusters,
p.spaceGroup,
p.title,
p.resolution,
p.rfreeValue,
i.interfaceId,
i.clusterId,
i.chain1,
i.chain2,
get_numhomologs(p.pdbCode,i.chain1) h1,
get_numhomologs(p.pdbCode,i.chain2) h2,
get_refuniprotid(p.pdbCode,i.chain1) uniprot1,
get_refuniprotid(p.pdbCode,i.chain2) uniprot2,
get_firsttaxon(p.pdbCode,i.chain1) ftaxon1,
get_firsttaxon(p.pdbCode,i.chain2) ftaxon2,
get_lasttaxon(p.pdbCode,i.chain1) ltaxon1,
get_lasttaxon(p.pdbCode,i.chain2) ltaxon2,
i.infinite,
i.operator,
i.operatorType,
i.area,
get_score(p.pdbCode,i.interfaceId,'eppic-gm',1) gm1,
get_score(p.pdbCode,i.interfaceId,'eppic-gm',2) gm2,
get_score(p.pdbCode,i.interfaceId,'eppic-gm',0) gm,
get_score(p.pdbCode,i.interfaceId,'eppic-cr',1) cr1,
get_score(p.pdbCode,i.interfaceId,'eppic-cr',2) cr2,
get_score(p.pdbCode,i.interfaceId,'eppic-cr',0) cr,
get_score(p.pdbCode,i.interfaceId,'eppic-cs',1) cs1,
get_score(p.pdbCode,i.interfaceId,'eppic-cs',2) cs2,
get_score(p.pdbCode,i.interfaceId,'eppic-cs',0) cs,
get_call(p.pdbCode,i.interfaceId,'eppic-gm') gmcall,
get_call(p.pdbCode,i.interfaceId,'eppic-cr') crcall,
get_call(p.pdbCode,i.interfaceId,'eppic-cs') cscall,
get_call(p.pdbCode,i.interfaceId,'eppic') eppic,
get_clustercall(p.pdbCode,i.clusterId,'pisa') pisa,
get_clustercall(p.pdbCode,i.clusterId,'authors') authors,
get_clustercall(p.pdbCode,i.clusterId,'pqs') pqs,
s1.c30 c1_30,s1.c40 c1_40,s1.c50 c1_50,s1.c60 c1_60,s1.c70 c1_70,s1.c80 c1_80,s1.c90 c1_90,s1.c95 c1_95,s1.c100 c1_100,
s2.c30 c2_30,s2.c40 c2_40,s2.c50 c2_50,s2.c60 c2_60,s2.c70 c2_70,s2.c80 c2_80,s2.c90 c2_90,s2.c95 c2_95,s2.c100 c2_100
from PdbInfo as p inner join Interface as i on p.pdbCode=i.pdbCode
inner join SeqCluster as s1 on binary s1.pdbCode= binary i.pdbCode and binary get_refchain(i.pdbCode,i.chain1) =binary s1.repChain
inner join SeqCluster as s2 on binary s2.pdbCode=binary i.pdbCode and binary get_refchain(i.pdbCode,i.chain2) =binary s2.repChain
where p.pdbCode is not NULL;


drop view EppicView;
create view EppicView as
select 
p.pdbCode,
p.expMethod,
p.numChainClusters,
p.spaceGroup,
p.title,
p.resolution,
p.rfreeValue,
#if(p.ncsOpsPresent,'yes','no') ncsOpsPresent,
i.interfaceId,
i.clusterId,
i.chain1,
i.chain2,
get_numhomologs(p.pdbCode,i.chain1) h1,
get_numhomologs(p.pdbCode,i.chain2) h2,
get_refuniprotid(p.pdbCode,i.chain1) uniprot1,
get_refuniprotid(p.pdbCode,i.chain2) uniprot2,
get_firsttaxon(p.pdbCode,i.chain1) ftaxon1,
get_firsttaxon(p.pdbCode,i.chain2) ftaxon2,
get_lasttaxon(p.pdbCode,i.chain1) ltaxon1,
get_lasttaxon(p.pdbCode,i.chain2) ltaxon2,
if(i.infinite,'yes','no') infinite,
#if(i.prot1,'yes','no') prot1,
#if(i.prot2,'yes','no') prot2,
i.operator,
i.operatorType,
if (i.isologous,'yes','no') isologous,
i.area,
get_score(p.pdbCode,i.interfaceId,'eppic-gm',1) gm1,
get_score(p.pdbCode,i.interfaceId,'eppic-gm',2) gm2,
get_score(p.pdbCode,i.interfaceId,'eppic-gm',0) gm,
get_score(p.pdbCode,i.interfaceId,'eppic-cr',1) cr1,
get_score(p.pdbCode,i.interfaceId,'eppic-cr',2) cr2,
get_score(p.pdbCode,i.interfaceId,'eppic-cr',0) cr,
get_score(p.pdbCode,i.interfaceId,'eppic-cs',1) cs1,
get_score(p.pdbCode,i.interfaceId,'eppic-cs',2) cs2,
get_score(p.pdbCode,i.interfaceId,'eppic-cs',0) cs,
get_call(p.pdbCode,i.interfaceId,'eppic-gm') gmcall,
get_call(p.pdbCode,i.interfaceId,'eppic-cr') crcall,
get_call(p.pdbCode,i.interfaceId,'eppic-cs') cscall,
get_call(p.pdbCode,i.interfaceId,'eppic') eppic,
get_clustercall(p.pdbCode,i.clusterId,'pdb1') pdbcall,
get_assembly_mmSize(p.pdbCode,'pdb1') mmSize,
from PdbInfo as p inner join Interface as i on binary p.pdbCode= binary i.pdbCode
where p.pdbCode is not NULL;


drop view EppicView2;
create view EppicView2 as
select 
p.pdbCode,
p.expMethod,
p.numChainClusters,
p.spaceGroup,
p.title,
p.resolution,
p.rfreeValue,
i.interfaceId,
i.clusterId,
i.chain1,
i.chain2,
get_numhomologs(p.pdbCode,i.chain1) h1,
get_numhomologs(p.pdbCode,i.chain2) h2,
get_refuniprotid(p.pdbCode,i.chain1) uniprot1,
get_refuniprotid(p.pdbCode,i.chain2) uniprot2,
get_firsttaxon(p.pdbCode,i.chain1) ftaxon1,
get_firsttaxon(p.pdbCode,i.chain2) ftaxon2,
get_lasttaxon(p.pdbCode,i.chain1) ltaxon1,
get_lasttaxon(p.pdbCode,i.chain2) ltaxon2,
if(i.infinite,'yes','no') infinite,
i.operator,
i.operatorType,
if (i.isologous,'yes','no') isologous,
i.area,
get_score(p.pdbCode,i.interfaceId,'eppic-gm',1) gm1,
get_score(p.pdbCode,i.interfaceId,'eppic-gm',2) gm2,
get_score(p.pdbCode,i.interfaceId,'eppic-gm',0) gm,
get_score(p.pdbCode,i.interfaceId,'eppic-cr',1) cr1,
get_score(p.pdbCode,i.interfaceId,'eppic-cr',2) cr2,
get_score(p.pdbCode,i.interfaceId,'eppic-cr',0) cr,
get_score(p.pdbCode,i.interfaceId,'eppic-cs',1) cs1,
get_score(p.pdbCode,i.interfaceId,'eppic-cs',2) cs2,
get_score(p.pdbCode,i.interfaceId,'eppic-cs',0) cs,
get_call(p.pdbCode,i.interfaceId,'eppic-gm') gmcall,
get_call(p.pdbCode,i.interfaceId,'eppic-cr') crcall,
get_call(p.pdbCode,i.interfaceId,'eppic-cs') cscall,
get_call(p.pdbCode,i.interfaceId,'eppic') eppic,
get_clustercall(p.pdbCode,i.clusterId,'pdb1') pdbcall,
get_assembly_mmSize(p.pdbCode,'pdb1') mmSize,
get_seq_clusterid(p.pdbCode,i.chain1,80) c1_80,
get_seq_clusterid(p.pdbCode,i.chain1,90) c1_90,
get_seq_clusterid(p.pdbCode,i.chain1,95) c1_95,
get_seq_clusterid(p.pdbCode,i.chain1,100) c1_100,
get_seq_clusterid(p.pdbCode,i.chain2,80) c2_80,
get_seq_clusterid(p.pdbCode,i.chain2,90) c2_90,
get_seq_clusterid(p.pdbCode,i.chain2,95) c2_95,
get_seq_clusterid(p.pdbCode,i.chain2,100) c2_100
from PdbInfo as p inner join Interface as i on binary p.pdbCode= binary i.pdbCode
where p.pdbCode is not NULL;



select 
p.pdbCode,
get_numhomologs(p.pdbCode,i.chain1) h1
from PdbInfo as p inner join Interface as i on p.pdbCode=i.pdbCode
where p.pdbCode is not NULL;


 def getHistory(self):
        self.connectDatabase()
        for i in range(1980,2016):
            iface=atof(self.runQuery("select count(*) from PdbInfo as p inner join Interface as i on i.pdbCode=p.pdbCode where p.releaseDate<'%s-12-31' and p.expMethod='X-RAY DIFFRACTION'"%(i))[0][0])
            enty=atof(self.runQuery("select count(*) from PdbInfo where releaseDate<'%d-12-31' and expMethod='X-RAY DIFFRACTION'"%(i))[0][0])
            iface1=atof(self.runQuery("select count(*) from PdbInfo as p inner join Interface as i on i.pdbCode=p.pdbCode where p.releaseDate<'%s-12-31' and p.releaseDate>'%d-12-31' and p.expMethod='X-RAY DIFFRACTION'"%(i,i-1))[0][0])
            enty1=atof(self.runQuery("select count(*) from PdbInfo where releaseDate<'%d-12-31' and releaseDate>'%d-12-31' and expMethod='X-RAY DIFFRACTION'"%(i,i-1))[0][0])
            print i,iface,enty,iface/enty,iface1,enty1,iface1/enty1



| Assembly                |
| ChainCluster            |
| Contact                 |
| DataDownloadTracking    |
| EppicView               |
| EppicView2              |
| Homolog                 |
| IPAllowed               |
| IPForbidden             |
| Interface               |
| InterfaceCluster        |
| InterfaceClusterScore   |
| InterfaceScore          |
| InterfaceWarning        |
| Job                     |
| PdbInfo                 |
| Residue                 |
| RunParameters           |
| SeqCluster              |
| UniProtRefWarning       |
| UserSession             |
| UserSessionJob          |
+-------------------------+


ALTER TABLE Assembly CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE ChainCluster CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE Contact CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE DataDownloadTracking CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE Interface CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE nterfaceCluster CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE InterfaceClusterScore CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE InterfaceWarning CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE InterfaceScore CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE Job CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE PdbInfo  CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE SeqCluster CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;

