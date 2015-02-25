/*creating benchmark tables by combining EppicTable with benchmark database*/
drop table if exists dc_bio;
create table dc_bio as select d.* from EppicTable2 as d inner join benchmark.dc_bio as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;

drop table if exists dc_xtal;
create table dc_xtal as select d.* from EppicTable2 as d inner join benchmark.dc_xtal as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;

drop table if exists po_bio;
create table po_bio as select d.* from EppicTable2 as d inner join benchmark.ponstingl_bio as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;

drop table if exists po_xtal;
create table po_xtal as select d.* from EppicTable2 as d inner join benchmark.ponstingl_xtal as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;

drop table if exists dun_bio; 
create table dun_bio as select e.* from EppicTable2 as e inner join dunbrack.eppic_dun_table as d
on d.pdbCode=e.pdbCode and d.interfaceId=e.interfaceId where d.ratio>0.8 and e.area > 400 and e.area < 2000 and e.resolution < 2.5 and e.rfreeValue < 0.3  group by d.pfam,d.c1_80,d.c2_80;

drop table if exists nmr_bio;
create table nmr_bio as 
select e.* from EppicTable2 as e inner join nmr_xray.nmr_xray as x on x.pdbx=e.pdbCode and x.idx=e.interfaceId where e.area>400 and e.resolution < 2.5 and e.rfreeValue < 0.3 and x.seqiden>0.8 group by e.c1_80,e.c2_80;

drop table if exists many_xtal_table;
create table many_xtal_table as select * from EppicTable2 where resolution < 2.5 and rfreeValue < 0.3 and area > 400  and infinite=1 group by c1_80,c2_80; 





/*adding a column to know where it comes from */


alter table dc_bio add column source varchar(255) default "dc_bio";
alter table dc_xtal add column source varchar(255) default "dc_xtal";
alter table po_bio add column source varchar(255) default "po_bio";
alter table po_xtal add column source varchar(255) default "po_xtal";
alter table dun_bio add column source varchar(255) default "dunbrack";
alter table nmr_bio add column source varchar(255) default "nmr";
alter table many_xtal_table add column source varchar(255) default "infinite";

/*combining nmr and dunbrack datasets to get many bio dataset*/
drop table if exists many_bio_table;
create table many_bio_table as select * from dun_bio union all select * from nmr_bio;

/*multiple entries are removed*/

update many_bio_table set source='dunbrack,nmr' where pdbCode='1a7g' and interfaceId=1 and source='dunbrack';
delete from many_bio_table where pdbCode='1a7g' and interfaceId=1 and source='nmr';

update many_bio_table set source='dunbrack,nmr' where pdbCode='1a7w' and interfaceId=1 and source='dunbrack';
delete from many_bio_table where pdbCode='1a7w' and interfaceId=1 and source='nmr';

update many_bio_table set source='dunbrack,nmr' where pdbCode='1by9' and interfaceId=1 and source='dunbrack';
delete from many_bio_table where pdbCode='1by9' and interfaceId=1 and source='nmr';

update many_bio_table set source='dunbrack,nmr' where pdbCode='1cz8' and interfaceId=3 and source='dunbrack';
delete from many_bio_table where pdbCode='1cz8' and interfaceId=3 and source='nmr';

update many_bio_table set source='dunbrack,nmr' where pdbCode='1ecs' and interfaceId=1 and source='dunbrack';
delete from many_bio_table where pdbCode='1ecs' and interfaceId=1 and source='nmr';

update many_bio_table set source='dunbrack,nmr' where pdbCode='1j55' and interfaceId=1 and source='dunbrack';
delete from many_bio_table where pdbCode='1j55' and interfaceId=1 and source='nmr';

update many_bio_table set source='dunbrack,nmr' where pdbCode='1pdo' and interfaceId=1 and source='dunbrack';
delete from many_bio_table where pdbCode='1pdo' and interfaceId=1 and source='nmr';

update many_bio_table set source='dunbrack,nmr' where pdbCode='1udv' and interfaceId=1 and source='dunbrack';
delete from many_bio_table where pdbCode='1udv' and interfaceId=1 and source='nmr';

