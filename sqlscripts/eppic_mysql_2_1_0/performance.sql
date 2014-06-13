
/*to get the performance*/
DROP procedure IF EXISTS eppic_performance;
DELIMITER //
CREATE procedure eppic_performance(in dbname varchar(255),in method varchar(255), in h int(11)) 
BEGIN
declare tp,tn,fp,fn,p,n,cc int(11);
declare Sensitivity,Specificity,Accuracy,MCC double;
select 1 into cc;
if (dbname='dc' and method='cs') then
select count(*) into p  from dc_bio where h1>=h and h2>=h and  cs!='nopred';
select count(*) into n  from dc_xtal where h1>=h and h2>=h and  cs!='nopred';
select count(*) into tp  from dc_bio where h1>=h and h2>=h and  cs='bio';
select count(*) into tn  from dc_xtal where h1>=h and h2>=h and  cs='xtal';
select count(*) into fn  from dc_bio where h1>=h and h2>=h and  cs='xtal';
select count(*) into fp  from dc_xtal where h1>=h and h2>=h and  cs='bio';
elseif (dbname='dc' and method='cr') then
select count(*) into p  from dc_bio where h1>=h and h2>=h and  cs!='nopred';
select count(*) into n  from dc_xtal where h1>=h and h2>=h and  cs!='nopred';
select count(*) into tp  from dc_bio where h1>=h and h2>=h and  cr='bio';
select count(*) into tn  from dc_xtal where h1>=h and h2>=h and  cr='xtal';
select count(*) into fn  from dc_bio where h1>=h and h2>=h and  cr='xtal';
select count(*) into fp  from dc_xtal where h1>=h and h2>=h and  cr='bio';
elseif (dbname='dc' and method='gm') then
select count(*) into p  from dc_bio where h1>=h and h2>=h and  gm!='nopred';
select count(*) into n  from dc_xtal where h1>=h and h2>=h and  gm!='nopred';
select count(*) into tp  from dc_bio where h1>=h and h2>=h and  gm='bio';
select count(*) into tn  from dc_xtal where h1>=h and h2>=h and  gm='xtal';
select count(*) into fn  from dc_bio where h1>=h and h2>=h and  gm='xtal';
select count(*) into fp  from dc_xtal where h1>=h and h2>=h and  gm='bio';
elseif (dbname='dc' and method='final') then
select count(*) into p  from dc_bio where h1>=h and h2>=h and  cs!='nopred';
select count(*) into n  from dc_xtal where h1>=h and h2>=h and  cs!='nopred';
select count(*) into tp  from dc_bio where h1>=h and h2>=h and  final='bio';
select count(*) into tn  from dc_xtal where h1>=h and h2>=h and  final='xtal';
select count(*) into fn  from dc_bio where h1>=h and h2>=h and  final='xtal';
select count(*) into fp  from dc_xtal where h1>=h and h2>=h and  final='bio';
elseif (dbname='po' and method='cr') then
select count(*) into p  from po_bio where h1>=h and h2>=h and  cs!='nopred';
select count(*) into n  from po_xtal where h1>=h and h2>=h and  cs!='nopred';
select count(*) into tp  from po_bio where h1>=h and h2>=h and  cr='bio';
select count(*) into tn  from po_xtal where h1>=h and h2>=h and  cr='xtal';
select count(*) into fn  from po_bio where h1>=h and h2>=h and  cr='xtal';
select count(*) into fp  from po_xtal where h1>=h and h2>=h and  cr='bio';
elseif (dbname='po' and method='cs') then
select count(*) into p  from po_bio where h1>=h and h2>=h and  cs!='nopred';
select count(*) into n  from po_xtal where h1>=h and h2>=h and  cs!='nopred';
select count(*) into tp  from po_bio where h1>=h and h2>=h and  cs='bio';
select count(*) into tn  from po_xtal where h1>=h and h2>=h and  cs='xtal';
select count(*) into fn  from po_bio where h1>=h and h2>=h and  cs='xtal';
select count(*) into fp  from po_xtal where h1>=h and h2>=h and  cs='bio';
elseif (dbname='po' and method='final') then
select count(*) into p  from po_bio where h1>=h and h2>=h and  cs!='nopred';
select count(*) into n  from po_xtal where h1>=h and h2>=h and  cs!='nopred';
select count(*) into tp  from po_bio where h1>=h and h2>=h and  final='bio';
select count(*) into tn  from po_xtal where h1>=h and h2>=h and  final='xtal';
select count(*) into fn  from po_bio where h1>=h and h2>=h and  final='xtal';
select count(*) into fp  from po_xtal where h1>=h and h2>=h and  final='bio';
elseif (dbname='po' and method='gm') then
select count(*) into p  from po_bio where h1>=h and h2>=h and  gm!='nopred';
select count(*) into n  from po_xtal where h1>=h and h2>=h and  gm!='nopred';
select count(*) into tp  from po_bio where h1>=h and h2>=h and  gm='bio';
select count(*) into tn  from po_xtal where h1>=h and h2>=h and  gm='xtal';
select count(*) into fn  from po_bio where h1>=h and h2>=h and  gm='xtal';
select count(*) into fp  from po_xtal where h1>=h and h2>=h and  gm='bio';
elseif (dbname='many' and method='cs') then
select count(*) into p  from many_bio where h1>=h and h2>=h and  cs!='nopred';
select count(*) into n  from many_xtal where h1>=h and h2>=h and  cs!='nopred';
select count(*) into tp  from many_bio where h1>=h and h2>=h and  cs='bio';
select count(*) into tn  from many_xtal where h1>=h and h2>=h and  cs='xtal';
select count(*) into fn  from many_bio where h1>=h and h2>=h and  cs='xtal';
select count(*) into fp  from many_xtal where h1>=h and h2>=h and  cs='bio';
elseif (dbname='many' and method='cr') then
select count(*) into p  from many_bio where h1>=h and h2>=h and  cs!='nopred';
select count(*) into n  from many_xtal where h1>=h and h2>=h and  cs!='nopred';
select count(*) into tp  from many_bio where h1>=h and h2>=h and  cr='bio';
select count(*) into tn  from many_xtal where h1>=h and h2>=h and  cr='xtal';
select count(*) into fn  from many_bio where h1>=h and h2>=h and  cr='xtal';
select count(*) into fp  from many_xtal where h1>=h and h2>=h and  cr='bio';
elseif (dbname='many' and method='final') then
select count(*) into p  from many_bio where h1>=h and h2>=h and  cs!='nopred';
select count(*) into n  from many_xtal where h1>=h and h2>=h and  cs!='nopred';
select count(*) into tp  from many_bio where h1>=h and h2>=h and  final='bio';
select count(*) into tn  from many_xtal where h1>=h and h2>=h and  final='xtal';
select count(*) into fn  from many_bio where h1>=h and h2>=h and  final='xtal';
select count(*) into fp  from many_xtal where h1>=h and h2>=h and  final='bio';
elseif (dbname='many' and method='gm') then
select count(*) into p  from many_bio where h1>=h and h2>=h and  gm!='nopred';
select count(*) into n  from many_xtal where h1>=h and h2>=h and  gm!='nopred';
select count(*) into tp  from many_bio where h1>=h and h2>=h and  gm='bio';
select count(*) into tn  from many_xtal where h1>=h and h2>=h and  gm='xtal';
select count(*) into fn  from many_bio where h1>=h and h2>=h and  gm='xtal';
select count(*) into fp  from many_xtal where h1>=h and h2>=h and  gm='bio';
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
select dbname,method,Sensitivity,Specificity,Accuracy,MCC;
end if;
END//
DELIMITER ;

/*to get the databse size*/

DROP procedure IF EXISTS benchmark_size;
DELIMITER //
CREATE procedure benchmark_size(in dbname varchar(255),in method varchar(255), in h int(11)) 
BEGIN
declare BioTotal,BioPred,BioNopred,XtalTotal,XtalPred,XtalNopred int(11);
if (dbname='dc' and method='cs') then
select count(*) into BioTotal  from dc_bio where h1>=h and h2>=h;
select count(*) into BioNopred  from dc_bio where cs='nopred' and h1>=h and h2>=h;
select BioTotal-BioNopred into BioPred;
select count(*) into XtalTotal  from dc_xtal where h1>=h and h2>=h;
select count(*) into XtalNopred  from dc_xtal where cs='nopred' and h1>=h and h2>=h;
select XtalTotal-XtalNopred into XtalPred;
elseif (dbname='dc' and method='cr') then
select count(*) into BioTotal  from dc_bio where h1>=h and h2>=h;
select count(*) into BioNopred  from dc_bio where cr='nopred' and h1>=h and h2>=h;
select BioTotal-BioNopred into BioPred;
select count(*) into XtalTotal  from dc_xtal where h1>=h and h2>=h;
select count(*) into XtalNopred  from dc_xtal where cr='nopred' and h1>=h and h2>=h;
select XtalTotal-XtalNopred into XtalPred;
elseif (dbname='po' and method='cr') then
select count(*) into BioTotal  from po_bio where h1>=h and h2>=h;
select count(*) into BioNopred  from po_bio where cr='nopred' and h1>=h and h2>=h;
select BioTotal-BioNopred into BioPred;
select count(*) into XtalTotal  from po_xtal where h1>=h and h2>=h;
select count(*) into XtalNopred  from po_xtal where cr='nopred' and h1>=h and h2>=h;
select XtalTotal-XtalNopred into XtalPred;
elseif (dbname='po' and method='cs') then
select count(*) into BioTotal  from po_bio where h1>=h and h2>=h;
select count(*) into BioNopred  from po_bio where cs='nopred' and h1>=h and h2>=h;
select BioTotal-BioNopred into BioPred;
select count(*) into XtalTotal  from po_xtal where h1>=h and h2>=h;
select count(*) into XtalNopred  from po_xtal where cs='nopred' and h1>=h and h2>=h;
select XtalTotal-XtalNopred into XtalPred;
elseif (dbname='many' and method='cs') then
select count(*) into BioTotal  from many_bio where h1>=h and h2>=h;
select count(*) into BioNopred  from many_bio where cs='nopred' and h1>=h and h2>=h;
select BioTotal-BioNopred into BioPred;
select count(*) into XtalTotal  from many_xtal where h1>=h and h2>=h;
select count(*) into XtalNopred  from many_xtal where cs='nopred' and h1>=h and h2>=h;
select XtalTotal-XtalNopred into XtalPred ;
elseif (dbname='many' and method='cr') then
select count(*) into BioTotal  from many_bio where h1>=h and h2>=h;
select count(*) into BioNopred  from many_bio where cr='nopred' and h1>=h and h2>=h;
select BioTotal-BioNopred into BioPred;
select count(*) into XtalTotal  from many_xtal where h1>=h and h2>=h;
select count(*) into XtalNopred  from many_xtal where cr='nopred' and h1>=h and h2>=h;
select XtalTotal-XtalNopred into XtalPred ;
else
select "Entered paramers are wrong";
end if;
select dbname,method,BioTotal,XtalTotal,BioPred,XtalPred,BioNopred,XtalNopred;
END//
DELIMITER ;




DROP procedure IF EXISTS get_benchmark_size;
DELIMITER //
CREATE procedure get_benchmark_size(in h int(11))
BEGIN
call benchmark_size('dc','cr',h);
call benchmark_size('dc','cs',h); 
call benchmark_size('dc','final',h);
call benchmark_size('po','cr',h);
call benchmark_size('po','cs',h); 
call benchmark_size('po','final',h);
call benchmark_size('many','cr',h);
call benchmark_size('many','cs',h); 
call benchmark_size('many','final',h);
END//
DELIMITER ;


DROP procedure IF EXISTS get_eppic_performance;
DELIMITER //
CREATE procedure get_eppic_performance(in h int(11))
BEGIN
call eppic_performance('dc','gm',h);
call eppic_performance('dc','cr',h);
call eppic_performance('dc','cs',h); 
call eppic_performance('dc','final',h);
call eppic_performance('po','gm',h);
call eppic_performance('po','cr',h);
call eppic_performance('po','cs',h); 
call eppic_performance('po','final',h);
call eppic_performance('many','gm',h);
call eppic_performance('many','cr',h);
call eppic_performance('many','cs',h); 
call eppic_performance('many','final',h);
END//
DELIMITER ;



DROP procedure IF EXISTS build_report;
DELIMITER //
CREATE procedure build_report()
BEGIN
declare t,c,i,x,b,n,tc,tcm,tcm60,tcm50,tcm6010,tcm5010 int(11);
select count(*) into t from Job where length(jobId)=4;
select count(*) into c from Job where length(jobId)=4 and status="Finished";
select count(*) into i from detailedTable;
select count(*) into b from detailedTable where final='bio';
select count(*) into x from detailedTable where final='xtal';
select count(*) into n from detailedTable where final='nopred';
select count(*) into tc from ChainCluster as c inner join PdbInfo as p on p.uid=c.pdbInfo_uid 
inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4;
select count(*) into tcm from ChainCluster as c inner join PdbInfo as p on p.uid=c.pdbInfo_uid 
inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and c.hasUniProtRef;
select count(*) into tcm60 from ChainCluster as c inner join PdbInfo as p on p.uid=c.pdbInfo_uid 
inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and c.hasUniProtRef and c.seqIdCutoff>0.59;
select count(*) into tcm50 from ChainCluster as c inner join PdbInfo as p on p.uid=c.pdbInfo_uid 
inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and c.hasUniProtRef and c.seqIdCutoff>0.49;
select count(*) into tcm6010 from ChainCluster as c inner join PdbInfo as p on p.uid=c.pdbInfo_uid 
inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and c.hasUniProtRef and c.seqIdCutoff>0.59 and c.numHomologs>=10;
select count(*) into tcm5010 from ChainCluster as c inner join PdbInfo as p on p.uid=c.pdbInfo_uid 
inner join Job as j on j.uid=p.job_uid where length(j.jobId)=4 and c.hasUniProtRef and c.seqIdCutoff>0.49 and c.numHomologs>=10;
select t Total_number_of_pdbs,c Eppic_precomputed,t-c Nonstandard_and_clashes,(c/t)*100 Eppic_precomputed_percentage;
select i Total_number_of_Interfaces,x final_xtal,(x/i)*100 final_xtal_percentage,b final_bio,(b/i)*100 final_bio_percentage;
select tc total_no_chains,tcm has_uniprot_match,tcm6010 idcutoff60_10homologs,(tcm6010/tcm)*100 percentage,tcm5010 idcutoff50_10homologs,(tcm5010/tcm)*100 percentage;
call get_eppic_performance(0);
END//
DELIMITER ;












select count(*) from InterfaceScore as s inner join Interface as i
on i.uid=s.interfaceItem_uid where method='eppic' and callName='bio' and s.pdbCode='4hnk' group by i.clusterId;


















