select
crystalSystem, 
pdbCode,
spaceGroup,
cellA,
cellB,
cellC,
cellAlpha,
cellBeta,
cellGamma,
abs(cellA-cellB) AB,
abs(cellA-cellC) AC,
abs(cellB-cellC) BC
from CrystalSystem where 
(spaceGroup in ("P 2","P 21","C 2") 
	and (cellAlpha!=90 or cellGamma!=90)) or
(spaceGroup in ("P 2 2 2","P 2 2 21","P 21 21 2","P 21 21 21","C 2 2 21","C 2 2 2","F 2 2 2","I 2 2 2","P 21 21 21") 
	and (cellAlpha!=90 or cellBeta!=90 or cellGamma!=90)) or
(spaceGroup in ("P 4","P 41","P 42","P 43","I 4","I 41","P 4 2 2","P 4 21 2","P 41 21 2","P 42 2 2","P 42 21 2","P 43 2 2","P 43 21 2","I 4 2 2","I 41 2 2") 
	and (cellA!=cellB or cellAlpha!=90 or cellBeta!=90 or cellGamma!=90)) or
(spaceGroup in ("P 3","P 31","P 32","P 3 1 2","P 3 2 1","P 31 1 2","P 31 2 1","P 32 1 2","P 32 2 1","R 32","P 6","P 61","P 65","P 63","P 62","P 64","P 6 2 2","P 61 2 2","P 65 2 2","P 62 2 2","P 64 2 2","P 63 2 2") 
	and (cellA!=cellB or cellAlpha!=90 or cellBeta!=90 or cellGamma!=120)) or
(spaceGroup in ("P 2 3","F 2 3","I 2 3","P 21 3","I 21 3","P 4 3 2","P 42 3 2","F 4 3 2","F 41 3 2","I 4 3 2","P 43 3 2","I 41 3 2") 
	and (cellA!=cellB or cellA!=cellC or cellB!=cellC or cellAlpha!=90 or cellBeta!=90 or cellGamma!=90))
order by crystalSystem ;




create table CrystalSystem as 
select 
pdbCode,
spaceGroup,
cellA,
cellB,
cellC,
cellAlpha,
cellBeta,
cellGamma
from PdbInfo;

alter table CrystalSystem add crystalSystem varchar(255)  default "none";

update CrystalSystem set crystalSystem="Triclinic" where spaceGroup in ("P 1"); 
update CrystalSystem set crystalSystem="Monoclinic" where spaceGroup in ("P 2","P 21","C 2");
update CrystalSystem set crystalSystem="Orthorhombic" where spaceGroup in ("P 2 2 2","P 2 2 21","P 21 21 2","P 21 21 21","C 2 2 21","C 2 2 2","F 2 2 2","I 2 2 2","P 21 21 21");

update CrystalSystem set crystalSystem="Tetragonal" where spaceGroup in ("P 4","P 41","P 42","P 43","I 4","I 41","P 4 2 2","P 4 21 2","P 41 21 2","P 42 2 2","P 42 21 2","P 43 2 2","P 43 21 2","I 4 2 2","I 41 2 2");

update CrystalSystem set crystalSystem="Trigonal-hexagonal" where spaceGroup in ("P 3","P 31","P 32","R 3","P 3 1 2","P 3 2 1","P 31 1 2","P 31 2 1","P 32 1 2","P 32 2 1","R 32","P 6","P 61","P 65","P 63","P 62","P 64","P 6 2 2","P 61 2 2","P 65 2 2","P 62 2 2","P 64 2 2","P 63 2 2");
update CrystalSystem set crystalSystem="Cubic" where spaceGroup in ("P 2 3","F 2 3","I 2 3","P 21 3","I 21 3","P 4 3 2","P 42 3 2","F 4 3 2","F 41 3 2","I 4 3 2","P 43 3 2","I 41 3 2");


