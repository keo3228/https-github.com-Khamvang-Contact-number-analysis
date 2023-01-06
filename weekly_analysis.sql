-- ________________________________________________ Analysis for contact_numbers_to_lcc ________________________________________________ --
-- 1)create table
CREATE TABLE `all_unique_analysis_weekly` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contact_no` varchar(255) NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `priority_type` varchar(255) NOT NULL,
  `date_created` date DEFAULT NULL,
  `date_updated` date DEFAULT NULL,
  `lalcocustomer_id` int NOT NULL DEFAULT '0',
  `custtbl_id` int NOT NULL DEFAULT '0',
  `pbxcdr_id` int NOT NULL DEFAULT '0',
  `pbxcdr_called_time` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3;


# Backup data from all_unique_analysis_weekly to all_unique_analysis 
select count(*) from all_unique_analysis_weekly auaw -- 399473

-- 1 backup data
insert into all_unique_analysis (contact_no , status , priority_type , date_created , date_updated , lalcocustomer_id , custtbl_id , pbxcdr_id , pbxcdr_called_time)
select contact_no , status , priority_type , date_created , date_updated , lalcocustomer_id , custtbl_id , pbxcdr_id , pbxcdr_called_time  from all_unique_analysis_weekly ;

-- 2 delete duplicate
delete from removed_duplicate_2;
select count(*) from all_unique_analysis; -- 13157997 >> 10769929 >> 11169402
insert into removed_duplicate_2 
select id, row_numbers, now() `time` from ( 
		select id , row_number() over (partition by contact_no order by field(priority_type, "contracted", "ringi_not_contract", "aseet_not_contract",
			"prospect_sabc", "pbx_cdr") ,
		FIELD(`status` , "Active", "Closed", "Refinance", "Disbursement Approval", "Pending Disbursement", "Pending Approval", "Pending",
		"Approved", "Pending Approval from Credit", "Asset Assessed", "Pending Assessment", "Draft", "Cancelled", "Deleted",
			"X", "S", "A", "B", "C", "F", "G", "G1", "G2", "ANSWERED", "NO ANSWER", "FAILED", "BUSY", "VOICEMAIL"), id desc) as row_numbers  
		from all_unique_analysis 
		) as t1
	where row_numbers > 1;

delete from all_unique_analysis where id in (select id from removed_duplicate_2 );

-- delete before import new
delete from all_unique_analysis_weekly ;

-- 2) Export data to contact_data_db analysis  
-- (1) contracted: export from database lalco to analysis in database contact_data_db table all_unique_analysis
select * from all_unique_analysis_weekly where priority_type = 'contracted' order by date_created desc;
SELECT * FROM (
SELECT 
	NULL `id`,
case when left (right (REPLACE ( cu.main_contact_no, ' ', '') ,8),1) = '0' then CONCAT('903',right (REPLACE ( cu.main_contact_no, ' ', '') ,8))
    when length (REPLACE ( cu.main_contact_no, ' ', '')) = 7 then CONCAT('9030',REPLACE ( cu.main_contact_no, ' ', ''))
    else CONCAT('9020', right(REPLACE ( cu.main_contact_no, ' ', '') , 8))
end `contact_no`,
	CASE
		c.status WHEN 0 THEN 'Pending' WHEN 1 THEN 'Pending Approval' WHEN 2 THEN 'Pending Disbursement'
		WHEN 3 THEN 'Disbursement Approval' WHEN 4 THEN 'Active' WHEN 5 THEN 'Cancelled'
		WHEN 6 THEN 'Refinance' WHEN 7 THEN 'Closed' ELSE NULL
	END `status`,
	'contracted' `priority_type`,
	case when c.status = 4 then from_unixtime(c.disbursed_datetime , '%Y-%m-%d') when c.status in (6,7) then c.date_closed end `date_created`,
	date(now()) `date_updated`,
	cu.id 'lalcocustomer_id'
FROM tblcontract c left join tblprospect p on (p.id = c.prospect_id)
left join tblcustomer cu on (cu.id = p.customer_id)
WHERE c.status in (4,6,7) ) t
WHERE LENGTH(contact_no) IN (11,12) and `date_created` >= '2022-10-25'; -- copy last date_created to here

-- (2) ringi not contract: export from database lalco to analysis in database contact_data_db table all_unique_analysis
select * from all_unique_analysis_weekly where priority_type = 'ringi_not_contract' order by date_created desc;
SELECT * FROM (
SELECT 
	NULL `id`,
case when left (right (REPLACE ( cu.main_contact_no, ' ', '') ,8),1) = '0' then CONCAT('903',right (REPLACE ( cu.main_contact_no, ' ', '') ,8))
    when length (REPLACE ( cu.main_contact_no, ' ', '')) = 7 then CONCAT('9030',REPLACE ( cu.main_contact_no, ' ', ''))
    else CONCAT('9020', right(REPLACE ( cu.main_contact_no, ' ', '') , 8))
end `contact_no`,
	CASE p.status WHEN 0 THEN 'Draft'
		WHEN 1 THEN 'Pending Approval from Credit'
		WHEN 2 THEN 'Pending Final Approval from Credit Manager'
		WHEN 3 THEN 'Approved'
		WHEN 4 THEN 'Cancelled'
		ELSE NULL
	END `status`,
	'ringi_not_contract' `priority_type`,
	FROM_UNIXTIME(p.date_updated , '%Y-%m-%d') `date_created`,
	date(now()) `date_updated`,
	cu.id 'lalcocustomer_id'
FROM tblcontract c right join tblprospect p on (p.id = c.prospect_id)
left join tblcustomer cu on (cu.id = p.customer_id)
WHERE c.status not in (4,6,7) or p.status != 3 ) t
WHERE LENGTH(contact_no) IN (11,12) and `date_created` >= '2022-10-25'; -- copy last date_created to here

-- (3) asset not contract: export from database lalco to analysis in database contact_data_db table all_unique_analysis
select * from all_unique_analysis_weekly where priority_type = 'aseet_not_contract' order by date_created desc;
SELECT * FROM (
SELECT 
	NULL `id`,
case when cu.id is null or cu.id = '' then
(case when left (right (REPLACE ( cu2.main_contact_no, ' ', '') ,8),1) = '0' then CONCAT('903',right (REPLACE ( cu2.main_contact_no, ' ', '') ,8))
    when length (REPLACE ( cu2.main_contact_no, ' ', '')) = 7 then CONCAT('9030',REPLACE ( cu2.main_contact_no, ' ', ''))
    else CONCAT('9020', right(REPLACE ( cu2.main_contact_no, ' ', '') , 8))
end )
else 
(case when left (right (REPLACE ( cu.main_contact_no, ' ', '') ,8),1) = '0' then CONCAT('903',right (REPLACE ( cu.main_contact_no, ' ', '') ,8))
    when length (REPLACE ( cu.main_contact_no, ' ', '')) = 7 then CONCAT('9030',REPLACE ( cu.main_contact_no, ' ', ''))
    else CONCAT('9020', right(REPLACE ( cu.main_contact_no, ' ', '') , 8))
end )
end
`contact_no`,
	CASE av.status WHEN 0 THEN 'Draft' WHEN 1 THEN 'Pending Assessment' WHEN 2 THEN 'Asset Assessed' 
		WHEN 3 THEN 'Cancelled' WHEN 4 THEN 'Deleted' 
	END `status`,
	'aseet_not_contract' `priority_type`,
	case when cu.id is null or cu.id = '' then FROM_UNIXTIME(cu2.date_created, '%Y-%m-%d')
	else FROM_UNIXTIME(av.date_updated , '%Y-%m-%d') end `date_created`,
	date(now()) `date_updated`,
	case when cu.id is null or cu.id = '' then cu2.id else cu.id end 'lalcocustomer_id'
FROM tblassetvaluation av left join tblcustomer cu on (av.customer_id = cu.id)
left join tblprospectasset pa on (pa.assetvaluation_id = av.id)
left join tblprospect p on (p.id = pa.prospect_id)
left join tblcustomer cu2 on (p.customer_id = cu2.id)
WHERE av.status != 2 or p.status != 3 
) t
WHERE LENGTH(contact_no) IN (11,12) and `date_created` >= '2022-10-25'; -- copy last date_created to here

-- 3) import from database lalcodb to analysis in database contact_data_db
select * from all_unique_analysis_weekly where priority_type = 'prospect_sabc' order by custtbl_id desc;
select '' "id",
	case
		when left(right (translate (c.tel, translate(c.tel, '0123456789', ''), ''), 8), 1)= '0' then CONCAT('903', right (translate (c.tel, translate(c.tel, '0123456789', ''), ''), 8))
		when LENGTH( translate (c.tel, translate(c.tel, '0123456789', ''), '')) = 7 then CONCAT('9030', right (translate (c.tel, translate(c.tel, '0123456789', ''), ''), 8))
		else CONCAT('9020', right (translate (c.tel, translate(c.tel, '0123456789', ''), ''), 8))
	end "contact_no",
	c.rank1 "status",
	'prospect_sabc' "priority_type",
	case when n.inputdate is null then c.inputdate else n.inputdate end "date_created",
	date(now()) "date_updated",
	c.id "custtbl_id"
from custtbl c left join negtbl n on (c.id = n.custid)
where c.inputdate >= '2022-10-26' or n.inputdate >= '2022-10-26'; -- please chcek this date_created date from table all_unique_analysis


-- 4) import data from database lalco_pbx to database contact_data_db
select * from all_unique_analysis_weekly where priority_type = 'pbx_cdr' order by pbxcdr_id desc;
insert into all_unique_analysis_weekly  
select null id, callee_number 'contact_no',
	case when status = 'FAILED' or status = 'BUSY' or status = 'VOICEMAIL' then 'NO ANSWER' else status end status ,
	'pbx_cdr' `priority_type`,
	date_format(`time`, '%Y-%m-%d') date_created,
	date(now()) date_updated,
	0 lalcocustomer_id ,
	0 custtbl_id ,
	id `pbxcdr_id` ,
	0 `pbxcdr_called_time` 
from lalco_pbx.pbx_cdr pc 
where -- status = 'ANSWERED' and communication_type = 'Outbound'
	   status in ('NO ANSWER', 'FAILED', 'BUSY', 'VOICEMAIL' ) and communication_type = 'Outbound'
 and date_format(`time`, '%Y-%m-%d') >= '2022-10-25' -- please chcek this date from table all_unique_analysis
 and CONCAT(LENGTH(callee_number), left( callee_number, 5)) in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290209')
group by callee_number ;


-- 5)delete duplicate
delete from removed_duplicate_2;
select count(*) from all_unique_analysis_weekly; -- 4406803 >> 399473
insert into removed_duplicate_2 
select id, row_numbers, now() `time` from ( 
		select id , row_number() over (partition by contact_no order by field(priority_type, "contracted", "ringi_not_contract", "aseet_not_contract",
			"prospect_sabc", "pbx_cdr") ,
		FIELD(`status` , "Active", "Closed", "Refinance", "Disbursement Approval", "Pending Disbursement", "Pending Approval", "Pending",
		"Approved", "Pending Approval from Credit", "Asset Assessed", "Pending Assessment", "Draft", "Cancelled", "Deleted",
			"X", "S", "A", "B", "C", "F", "G", "G1", "G2", "ANSWERED", "NO ANSWER", "FAILED", "BUSY", "VOICEMAIL"), id desc) as row_numbers  
		from all_unique_analysis_weekly  
		) as t1
	where row_numbers > 1;

delete from all_unique_analysis_weekly where id in (select id from removed_duplicate_2 );

delete from all_unique_analysis_weekly where date_created < '2022-09-21';

-- 6)check data
select priority_type, status, count(*) from all_unique_analysis_weekly where date_updated >= '2022-10-25' group by priority_type, status 
order by field(priority_type, "contracted", "ringi_not_contract", "aseet_not_contract",
			"prospect_sabc", "pbx_cdr") ,
	FIELD(`status` , "Active", "Closed", "Refinance", "Disbursement Approval", "Pending Disbursement", "Pending Approval", "Pending",
		"Approved", "Pending Approval from Credit", "Asset Assessed", "Pending Assessment", "Draft", "Cancelled", "Deleted",
			"X", "S", "A", "B", "C", "F", "G", "G1", "G2", "ANSWERED", "NO ANSWER", "FAILED", "BUSY", "VOICEMAIL") ;



select count(*)  from contact_numbers_to_lcc ;
select * from all_unique_analysis_weekly auaw where priority_type = 'prospect_sabc' and status = '';




-- ________________________________________________ update status for contact_numbers_to_lcc ________________________________________________ --
-- 001 priority_type = 'contracted'
-- 7)insert data to temp_update_any
insert into temp_update_any 
select cntl.id, cntl.contact_no, aua.priority_type `remark_3`, aua.status, 0 `pbxcdr_time` 
from contact_numbers_to_lcc cntl left join all_unique_analysis_weekly  aua on (cntl.contact_no = aua.contact_no)
where aua.priority_type = 'contracted' and aua.date_created >= '2022-11-26' ;
select now(); -- datetime on this time

select status, count(*) from contact_numbers_to_lcc cntl where cntl.id in (select id from temp_update_any) group by status;

-- 8)update status in table contact_numbers_to_lcc 
update contact_numbers_to_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_3 = tua.remark_3, cntl.status = tua.status, cntl.date_updated = date(now())
where cntl.id in (select id from temp_update_any );
select now(); -- datetime on this time

select status, status_updated, count(*)  from contact_for_202212_lcc cntl where cntl.id in (select id from temp_update_any)  group by status, status_updated ;

-- 8)update status in table contact_for_202212_lcc 
update contact_for_202212_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_2 = tua.remark_3, cntl.status_updated = tua.status
where cntl.id in (select id from temp_update_any );
select now(); -- datetime on this time

-- 9)delete data from temp_update_any
delete from temp_update_any ;
select now(); -- datetime on this time


-- 002 priority_type = 'ringi_not_contract'
-- 7)insert data to temp_update_any
insert into temp_update_any 
select cntl.id, cntl.contact_no, aua.priority_type `remark_3`, aua.status, 0 `pbxcdr_time` 
from contact_numbers_to_lcc cntl left join all_unique_analysis_weekly  aua on (cntl.contact_no = aua.contact_no)
where aua.priority_type = 'ringi_not_contract' and aua.date_created >= '2022-11-26' ;

select status, count(*) from contact_numbers_to_lcc cntl where cntl.id in (select id from temp_update_any) group by status;

-- 8)update status in table contact_numbers_to_lcc 
update contact_numbers_to_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_3 = tua.remark_3, cntl.status = tua.status, cntl.date_updated = date(now())
where cntl.id in (select id from temp_update_any) and (cntl.status is null or cntl.remark_3 not in ('contracted'));
select now(); -- datetime on this time

select status, status_updated, count(*)  from contact_for_202212_lcc cntl where cntl.id in (select id from temp_update_any) group by status, status_updated ;

-- 8)update status in table contact_for_202212_lcc 
update contact_for_202212_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_2 = tua.remark_3, cntl.status_updated = tua.status
where cntl.id in (select id from temp_update_any) and (cntl.status_updated is null or cntl.remark_2 not in ('contracted'));
select now(); -- datetime on this time

-- 9)delete data from temp_update_any
delete from temp_update_any ;
select now(); -- datetime on this time


-- 003 priority_type = 'ringi_not_contract'
-- 7)insert data to temp_update_any
insert into temp_update_any 
select cntl.id, cntl.contact_no, aua.priority_type `remark_3`, aua.status, 0 `pbxcdr_time` 
from contact_numbers_to_lcc cntl left join all_unique_analysis_weekly  aua on (cntl.contact_no = aua.contact_no)
where aua.priority_type = 'aseet_not_contract' and aua.date_created >= '2022-11-26';

select remark_3, status, count(*) from contact_numbers_to_lcc cntl where cntl.id in (select id from temp_update_any) group by remark_3, status;

-- 8)update status in table contact_numbers_to_lcc 
update contact_numbers_to_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_3 = tua.remark_3, cntl.status = tua.status, cntl.date_updated = date(now())
where cntl.id in (select id from temp_update_any) and (cntl.status is null or cntl.remark_3 not in ('contracted'));
select now(); -- datetime on this time

select remark_3, status, count(*) from contact_numbers_to_lcc cntl where cntl.id in (select id from temp_update_any) group by remark_3, status;

-- 8)update status in table contact_for_202212_lcc 
update contact_for_202212_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_2 = tua.remark_3, cntl.status_updated = tua.status
where cntl.id in (select id from temp_update_any) and (cntl.status_updated is null or cntl.remark_2 not in ('contracted'));
select now(); -- datetime on this time

-- 9)delete data from temp_update_any
delete from temp_update_any ;
select now(); -- datetime on this time

-- 004 priority_type = 'prospect_sabc' 
-- 7)insert data to temp_update_any
insert into temp_update_any 
select cntl.id, cntl.contact_no, aua.priority_type `remark_3`, aua.status, 0 `pbxcdr_time` 
from contact_numbers_to_lcc cntl left join all_unique_analysis_weekly  aua on (cntl.contact_no = aua.contact_no)
where aua.priority_type = 'prospect_sabc' and aua.date_created >= '2022-11-26';

-- 
insert into temp_update_any 
select aua.id, aua.contact_no, aua.priority_type `remark_3`, aua.status, 0 `pbxcdr_time` 
from all_unique_analysis_weekly  aua 
where aua.priority_type = 'prospect_sabc' and aua.date_created >= '2022-11-26';

select cntl.id, cntl.contact_no, 'prospect_sabc' `remark_3`, null status, 0 `pbxcdr_time` from contact_numbers_to_lcc cntl 
where cntl.contact_no in (select contact_no from temp_update_any tua);

select * from temp_update_any tua ;

select remark_3, status, count(*) from contact_numbers_to_lcc cntl where cntl.id in (select id from temp_update_any) group by remark_3, status;

-- 8)update status in table contact_numbers_to_lcc 
update contact_numbers_to_lcc cntl inner join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_3 = tua.remark_3, cntl.status = tua.status, cntl.date_updated = date(now())
where cntl.id in (select id from temp_update_any ) and (cntl.status is null or cntl.remark_3 not in ('contracted', 'ringi_not_contract', 'aseet_not_contract'));
select now(); -- datetime on this time

select status, status_updated, count(*) from contact_for_202212_lcc cntl where cntl.id in (select id from temp_update_any) group by status, status_updated ;

-- 8)update status in table contact_for_202212_lcc 
update contact_for_202212_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_2 = tua.remark_3, cntl.status_updated = tua.status
where cntl.id in (select id from temp_update_any) and (cntl.status_updated is null or cntl.remark_2 not in ('contracted', 'ringi_not_contract', 'aseet_not_contract'));
select now(); -- datetime on this time

-- 9)delete data from temp_update_any
delete from temp_update_any ;
select now(); -- datetime on this time


-- 005 aua.priority_type = 'pbx_cdr' and aua.status = 'ANSWERED' and cntl.status != 'ANSWERED'
-- 7)insert data to temp_update_any
insert into temp_update_any 
select cntl.id, cntl.contact_no, aua.priority_type `remark_3`, aua.status, 0 `pbxcdr_time` 
from contact_numbers_to_lcc cntl inner join all_unique_analysis_weekly aua on (cntl.contact_no = aua.contact_no)
where aua.priority_type = 'pbx_cdr' and aua.status = 'ANSWERED' and cntl.status != 'ANSWERED' and aua.date_created >= '2022-11-26';

-- 7)insert data to temp_update_any
insert into temp_update_any 
select aua.id, aua.contact_no, aua.priority_type `remark_3`, aua.status, 0 `pbxcdr_time` 
from all_unique_analysis_weekly  aua 
where aua.priority_type = 'pbx_cdr' and aua.status = 'ANSWERED' and aua.date_created >= '2022-11-26';

select cntl.id, cntl.contact_no, 'pbx_cdr' `remark_3`, 'ANSWERED' status, 0 `pbxcdr_time` from contact_numbers_to_lcc cntl 
where cntl.contact_no in (select contact_no from temp_update_any tua);

select * from temp_update_any tua ;

select remark_3, status, count(*) from contact_numbers_to_lcc cntl where cntl.id in (select id from temp_update_any) group by remark_3, status;

-- 8)update status in table contact_numbers_to_lcc 
update contact_numbers_to_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_3 = tua.remark_3, cntl.status = tua.status, cntl.date_updated = date(now())
where cntl.id in (select id from temp_update_any ) and (cntl.status is null or cntl.remark_3 not in ('contracted', 'ringi_not_contract', 'aseet_not_contract', 'prospect_sabc'));
select now(); -- datetime on this time

select status, status_updated, count(*) from contact_for_202212_lcc cntl where cntl.id in (select id from temp_update_any) group by status, status_updated ;

-- 8)update status in table contact_for_202212_lcc 
update contact_for_202212_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_2 = tua.remark_3, cntl.status_updated = tua.status
where cntl.id in (select id from temp_update_any) and (cntl.status_updated is null or cntl.remark_2 not in ('contracted', 'ringi_not_contract', 'aseet_not_contract', 'prospect_sabc'));
select now(); -- datetime on this time

-- 9)delete data from temp_update_any
delete from temp_update_any ;
select now(); -- datetime on this time


-- 006 aua.priority_type = 'pbx_cdr' and aua.status = 'NO ANSWER' and cntl.status != 'NO ANSWER'
-- 7)insert data to temp_update_any
insert into temp_update_any 
select cntl.id, cntl.contact_no, aua.priority_type `remark_3`, aua.status, 0 `pbxcdr_time` 
from contact_numbers_to_lcc cntl left join all_unique_analysis_weekly aua on (cntl.contact_no = aua.contact_no)
where aua.priority_type = 'pbx_cdr' and aua.status = 'NO ANSWER' and cntl.status != 'NO ANSWER' and aua.date_created >= '2022-11-26';

-- 7)insert data to temp_update_any
insert into temp_update_any 
select aua.id, aua.contact_no, aua.priority_type `remark_3`, aua.status, 0 `pbxcdr_time` 
from all_unique_analysis_weekly  aua 
where aua.priority_type = 'pbx_cdr' and aua.status = 'NO ANSWER' and aua.date_created >= '2022-11-26';

select cntl.id, cntl.contact_no, 'pbx_cdr' `remark_3`, null status, 0 `pbxcdr_time` from contact_numbers_to_lcc cntl 
where cntl.contact_no in (select contact_no from temp_update_any tua);

select * from temp_update_any tua ;

select remark_3, status, count(*) from contact_numbers_to_lcc cntl where cntl.id in (select id from temp_update_any) group by remark_3, status;

-- 8)update status in table contact_numbers_to_lcc 
update contact_numbers_to_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_3 = tua.remark_3, cntl.status = tua.status, cntl.date_updated = date(now())
where cntl.id in (select id from temp_update_any ) and (cntl.status is null or cntl.status in ('SMS_success', 'ETL_active'));
select now(); -- datetime on this time

select status, status_updated, count(*) from contact_for_202212_lcc cntl where cntl.id in (select id from temp_update_any)  group by status, status_updated ;

-- 8)update status in table contact_for_202212_lcc 
update contact_for_202212_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_2 = tua.remark_3, cntl.status_updated = tua.status
where cntl.id in (select id from temp_update_any ) and (cntl.status_updated is null or cntl.status_updated in ('SMS_success', 'ETL_active'));
select now(); -- datetime on this time

-- 9)delete data from temp_update_any
delete from temp_update_any ;
select now(); -- datetime on this time

insert into temp_update_any 
select id, concat('90', contact_no) 'contact_no', '' remark_3, '' status, 0 pbxcdr_time from temp_sms_chairman where date_updated >= '2022-09-01' and status = 2

select id, contact_no, remark_3 , status, date_updated from contact_numbers_to_lcc cntl 
where id in (select id from temp_update_any ) and status is not null and date_updated != '2022-11-26' and status not in ('Active', 'Approved','Draft','ANSWERED','X','C');

update contact_numbers_to_lcc set remark_3 = 'Telecom', status = 'SMS_Failed', date_updated = date(now()) 
where id in (select id from temp_update_any ) and status is not null and date_updated != '2022-11-26' and status not in ('Active', 'Approved','Draft','ANSWERED','X','C');

delete from temp_update_any ;

select count(*) from contact_numbers cn where file_id = 1059; order by id desc; -- 48258961, 47741438
select count(*) from contact_numbers_to_lcc cntl where file_id = 1059; order by id desc; -- 48278665, 
select * from payment p order by id desc;


