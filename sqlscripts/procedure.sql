drop procedure if exists SearchCrystalForm;
DELIMITER $$
create procedure SearchCrystalForm(IN clsid int(11))
BLOCK1: begin
declare uid1 int(11);
declare pdb1,chain1 varchar(255);
declare finished boolean default false;
declare cur1 cursor for select chainCluster_uid  from SeqCluster where c95=clsid order by uid;
declare continue handler for not found set finished = true;
open cur1;
LOOP1: loop
fetch cur1 into uid1;
if finished then
close cur1;
leave LOOP1;
end if;
BLOCK2: begin
declare uid2 int(11);
declare pdb2,chain2 varchar(255);
declare finished2 boolean default false;
declare cur2 cursor for select chainCluster_uid from SeqCluster where c95=clsid and uid>uid1 order by uid;
declare continue handler for not found set finished2 = true;
open cur2;
LOOP2: loop
fetch cur2 into uid2;
if finished2 then
close cur2;
leave LOOP2;
end if;
if (IsSameCrystalForm(uid1,uid2,1)=0) then
select p.pdbCode,i.interfaceId from InterfaceCluster as p inner join Interface as i on p.uid=i.interfaceCluster_uid inner join ChainCluster as c on c.pdbInfo_uid=p.pdbInfo_uid where i.area>300 and c.uid=uid1;
select p.pdbCode,i.interfaceId from InterfaceCluster as p inner join Interface as i on p.uid=i.interfaceCluster_uid inner join ChainCluster as c on c.pdbInfo_uid=p.pdbInfo_uid where i.area>300 and c.uid=uid2;
end if;
end loop LOOP2;
end BLOCK2;
end loop LOOP1;
end BLOCK1;$$
DELIMITER ;


select pdbCode,repChain into pdb1,chain1 from ChainCluster where uid=uid1;
select pdbCode,repChain into pdb2,chain2 from ChainCluster where uid=uid2;
select uid1,pdb1,chain1,uid2,pdb2,chain2,IsSameCrystalForm(uid1,uid2,1) cf;
