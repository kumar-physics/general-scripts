



/*creating benchmark tables by combining detailedTable with benchmark database*/
drop table if exists dc_bio;
create table dc_bio as select d.* from detailedTable as d inner join benchmark.dc_bio as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;

drop table if exists dc_xtal;
create table dc_xtal as select d.* from detailedTable as d inner join benchmark.dc_xtal as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;

drop table if exists po_bio;
create table po_bio as select d.* from detailedTable as d inner join benchmark.ponstingl_bio as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;

drop table if exists po_xtal;
create table po_xtal as select d.* from detailedTable as d inner join benchmark.ponstingl_xtal as b on 
b.pdb=d.pdbCode and b.interfaceid=d.interfaceId;

drop table if exists dun_bio; 
create table dun_bio as select * from dunbrack.eppic_dun_table where ratio>0.8 and area > 400 and area < 2000 and resolution < 2.5 and rfreeValue < 0.3  group by pfam,c1_80,c2_80;

drop table if exists nmr_bio;
create table nmr_bio as 
select * from nmr_xray.eppic_nmr_xray where area>400 and resolution < 2.5 and rfreeValue < 0.3 and seqiden>0.8 group by c1_80,c2_80;

drop table if exists many_xtal_table;
create table many_xtal_table as select * from detailedTable where resolution < 2.5 and rfreeValue < 0.3 and area > 400  and infinite=1 group by c1_80,c2_80; 




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


/*area filters used to match the size of the data sets*/
drop view if exists many_bio;
create view many_bio as select * from many_bio_table where area>500;

drop view if exists many_xtal;
create view many_xtal as select * from many_xtal_table where area>600 and area < 2000;


/* at the end we have 3 benchmarking datasets namely dc_<bio,xtal> po_<bio,xtal> many_<bio,xtal>*/
