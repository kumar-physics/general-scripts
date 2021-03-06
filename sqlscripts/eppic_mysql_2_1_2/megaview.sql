
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
create function get_seq_clusterid(pdb varchar(4), chain varchar(4),cl varchar(25)) returns varchar(4)
begin
declare res varchar(4);
set res=(select repChain from ChainCluster where pdbCode=pdb and memberChains like binary CONCAT("%",chain,"%"));
if (cl==30) then 
set res2=(select c30 from SeqCluster where pdbCode=pdb and chain
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
inner join SeqCluster as s1 on s1.pdbCode=i.pdbCode and binary get_refchain(i.pdbCode,i.chain1) =s1.repChain
inner join SeqCluster as s2 on s2.pdbCode=i.pdbCode and binary get_refchain(i.pdbCode,i.chain2) =s2.repChain
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
get_clustercall(p.pdbCode,i.clusterId,'pqs') pqs
from PdbInfo as p inner join Interface as i on p.pdbCode=i.pdbCode
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