
-- ____________________________________ Export to report source all ____________________________________ --
select * , count(*) from
	(
	select  cntl.branch_name , cntl.province_eng , cntl.`type` , fd.category , fd.category2 ,
		case when cntl.province_eng is not null and cntl.district_eng is not null and cntl.village is not null then 'have_address' else 'no_address' end `address`,
		case when cntl.maker is not null and cntl.model is not null then 'have_car' else 'no_car' end `car_info`,
		case when cntl.remark_3 = 'contracted' then 'contracted'
			when cntl.remark_3 = 'ringi_not_contract' then 'ringi_not_contract'
			when cntl.remark_3 = 'aseet_not_contract' then 'aseet_not_contract'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('S','A','B','C') then 'prospect_sabc'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('F') then 'prospect_f'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('G','G1','G2') then 'prospect_g'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('X') then 'contracted'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'ANSWERED' then 'ANSWERED'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'NO ANSWER' then 'NO ANSWER'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_active' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_inactive' then 'Telecom_inactive'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_success' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_Failed' then 'Telecom_inactive'
			else cntl.remark_3 
		end `result` 
	from contact_numbers_to_lcc cntl left join file_details fd on (fd.id = cntl.file_id)
	--  where cntl.id in (select id from temp_sms_chairman tean where status = 1) -- to export the rank F & G the SMS success
	) t
group by branch_name , province_eng , `type` , category , category2 , `address`, `car_info`, `result` ;

-- ____________________________________ Export to report monthly ____________________________________ --
select * , count(*) from 
	(
	select  cntl.branch_name , cntl.province_eng , cntl.`type` , fd.category , fd.category2 ,
		case when cntl.province_eng is not null and cntl.district_eng is not null and cntl.village is not null then 'have_address' else 'no_address' end `address`,
		case when cntl.maker is not null and cntl.model is not null then 'have_car' else 'no_car' end `car_info`,
		case when cntl.remark_3 = 'contracted' then 'contracted'
			when cntl.remark_3 = 'ringi_not_contract' then 'ringi_not_contract'
			when cntl.remark_3 = 'aseet_not_contract' then 'aseet_not_contract'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('S','A','B','C') then 'prospect_sabc'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('F') then 'prospect_f'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('G','G1','G2') then 'prospect_g'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('X') then 'contracted'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'ANSWERED' then 'ANSWERED'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'NO ANSWER' then 'NO ANSWER'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_active' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_inactive' then 'Telecom_inactive'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_success' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_Failed' then 'Telecom_inactive'
			else cntl.remark_3 
		end `result`,
		case when cntl.remark_2 = 'contracted' then 'contracted'
			when cntl.remark_2 = 'ringi_not_contract' then 'ringi_not_contract'
			when cntl.remark_2 = 'aseet_not_contract' then 'aseet_not_contract'
			when cntl.remark_2 = 'prospect_sabc' and cntl.status_updated in ('S','A','B','C') then 'prospect_sabc'
			when cntl.remark_2 = 'prospect_sabc' and cntl.status_updated in ('F') then 'prospect_f'
			when cntl.remark_2 = 'prospect_sabc' and cntl.status_updated in ('G','G1','G2') then 'prospect_g'
			when cntl.remark_2 = 'prospect_sabc' and cntl.status_updated in ('X') then 'contracted'
			when cntl.remark_2 = 'pbx_cdr' and cntl.status_updated = 'ANSWERED' then 'ANSWERED'
			when cntl.remark_2 = 'pbx_cdr' and cntl.status_updated = 'NO ANSWER' then 'NO ANSWER'
			when cntl.remark_2 = 'Telecom' and cntl.status_updated = 'ETL_active' then 'Telecom_active'
			when cntl.remark_2 = 'Telecom' and cntl.status_updated = 'ETL_inactive' then 'Telecom_inactive'
			when cntl.remark_2 = 'Telecom' and cntl.status_updated = 'SMS_success' then 'Telecom_active'
			when cntl.remark_2 = 'Telecom' and cntl.status_updated = 'SMS_Failed' then 'Telecom_inactive'
			else cntl.remark_2 
		end `new_result`
	from contact_for_202211_lcc cntl left join file_details fd on (fd.id = cntl.file_id)
	) t
group by branch_name ,  province_eng , `type` , category , category2 , `address`, `car_info`, `result`, `new_result` ;


update contact_for_202211_lcc set remark_2 = null where remark_2 not in ('contracted','ringi_not_contract','aseet_not_contract','prospect_sabc','pbx_cdr','Telecom')


select id , contact_no, remark_2 , status_updated from contact_for_202211_lcc cfl where remark_2 = 'contracted' or (remark_2 = 'prospect_sabc' and status_updated in ('X'))


-- ____________________________________ Export to report source all that not yet call last month ____________________________________ --
select * , count(*) from
	(
	select  cntl.branch_name , cntl.province_eng , cntl.`type` , fd.category , fd.category2 ,
		case when cntl.province_eng is not null and cntl.district_eng is not null and cntl.village is not null then 'have_address' else 'no_address' end `address`,
		case when cntl.maker is not null and cntl.model is not null then 'have_car' else 'no_car' end `car_info`,
		case when cntl.remark_3 = 'contracted' then 'contracted'
			when cntl.remark_3 = 'ringi_not_contract' then 'ringi_not_contract'
			when cntl.remark_3 = 'aseet_not_contract' then 'aseet_not_contract'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('S','A','B','C') then 'prospect_sabc'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('F') then 'prospect_f'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('G','G1','G2') then 'prospect_g'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('X') then 'contracted'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'ANSWERED' then 'ANSWERED'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'NO ANSWER' then 'NO ANSWER'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_active' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_inactive' then 'Telecom_inactive'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_success' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_Failed' then 'Telecom_inactive'
			else cntl.remark_3 
		end `result` 
	from contact_numbers_to_lcc cntl left join file_details fd on (fd.id = cntl.file_id)
	where cntl.id in (select id from contact_for_202211_lcc where status_updated is not null) -- to export the rank F & G the SMS success
	) t
group by branch_name , province_eng , `type` , category , category2 , `address`, `car_info`, `result` ;


-- ____________________________________ Export to report each telecom ____________________________________ --
select * , count(*) from
	(
	select case when CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190302', '1290202') then 'ETL'
			when CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190305', '1290205') then 'LTC'
			when CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190307', '1290207') then 'Beeline'
			when CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1290202','1290208') then 'Besttelecom'
			when CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190304', '1190309', '1290209') then 'Unitel'
		end `telecom`,
		left( contact_no, 4) `numbers`,
	case when cntl.remark_3 = 'contracted' then 'contracted'
			when cntl.remark_3 = 'ringi_not_contract' then 'ringi_not_contract'
			when cntl.remark_3 = 'aseet_not_contract' then 'aseet_not_contract'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('S','A','B','C') then 'prospect_sabc'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('F') then 'prospect_f'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('G','G1','G2') then 'prospect_g'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('X') then 'contracted'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'ANSWERED' then 'ANSWERED'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'NO ANSWER' then 'NO ANSWER'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_active' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_inactive' then 'Telecom_inactive'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_success' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_Failed' then 'Telecom_inactive'
			else cntl.remark_3 
		end `result` 
	from contact_numbers_to_lcc cntl 
		) t
group by `telecom`, `numbers`, `result` ;


-- ____________________________________ Export to report source all telecom check ____________________________________ --
select * , count(*) from
	(
	select  cntl.branch_name , cntl.province_eng , cntl.`type` , fd.category , fd.category2 ,
		case when cntl.province_eng is not null and cntl.district_eng is not null and cntl.village is not null then 'have_address' else 'no_address' end `address`,
		case when cntl.maker is not null and cntl.model is not null then 'have_car' else 'no_car' end `car_info`,
		case when cntl.remark_3 = 'contracted' then 'contracted'
			when cntl.remark_3 = 'ringi_not_contract' then 'ringi_not_contract'
			when cntl.remark_3 = 'aseet_not_contract' then 'aseet_not_contract'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('S','A','B','C') then 'prospect_sabc'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('F') then 'prospect_f'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('G','G1','G2') then 'prospect_g'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('X') then 'contracted'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'ANSWERED' then 'ANSWERED'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'NO ANSWER' then 'NO ANSWER'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_active' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_inactive' then 'Telecom_inactive'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_success' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_Failed' then 'Telecom_inactive'
			else cntl.remark_3 
		end `result` 
	from contact_numbers_to_lcc cntl left join file_details fd on (fd.id = cntl.file_id)
	where cntl.id in (select id from temp_sms_chairman tean where status = 1 ) -- SMS check
		or cntl.id in (select id from temp_etl_active_numbers tean2 ) -- ETL active
	) t
group by branch_name , province_eng , `type` , category , category2 , `address`, `car_info`, `result` ;


-- ____________________________________ Export to report source all SMS success and ETL active ____________________________________ --
select * , count(*) from
	(
	select  cntl.branch_name , cntl.province_eng , cntl.`type` , fd.category , fd.category2 ,
		case when cntl.province_eng is not null and cntl.district_eng is not null and cntl.village is not null then 'have_address' else 'no_address' end `address`,
		case when cntl.maker is not null and cntl.model is not null then 'have_car' else 'no_car' end `car_info`,
		case when cntl.remark_3 = 'contracted' then 'contracted'
			when cntl.remark_3 = 'ringi_not_contract' then 'ringi_not_contract'
			when cntl.remark_3 = 'aseet_not_contract' then 'aseet_not_contract'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('S','A','B','C') then 'prospect_sabc'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('F') then 'prospect_f'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('G','G1','G2') then 'prospect_g'
			when cntl.remark_3 = 'prospect_sabc' and cntl.status in ('X') then 'contracted'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'ANSWERED' then 'ANSWERED'
			when cntl.remark_3 = 'pbx_cdr' and cntl.status = 'NO ANSWER' then 'NO ANSWER'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_active' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'ETL_inactive' then 'Telecom_inactive'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_success' then 'Telecom_active'
			when cntl.remark_3 = 'Telecom' and cntl.status = 'SMS_Failed' then 'Telecom_inactive'
			else cntl.remark_3 
		end `result` 
	from contact_numbers_to_lcc cntl left join file_details fd on (fd.id = cntl.file_id)
	 where cntl.id in (select id from temp_sms_chairman tean where status = 1) -- to export the rank F & G the SMS success
	 	or cntl.id in (select id from temp_etl_active_numbers tean2 ) -- ETL active
	) t
group by branch_name , province_eng , `type` , category , category2 , `address`, `car_info`, `result` ;



-- ____________________________________ Export to report SMS status ____________________________________ --
select date_created, telecom, old_status , status , count(*) 
from temp_sms_chairman -- where date_updated >= '2022-09-01' 
group by date_created, telecom, old_status, status ;

-- ____________________________________ Export to report Pending for SMS checking ____________________________________ --
select case when CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190302', '1290202') then 'ETL'
		when CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190305', '1290205') then 'LTC'
		when CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190307', '1290207') then 'Beeline'
		when CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1290208') then 'Besttelecom'
		when CONCAT(LENGTH(contact_no), left( contact_no, 5)) in ('1190304', '1190309', '1290209') then 'Unitel'
	end `telecom`,
	count(case when status in ('F') then 1 end) 'F',
	count(case when status in ('G','G1','G2') then 1 end) 'G',
	count(case when status is null then 1 end) 'null'
from contact_numbers_to_lcc 
where (status is null or status in ('F','G','G1','G2')) and id not in (select id from temp_sms_chairman) --  where status in (1,2)
	and CONCAT(LENGTH(contact_no), left( contact_no, 5)) not in ('1190302', '1290202') 
group by telecom;



/* ___________________________ Order 2023-01-13 ___________________________ */
-- 1_)
select id, staff_no , staff_name , `type` , category , number_of_original_file, date_received  from file_details fd 

-- 2_)
select file_id , count(*) 
from contact_numbers_to_lcc cntl 
group by file_id ;

-- 3_)
select file_id , count(*) 
from contact_numbers_to_lcc cntl 
where cntl.id in (select id from temp_sms_chairman tean where status = 1) -- to export the rank F & G the SMS success
	 	or cntl.id in (select id from temp_etl_active_numbers tean2 ) -- ETL active
	 	or cntl.remark_3 = 'contracted'
	 	or cntl.remark_3 = 'ringi_not_contract' 
	 	or cntl.remark_3 = 'aseet_not_contract'
	 	or (cntl.remark_3 = 'prospect_sabc' and cntl.status in ('S','A','B','C'))
	 	or cntl.status = 'ANSWERED'
group by file_id ;


-- 4_) 
select province_eng , district_eng , count(*) 
from village_master_project vmp 
group by province_eng , district_eng;




