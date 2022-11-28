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
