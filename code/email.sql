use ev_data;

drop table if exists email_sprint ;
create temporary table email_sprint 
select *
from emails
where email_subject_id = 7 and sent_date between '2016-08-10' and '2016-10-10' ;

select * from email_sprint;
-- email sent 
drop table if exists email_sent_sprint ;
create temporary table email_sent_sprint 
select count(email_id) as sent  from email_sprint ;

select * from email_sent_sprint;

-- email clicked
drop table if exists email_clicked_sprint ;
create temporary table email_clicked_sprint 
select count(email_id) as clicked  from email_sprint where clicked = 't'  ;

select * from email_clicked_sprint;

-- email open 
drop table if exists email_opened_sprint ;
create temporary table email_opened_sprint 
select count(email_id) as opened  from email_sprint where opened = 't'  ;

select * from email_opened_sprint;

-- email bounce  
drop table if exists email_bounced_sprint ;
create temporary table email_bounced_sprint 
select count(email_id) as bounced  from email_sprint where bounced = 't'  ;

select * from email_bounced_sprint;

-- KPI numbers 
-- open rate 
drop table if exists open_rate_sprint ;
create temporary table open_rate_sprint 
select round((opened/sent*100),2) as click_rate_   from email_sent_sprint, email_opened_sprint ;

select * from open_rate_sprint;

-- click rate 
drop table if exists click_rate_sprint ;
create temporary table click_rate_sprint 
select round((clicked/sent*100),2) as click_rate   from email_clicked_sprint, email_sent_sprint ;

select * from click_rate_sprint;