-- _____________________________________________________________________________________________________________________________ --
#============ The step to insert new contact numbers to my database ================
-- 1) check the current data in contact_numbers before import new 
select * from contact_numbers where remark_1 in ('1233','1234','1235','1236','1237','1238','1239','1240','1241','1242') ;
-- result: 0 row
select * from contact_numbers order by id desc limit 10;
-- result: last id 47610791 and last file_id 1064
select * from file_details order by id desc;
id  |file_no|file_name                  
----+-------+---------------------------
1063|1254   |1254_JING_3306_20220929_CSV

-- 2) open the googlessheets link: [https://docs.google.com/spreadsheets/d/1e6i-Xhnb7VhSkgSuSlzOhLs53gasV-DiwbOcSftcVdQ/edit#gid=115262897]

-- 3) convert file .xlsx to file .csv download files from sheetname [Upload_Excel_file] 

-- 4) upload file .csv to sheetname [Upload_CSV_file]

-- 5) add new record and update table file_details from sheetname [file_details_database] at google sheet
select * from file_details fd ;

update file_details set date_created = unix_timestamp(now()) 
where id >= 1064 ; -- need to change the new file_no here when add new data

-- 6) import csv file from to table name [contact_numbers] 
select * from contact_numbers where file_id is null order by id desc;

select file_id, `type`, remark_1, count(*) from contact_numbers cn
where file_id >= 1064
group by file_id, `type`, remark_1 ;

alter table valid_contact_numbers convert to character set utf8mb4 collate utf8mb4_general_ci;

-- 7) update file_id in table [contact_numbers] 
update contact_numbers cn right join file_details fd on (cn.remark_1 = fd.file_no)
set cn.file_id = fd.id , cn.created_date = date(now())
where fd.id >= 1064; -- done <= 1064

select cn.* , fd.id, fd.file_no from contact_numbers cn left join file_details fd on (cn.remark_1 = fd.file_no)
where fd.id >= 1064; -- done <= 1064

-- manual
-- update contact_numbers set file_id = 1065 where file_id is null ;

select cn.* , fd.id, fd.file_no from contact_numbers cn left join file_details fd on (cn.remark_1 = fd.file_no)
where fd.id >= 1064; -- done <= 1064

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
where file_id >= 1064; -- done <= 1064


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
where file_id >= 1064; -- done <= 1064

-- 9) check and import valid number to table valid_contact_numbers
select *, CONCAT(LENGTH(contact_no), left( contact_no, 5)) from contact_numbers 
where CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1064 ; -- done <= 1064

select * from valid_contact_numbers where file_id >= 1064;
insert into valid_contact_numbers 
(`id`,`file_id`,`contact_no`)
select `id`,`file_id`,`contact_no`
from contact_numbers 
where CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1064; -- done <= 1064

-- 10) check and import invalid number to table valid_contact_numbers
select *, CONCAT(LENGTH(contact_no), left( contact_no, 5)) from contact_numbers 
where CONCAT(LENGTH(contact_no), left( contact_no, 5)) not in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1064; -- done <= 1064

select * from invalid_contact_numbers where file_id >= 1064;
insert into invalid_contact_numbers 
(`id`,`file_id`,`contact_no`)
select `id`,`file_id`,`contact_no`
from contact_data_db.contact_numbers 
where CONCAT(LENGTH(contact_no), left( contact_no, 5)) not in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1064; -- done <= 1064

-- 11) import data to all_unique_contact_numbers
insert into all_unique_contact_numbers 
(`id`,`file_id`,`contact_no`,`type`)
select `id`,`file_id`,`contact_no`,`type`
from contact_numbers 
where CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190302','1190304','1190305','1190307','1190309','1290202','1290205','1290207','1290208','1290209')
	and file_id >= 1064; -- done <= 1064

select file_id , `type`, count(*)  from all_unique_contact_numbers aucn where file_id >= 1064 group by file_id , `type`

-- 12) Query date to expot into table removed duplicate 
-- partition by contact_no === check duplicate by contact_no
-- order by FIELD(`type` , "Have Car","Need loan","Have address","Telecom"), id === order priorities by type and id
insert into removed_duplicate
select id, row_numbers, now() `time` from ( 
		select id, row_number() over (partition by contact_no order by FIELD(`type` , "Have Car","Need loan","Have address","Telecom"), id) as row_numbers  
		from all_unique_contact_numbers 
		where file_id <= 1064
		) as t1
	where row_numbers > 1; -- done <= 1064

-- 13) check and remove duplicate Delete from all unique where id = id in table removed duplicate 
delete from all_unique_contact_numbers 
where id in (select id from removed_duplicate where `time` >= '2022-11-28'); -- done <= 1064

-- 14) check and import date from contact_numbers to contact_numbers_to_lcc
select distinct province_eng from contact_numbers where file_id >= 1064;
