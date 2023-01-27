-- _____________________________________________________________________________________________________________________________ --
#============ The step to insert new contact numbers to my database ================
-- 1) check the current data in contact_numbers before import new 
select * from contact_numbers where remark_1 in ('1233','1234','1235','1236','1237','1238','1239','1240','1241','1242') ;
-- result: 0 row
select * from contact_numbers order by id desc limit 10;
-- result: last id 47610791 and last file_id 1066
select * from file_details order by id desc;
id  |file_no|file_name                    
----+-------+-----------------------------
1067|1258   |1258_Sai_3463_20230126_CSV   
1066|1257   |1257_Sai_3463_20230126_CSV    

-- 2) open the googlessheets link: [https://docs.google.com/spreadsheets/d/1e6i-Xhnb7VhSkgSuSlzOhLs53gasV-DiwbOcSftcVdQ/edit#gid=115262897]

-- 3) convert file .xlsx to file .csv download files from sheetname [Upload_Excel_file] 

-- 4) upload file .csv to sheetname [Upload_CSV_file]

-- 5) add new record and update table file_details from sheetname [file_details_database] at google sheet
select * from file_details fd ;

update file_details set date_created = unix_timestamp(now()) 
where id >= 1066 ; -- need to change the new file_no here when add new data

-- 6) import csv file from to table name [contact_numbers] 
select * from contact_numbers where file_id is null order by id desc;

select file_id, `type`, remark_1, count(*) from contact_numbers cn
where file_id >= 1066
group by file_id, `type`, remark_1 ;

alter table valid_contact_numbers convert to character set utf8mb4 collate utf8mb4_general_ci;

-- 7) update file_id in table [contact_numbers] 
update contact_numbers cn right join file_details fd on (cn.remark_1 = fd.file_no)
set cn.file_id = fd.id , cn.created_date = date(now())
where fd.id >= 1066; -- done <= 1066

select cn.* , fd.id, fd.file_no from contact_numbers cn left join file_details fd on (cn.remark_1 = fd.file_no)
where fd.id >= 1066; -- done <= 1066

-- manual
-- update contact_numbers set file_id = 1065 where file_id is null ;

select cn.* , fd.id, fd.file_no from contact_numbers cn left join file_details fd on (cn.remark_1 = fd.file_no)
where fd.id >= 1066; -- done <= 1066

-- 8) update contact number format sql: SELECT REGEXP_REPLACE('deddf2484521584sda,.;eds2', '[^[:digit:]]', '') "REGEXP_REPLACE";
select * , regexp_replace(contact_no , '[^[:digit:]]', '') ,	length (regexp_replace(contact_no , '[^[:digit:]]', '')),
	case when (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 9 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),3) = '021')
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 8 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),2) = '21' )
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 6)
		then concat('9021',right(regexp_replace(contact_no , '[^[:digit:]]', ''),6)) -- for 021
		when (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 11 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),3) = '020')
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 10 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),2) = '20')
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 8 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),1) in ('2','5','7','8','9'))
		then concat('9020',right(regexp_replace(contact_no , '[^[:digit:]]', ''),8)) -- for 020
		when (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 10 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),3) = '030')
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 9 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),2) = '30')
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 7 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),1) in ('2','4','5','7','9'))
		then concat('9030',right(regexp_replace(contact_no , '[^[:digit:]]', ''),7)) -- for 030
		when left (right (regexp_replace(contact_no , '[^[:digit:]]', ''),8),1) in ('0','1','') then concat('9030',right(regexp_replace(contact_no , '[^[:digit:]]', ''),7))
		when left (right (regexp_replace(contact_no , '[^[:digit:]]', ''),8),1) in ('2','5','7','8','9')
		then concat('9020',right(regexp_replace(contact_no , '[^[:digit:]]', ''),8))
		else concat('9020',right(regexp_replace(contact_no , '[^[:digit:]]', ''),8))
	end 'new_contact_no'
from contact_numbers cn 
where file_id >= 1066; -- done <= 1066

update contact_numbers set contact_no = 
	case when (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 9 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),3) = '021')
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 8 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),2) = '21' )
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 6)
		then concat('9021',right(regexp_replace(contact_no , '[^[:digit:]]', ''),6)) -- for 021
		when (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 11 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),3) = '020')
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 10 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),2) = '20')
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 8 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),1) in ('2','5','7','8','9'))
		then concat('9020',right(regexp_replace(contact_no , '[^[:digit:]]', ''),8)) -- for 020
		when (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 10 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),3) = '030')
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 9 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),2) = '30')
			or (length (regexp_replace(contact_no , '[^[:digit:]]', '')) = 7 and left (regexp_replace(contact_no , '[^[:digit:]]', ''),1) in ('2','4','5','7','9'))
		then concat('9030',right(regexp_replace(contact_no , '[^[:digit:]]', ''),7)) -- for 030
		when left (right (regexp_replace(contact_no , '[^[:digit:]]', ''),8),1) in ('0','1','') then concat('9030',right(regexp_replace(contact_no , '[^[:digit:]]', ''),7))
		when left (right (regexp_replace(contact_no , '[^[:digit:]]', ''),8),1) in ('2','5','7','8','9')
		then concat('9020',right(regexp_replace(contact_no , '[^[:digit:]]', ''),8))
		else concat('9020',right(regexp_replace(contact_no , '[^[:digit:]]', ''),8))
	end
where file_id >= 1066; -- done <= 1066

-- 9) check and import valid number to table valid_contact_numbers
select *, CONCAT(LENGTH(contact_no), left( contact_no, 5)) from contact_numbers 
where CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1066 ; -- done <= 1066

select * from valid_contact_numbers where file_id >= 1066;
insert into valid_contact_numbers 
(`id`,`file_id`,`contact_no`)
select `id`,`file_id`,`contact_no`
from contact_numbers 
where CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1066; -- done <= 1066

-- 10) check and import invalid number to table valid_contact_numbers
select *, CONCAT(LENGTH(contact_no), left( contact_no, 5)) from contact_numbers 
where CONCAT(LENGTH(contact_no), left( contact_no, 5)) not in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1066; -- done <= 1066

select * from invalid_contact_numbers where file_id >= 1066;
insert into invalid_contact_numbers 
(`id`,`file_id`,`contact_no`)
select `id`,`file_id`,`contact_no`
from contact_data_db.contact_numbers 
where CONCAT(LENGTH(contact_no), left( contact_no, 5)) not in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1066; -- done <= 1066

-- 11) import data to all_unique_contact_numbers
insert into all_unique_contact_numbers 
(`id`,`file_id`,`contact_no`,`type`)
select `id`,`file_id`,`contact_no`,`type`
from contact_numbers 
where CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1066; -- done <= 1066

select file_id , `type`, count(*)  from all_unique_contact_numbers aucn where file_id >= 1066 group by file_id , `type`

-- 12) Query date to expot into table removed duplicate 
-- partition by contact_no === check duplicate by contact_no
-- order by FIELD(`type` , "Have Car","Need loan","Have address","Telecom"), id === order priorities by type and id
insert into removed_duplicate
select id, row_numbers, now() `time` from ( 
		select id, row_number() over (partition by contact_no order by FIELD(`type` , "①Have Car","②Need loan","③Have address","④Telecom"), id) as row_numbers  
		from all_unique_contact_numbers 
		-- where file_id <= 1066
		) as t1
	where row_numbers > 1; -- done <= 1066

-- 13) check and remove duplicate Delete from all unique where id = id in table removed duplicate 
select * from removed_duplicate where `time` >= '2023-01-26';

delete from all_unique_contact_numbers 
where id in (select id from removed_duplicate where `time` >= '2023-01-26'); -- done <= 1066

-- 14) check and import date from contact_numbers to contact_numbers_to_lcc
select distinct province_eng from contact_numbers where file_id >= 1066;

insert into contact_numbers_to_lcc (`id`,`file_id`,`contact_no`,`name`,`province_eng`,`province_laos`,`district_eng`,`district_laos`,`village`,`type`,`maker`,`model`,`year`,`remark_1`,`remark_2`,`remark_3`,`branch_name`,`status`,`file_no`,`date_received`,`date_updated`,`pbxcdr_time`)
select cn.`id`,cn.`file_id`,cn.`contact_no`,
	case when cn.`name` = '' then null else cn.`name` end `name`, 
	case when cn.`province_eng` = '' then null else cn.`province_eng` end `province_eng`,
	case when cn.`province_laos` = '' then null else cn.`province_laos` end `province_laos`,
	case when cn.`district_eng` = '' then null else cn.`district_eng` end `district_eng`,
	case when cn.`district_laos` = '' then null else cn.`district_laos` end `district_laos`,
	case when cn.`village` = '' then null else cn.`village` end `village`,
	cn.`type`, 
	case when cn.`maker` = '' then null else cn.`maker` end `maker`,
	case when cn.`model` = '' then null else cn.`model` end `model`,
	case when cn.`year` = '' then null else cn.`year` end `year`,
	null `remark_1`,null `remark_2`,null `remark_3`,
	case when cn.province_eng = 'ATTAPUE' then 'Attapue'
		when cn.province_eng = 'BORKEO' then 'Bokeo'
		when cn.province_eng = 'BORLIKHAMXAY' then 'Paksan'
		when cn.province_eng = 'CHAMPASACK' then 'Pakse'
		when cn.province_eng = 'HUAPHAN' then 'Houaphan'
		when cn.province_eng = 'KHAMMOUAN' then 'Thakek'
		when cn.province_eng = 'LUANG PRABANG' then 'Luangprabang'
		when cn.province_eng = 'LUANGNAMTHA' then 'Luangnamtha'
		when cn.province_eng = 'OUDOMXAY' then 'Oudomxay'
		when cn.province_eng = 'PHONGSALY' then 'Oudomxay'
		when cn.province_eng = 'SALAVANH' then 'Salavan'
		when cn.province_eng = 'SAVANNAKHET' then 'Savannakhet'
		when cn.province_eng = 'VIENTIANE CAPITAL' then 'Head office'
		when cn.province_eng = 'VIENTIANE PROVINCE' then 'Vientiane province'
		when cn.province_eng = 'XAYABOULY' then 'Xainyabuli'
		when cn.province_eng = 'XAYSOMBOUN' then 'Xiengkhouang'
		when cn.province_eng = 'XEKONG' then 'Attapue'
		when cn.province_eng = 'XIENGKHUANG' then 'Xiengkhouang'
		when cn.province_eng = '' then fd.branch_name 
		when cn.province_eng is null then fd.branch_name 
		else null 
	end `branch_name` ,
	null `status`,fd.`file_no`,fd.`date_received`,date(now()) `date_updated`, 0 `pbxcdr_time`
from contact_numbers cn left join file_details fd on (fd.id = cn.file_id)
where CONCAT(LENGTH(cn.contact_no), left( cn.contact_no, 5)) in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1066; -- done <= 1066

select `type` , count(*) from contact_numbers_to_lcc cntl where file_id >= 1066 group by `type` ;

-- 15) check and remove duplicate Delete from all unique where id = id in table removed duplicate 
-- **** insert the old data to keep in table temp_merge_data for doing merge after 
delete from temp_merge_data ;

insert into temp_merge_data 
select * from contact_numbers_to_lcc 
where id in (select id from removed_duplicate where `time` >= '2023-01-26');

-- **** delete duplicate data from contact_numbers_to_lcc 
select * from temp_merge_data;

delete from contact_numbers_to_lcc where id in (select id from removed_duplicate where `time` >= '2023-01-26');

-- 16) count to check 
select cntl.file_no , cntl.`type`, count(*) from file_details fd left join contact_numbers_to_lcc cntl on (fd.id = cntl.file_id)
where fd.id >= 1066
group by cntl.file_no, cntl.`type` ;

-- 17) import data to payment table
insert into payment 
(`id`,`file_id`,`contact_no`,`name`,`province_eng`,`province_laos`,`district_eng`,`district_laos`,`village`,`type`,`maker`,`model`,`year`,`remark_1`,`remark_2`,`remark_3`,`code`,`payment_amount`)
select `id`,`file_id`,`contact_no`,`name`,`province_eng`,`province_laos`,`district_eng`,`district_laos`,`village`,`type`,`maker`,`model`,`year`,`remark_1`,`remark_2`,`remark_3`,`code`,`payment_amount`
from ( 
	select *, 
	ROUND( case when `code` = '1-1000' then 1/150
		when `code` = '1-1100' then 1/50
		when `code` = '1-1010' then 1/40
		when `code` = '1-1110' then 1/30
		when `code` = '1-1001' then 1/30
		when `code` = '1-1011' then 1/20
		when `code` = '1-1101' then 1/20
		when `code` = '1-1111' then 1/10
		when `code` = '2-1000' then 1/300
		when `code` = '2-1100' then 1/100
		when `code` = '2-1010' then 1/100
		when `code` = '2-1110' then 1/80
		when `code` = '2-1001' then 1/80
		when `code` = '2-1011' then 1/70
		when `code` = '2-1101' then 1/70
		when `code` = '2-1111' then 1/50
		when `code` = '3-1000' then 1/600
		when `code` = '3-1100' then 1/300
		when `code` = '3-1010' then 1/250
		when `code` = '3-1110' then 1/200
		when `code` = '3-1001' then 1/150
		when `code` = '3-1011' then 1/100
		when `code` = '3-1101' then 1/100
		when `code` = '3-1111' then 1/80
		else ''
	end - 0.00005, 4) `payment_amount` 
from (
		select 
			cntl .* ,
			concat( 
			case when t.id = 1 then 1 when t.id = 2 then 2 when t.id = 3 then 2 when t.id = 4 then 3 end , "-" ,
			case when cntl.contact_no != '' then 1 else 0 end ,
			case when cntl.name != '' then 1 else 0 end ,
			case when ((cntl.province_eng != '' or cntl.province_laos != '') and (cntl.district_eng != '' or cntl.district_laos != '') and cntl.village != '') != '' then 1 else 0 end ,
			case when (cntl.maker != '' or cntl.model != '') != '' then 1 else 0 end
				) `code`
		from contact_numbers_to_lcc cntl 
		left join tbltype t on (t.`type` = cntl.`type`)
		where cntl.file_id >= 1066 
		group by cntl.contact_no
	) `tblpayment`
) `data_import`;


-- 18) Check and delete the invalid numbers that SMS check
delete from temp_update_any ;

insert into temp_update_any 
select id, contact_no, remark_3 , status, pbxcdr_time  from contact_numbers_to_lcc cntl where file_id in (1058,1059) and status = 'SMS_Failed';

delete from payment where id in (select id from temp_update_any);

-- 19) Calculate to pay for Tou 623
select round(60000.26350 , 0) ;
select round(22.22289 + 0.00005, 4) 'roundup', round(22.22289 - 0.00005, 4) 'rounddown';
select round(848000.0 + 500.000, -3) 'roundup for LAK', round(100 + 4.9, -1) 'rounddown';

select '' `No.`, fd.date_received, fd.staff_no, fd.staff_name, 
	fd.broker_name, fd.broker_tel , fd.broker_work_place ,
	fd.file_no , fd.`type` , fd.number_of_original_file , 
	fd.number_of_original_file -
	case when p.file_id = 983 then ROUND(count(p.contact_no)/10,0)
		when p.file_id = 984 then ROUND(count(p.contact_no)/10,0)
		when p.file_id = 985 then ROUND(count(p.contact_no)/10,0)
		when p.file_id = 986 then ROUND(count(p.contact_no)/10,0)
		when p.file_id = 987 then ROUND(count(p.contact_no)*8/100,0)
		when p.file_id = 988 then ROUND(count(p.contact_no)/10,0)
		when p.file_id = 1039 then ROUND(count(p.contact_no)/2,0) -- from 1504	Joy it's randowm numbers
		when p.file_id = 1049 then ROUND(count(p.contact_no)/2,0) -- from 1504	Joy it's randowm numbers
		when p.file_id = 1055 then 0 -- we are already paid LAK 16.011.700,00 on 25/04/2022
		else count(p.contact_no)
	end 'count(not_pay)',
	case when p.file_id = 983 then ROUND(count(p.contact_no)/10,0)
		when p.file_id = 984 then ROUND(count(p.contact_no)/10,0)
		when p.file_id = 985 then ROUND(count(p.contact_no)/10,0)
		when p.file_id = 986 then ROUND(count(p.contact_no)/10,0)
		when p.file_id = 987 then ROUND(count(p.contact_no)*8/100,0)
		when p.file_id = 988 then ROUND(count(p.contact_no)/10,0)
		when p.file_id = 1039 then ROUND(count(p.contact_no)/2,0) -- from 1504	Joy it's randowm numbers
		when p.file_id = 1049 then ROUND(count(p.contact_no)/2,0) -- from 1504	Joy it's randowm numbers
		else count(p.contact_no)
	end 'count(to_pay)',
	case when p.file_id = 983 then sum(p.payment_amount)/10
		when p.file_id = 984 then sum(p.payment_amount)/10
		when p.file_id = 985 then sum(p.payment_amount)/10
		when p.file_id = 986 then sum(p.payment_amount)/10
		when p.file_id = 987 then sum(p.payment_amount)*8/100
		when p.file_id = 988 then sum(p.payment_amount)/10
		when p.file_id = 1039 then sum(p.payment_amount)/2 -- from 1504	Joy it's randowm numbers
		when p.file_id = 1049 then sum(p.payment_amount)/2 -- from 1504	Joy it's randowm numbers
		else sum(p.payment_amount)
	end 'calculate_amount',
	case when p.file_id = 983 then ROUND(sum(p.payment_amount)/10 ,0)
		when p.file_id = 984 then ROUND(sum(p.payment_amount)/10 ,0)
		when p.file_id = 985 then ROUND(sum(p.payment_amount)/10 ,0)
		when p.file_id = 986 then ROUND(sum(p.payment_amount)/10 ,0)
		when p.file_id = 987 then ROUND(sum(p.payment_amount)*8/100 ,0)
		when p.file_id = 988 then ROUND(sum(p.payment_amount)/10 ,0)
		when p.file_id = 1039 then ROUND(sum(p.payment_amount)/2 ,0) -- from 1504	Joy it's randowm numbers
		when p.file_id = 1049 then ROUND(sum(p.payment_amount)/2 ,0) -- from 1504	Joy it's randowm numbers
		when p.file_id = 1055 then 0 -- we already paid LAK 16.011.700,00 on 25/04/2022
		else ROUND(sum(p.payment_amount),0)
	end 'payment_amount',
	concat('file_id = ', fd.id) `remark`
from payment p 
right join file_details fd on (p.file_id = fd.id)
where fd.id >= 1058 
group by fd.id ;


select * from contact_numbers_to_lcc cntl where status is null and file_id in (1058,1059)

-- temp update status and remove inactive contact_no 
delete from temp_update_any ;
insert into temp_update_any select id, contact_no , remark_3, status, pbxcdr_time from contact_numbers_to_lcc cntl 
where file_id >= 1066 and left(contact_no, 5) in ('90302', '90202'); 

-- update 
select * from temp_update_any tua where contact_no not in (select contact_no from temp_etl_active_numbers tean);
update temp_update_any set remark_3 = 'Telecom', status = 'ETL_inactive' where contact_no not in (select contact_no from temp_etl_active_numbers tean);

update contact_numbers_to_lcc cntl left join temp_update_any tua on (cntl.id = tua.id) 
set cntl.remark_3 = tua.remark_3, cntl.status = tua.status, cntl.date_updated = date(now())
where cntl.id in (select id from temp_update_any );

delete from payment where id in (select id from temp_update_any where status = 'ETL_inactive');



-- 20 Add the numbers for table file_details 
select fd.id, cn.`numbers`, icn.`numbers`, aucn.`numbers`, p.`numbers`
from file_details fd 
left join (select file_id, count(*) `numbers` from contact_numbers group by file_id ) cn on (fd.id = cn.file_id)
left join (select file_id, count(*) `numbers` from invalid_contact_numbers icn group by file_id ) icn on (fd.id = icn.file_id)
left join (select file_id, count(*) `numbers` from all_unique_contact_numbers aucn group by file_id ) aucn on (fd.id = aucn.file_id)
left join (select file_id, count(*) `numbers` from payment p group by file_id ) p on (fd.id = p.file_id)
where fd.id >= 1066;


update file_details fd 
left join (select file_id, count(*) `numbers` from contact_numbers group by file_id ) cn on (fd.id = cn.file_id)
left join (select file_id, count(*) `numbers` from invalid_contact_numbers icn group by file_id ) icn on (fd.id = icn.file_id)
left join (select file_id, count(*) `numbers` from all_unique_contact_numbers aucn group by file_id ) aucn on (fd.id = aucn.file_id)
left join (select file_id, count(*) `numbers` from payment p group by file_id ) p on (fd.id = p.file_id)
set fd.number_of_original_file = cn.`numbers`, fd.number_of_invalid_contact = icn.`numbers`, fd.number_of_unique_contact = aucn.`numbers`, fd.number_for_payment = p.`numbers`
where fd.id >= 1066;


-- 21 Update or merge customer data from old to new 
select * from contact_numbers_to_lcc where contact_no in (select contact_no from temp_merge_data)

select * from contact_numbers_to_lcc where file_id >= 1066;
select * from temp_merge_data;

select * from temp_sms_chairman where id in (select id from temp_update_any tua);
delete from temp_sms_chairman where id in (select id from temp_update_any tua);


-- 22 export into other server
select * from contact_numbers cn where file_id >= 1066;
select * from all_unique_contact_numbers where file_id >= 1066;
select * from valid_contact_numbers vcn where file_id >= 1066;
select * from invalid_contact_numbers icn where file_id >= 1066;
select * from contact_numbers_to_lcc cntl where file_id >= 1066;
select * from temp_merge_data file_id >= 1066;
select * from removed_duplicate where `time` >= '2023-01-26';
select * from file_details fd ;


-- 23 delete data from new database as delete from old
delete from all_unique_contact_numbers 
where id in (select id from removed_duplicate where `time` >= '2023-01-26'); -- done <= 1066

delete from all_unique_contact_numbers 
where id in (select id from removed_duplicate where `time` >= '2023-01-26'); -- done <= 1066



-- 24 Insert or Export from one server to one server
-- 01)____First method_______
select * from file_details fd where id >= 1066;

select * from contact_numbers cn where file_id >= 1066;

select * from all_unique_contact_numbers aucn where file_id >= 1066;

select * from contact_numbers_to_lcc cntl where file_id >= 1066;

select * from removed_duplicate rd where `time` >= '2023-01-26';

select * from temp_merge_data tmd where file_id >= 1066;

select * from valid_contact_numbers vcn where file_id >= 1066;

select * from invalid_contact_numbers icn where file_id >= 1066;

select * from payment p where file_id >= 1066;

-- _________________________ Delete duplicate record from new database _________________________
delete from all_unique_contact_numbers 
where id in (select id from removed_duplicate where `time` >= '2023-01-26'); -- done <= 1066

delete from contact_numbers_to_lcc where id in (select id from removed_duplicate where `time` >= '2023-01-26');



-- 02) _______Second method ________
C:\Users\Advice>mysqldump -u root -p -h localhost --port 3306 contact_data_db file_details contact_numbers all_unique_contact_numbers contact_numbers_to_lcc removed_duplicate temp_merge_data valid_contact_numbers invalid_contact_numbers payment > D:\"OneDrive - LALCO lalcodb1"\"OneDrive - Lao Asean Leasing Co. Ltd"\contact_data_db\new_contact_number_20230127.sql
Enter password:

-- _________________________ Import table  _________________________ 
C:\Users\Advice>mysql -u root -p -h localhost --port 3306 contact_data_db < D:\"OneDrive - LALCO lalcodb1"\"OneDrive - Lao Asean Leasing Co. Ltd"\contact_data_db\new_contact_number_20230127.sql
Enter password:


