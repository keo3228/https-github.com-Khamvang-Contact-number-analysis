#============== Analysis ================
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


