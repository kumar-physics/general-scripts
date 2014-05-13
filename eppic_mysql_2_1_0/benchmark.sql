create table dunbrack_10_60(
pfam varchar(255),
pdbCode varchar(4),
interfaceId int(11),
chain1 varchar(4),
chain2 varchar(4),
dn_op1 varchar(255),
dn_op2 varchar(255),
dn_area double,
m int(11),
n int(11),
ratio double,
ep_op1 varchar(255),
ep_op2 varchar(255),
ep_op3 varchar(255),
ep_op4 varchar(255)
)

drop view eppic_dunbrack;
create view eppic_dunbrack as
select e.*,d.interfaceId du_id,d.chain1 dn_chain1,d.chain2 dn_chain2,d.dn_op1,d.dn_op2,d.ep_op1,d.ep_op2,d.ep_op3,d.ep_op4,d.dn_area,d.m,d.n,d.ratio,d.pfam from eppic_test_2_1_0.detailedTable as e inner join dunbrack_10_60 as d on d.pdbCode=e.pdbCode
where ((binary e.chain1 = d.chain1 and binary e.chain2 = d.chain2) or (binary e.chain1 = d.chain2 and binary e.chain2 = d.chain1)) and (
(d.ep_op1 = 'X,Y,Z' and d.ep_op2 = 'X,Y,Z' and e.operator = 'X,Y,Z' ) or
(d.ep_op1 = 'X,Y,Z' and d.ep_op2 != 'X,Y,Z' and e.operator != 'X,Y,Z' and (e.operator = d.ep_op1 or e.operator = d.ep_op2 or e.operator = d.ep_op3 or e.operator = d.ep_op4)) or
(d.ep_op1 != 'X,Y,Z' and d.ep_op2 = 'X,Y,Z' and e.operator != 'X,Y,Z' and (e.operator = d.ep_op1 or e.operator = d.ep_op2 or e.operator = d.ep_op3 or e.operator = d.ep_op4)) or
(d.ep_op1 != 'X,Y,Z' and d.ep_op2 != 'X,Y,Z' and e.operator != 'X,Y,Z' and (e.operator = d.ep_op1 or e.operator = d.ep_op2 or e.operator = d.ep_op3 or e.operator = d.ep_op4))) group by e.pdbCode,e.interfaceId;


create table dun_bio as select * from dunbrack.eppic_dun_table where ratio>0.8 and area > 400 and area < 2000 and resolution < 2.5 and rfreeValue < 0.3  group by pfam,c1_80,c2_80;


drop view if exists eppic_nmr_xray;
create view eppic_nmr_xray as 
select e.*,d.pdbn,d.idn,d.isscore,d.pvalue,d.zscore,d.rmsd,d.seqiden from eppic_test_2_1_0.detailedTable as e 
inner join nmr_xray as d on e.pdbCode=d.pdbx and e.interfaceId=d.idx;


create table nmr_bio as 
select * from nmr_xray.eppic_nmr_xray where area>400 and resolution < 2.5 and rfreeValue < 0.3 and seqiden>0.8 group by c1_80,c2_80;

drop table dun_bio;
create table dun_bio as select d.* from detailedTable as d inner join benchmark.dun_bio as b on 
b.pdbCode=d.pdbCode and b.interfaceId=d.interfaceId group by d.pdbcode,d.interfaceId;
drop table if exists nmr_bio;
create table nmr_bio as select d.* from detailedTable as d inner join benchmark.nmr_bio as b on 
b.pdbCode=d.pdbCode and b.interfaceId=d.interfaceId where d.area < 2000;


alter table dun_bio add column source varchar(255) default "dunbrack";


alter table nmr_bio add column source varchar(255) default "nmr";

drop table if exists many_bio;
create table many_bio as select * from dun_bio union all select * from nmr_bio;

drop table if exists many_xtal;
create table many_xtal as select * from detailedTable where resolution < 2.5 and rfreeValue < 0.3 and area > 630  and isInfinite=1 group by c1_80,c2_80; 
alter table many_xtal add column source varchar(255) default "infinite";

alter table nmr_bio add column source varchar(255) default "nmr";





drop table if exists dc_bio;
create table dc_bio as select d.* from detailedTable as d inner join benchmark.dc_bio as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;
alter table dc_bio add column source varchar(255) default "dc_bio";




drop table if exists dc_xtal;
create table dc_xtal as select d.* from detailedTable as d inner join benchmark.dc_xtal as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;
alter table dc_xtal add column source varchar(255) default "dc_xtal";





drop table if exists po_bio;
create table po_bio as select d.* from detailedTable as d inner join benchmark.ponstingl_bio as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;
alter table po_bio add column source varchar(255) default "po_bio";

drop table if exists po_xtal;
create table po_xtal as select d.* from detailedTable as d inner join benchmark.ponstingl_xtal as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;
alter table po_xtal add column source varchar(255) default "po_xtal";



DROP procedure IF EXISTS eppic_benchmark;
DELIMITER //
CREATE procedure eppic_benchmark(in dbname varchar(255),in method varchar(255)) 
BEGIN
declare tp,tn,fp,fn,p,n,cc int(11);
declare Sensitivity,Specificity,Accuracy,MCC double;
select 1 into cc;
if (dbname='dc' and method='cs') then
select count(*) into p  from dc_bio;
select count(*) into n  from dc_xtal;
select count(*) into tp  from dc_bio where cs='bio';
select count(*) into tn  from dc_xtal where cs='xtal';
select count(*) into fn  from dc_bio where cs='xtal';
select count(*) into fp  from dc_xtal where cs='bio';
elseif (dbname='dc' and method='cr') then
select count(*) into p  from dc_bio;
select count(*) into n  from dc_xtal;
select count(*) into tp  from dc_bio where cr='bio';
select count(*) into tn  from dc_xtal where cr='xtal';
select count(*) into fn  from dc_bio where cr='xtal';
select count(*) into fp  from dc_xtal where cr='bio';
elseif (dbname='po' and method='cr') then
select count(*) into p  from po_bio;
select count(*) into n  from po_xtal;
select count(*) into tp  from po_bio where cr='bio';
select count(*) into tn  from po_xtal where cr='xtal';
select count(*) into fn  from po_bio where cr='xtal';
select count(*) into fp  from po_xtal where cr='bio';
elseif (dbname='po' and method='cs') then
select count(*) into p  from po_bio;
select count(*) into n  from po_xtal;
select count(*) into tp  from po_bio where cs='bio';
select count(*) into tn  from po_xtal where cs='xtal';
select count(*) into fn  from po_bio where cs='xtal';
select count(*) into fp  from po_xtal where cs='bio';
elseif (dbname='many' and method='cs') then
select count(*) into p  from many_bio;
select count(*) into n  from many_xtal;
select count(*) into tp  from many_bio where cs='bio';
select count(*) into tn  from many_xtal where cs='xtal';
select count(*) into fn  from many_bio where cs='xtal';
select count(*) into fp  from many_xtal where cs='bio';
elseif (dbname='many' and method='cr') then
select count(*) into p  from many_bio;
select count(*) into n  from many_xtal;
select count(*) into tp  from many_bio where cr='bio';
select count(*) into tn  from many_xtal where cr='xtal';
select count(*) into fn  from many_bio where cr='xtal';
select count(*) into fp  from many_xtal where cr='bio';
else
select 0 into cc;
select 'Entered parameters are wrong';
end if;
if cc then
select tp+fn into p;
select fp+tn into n;
select tp/p into Sensitivity;
select tn/n into Specificity;
select (tp+tn)/(p+n) into Accuracy;
select ((tp*tn)-(fp*fn))/sqrt(p*n*(tp+fp)*(tn+fn)) into MCC;
select Sensitivity,Specificity,Accuracy,MCC;
end if;
END//
DELIMITER ;






