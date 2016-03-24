-- Get report date
column s_currdate new_value s_currdate;
select to_char(sysdate,'yyyy-mm-dd') as s_currdate from dual;

-- 
ACCEPT s_report_date CHAR DEFAULT '&s_currdate'- 
PROMPT 'Enter report date (&s_currdate'): '

-- Get starting hour and min
ACCEPT s_time CHAR-
PROMPT 'Enter report time (HH24:MI): '

--
-- Derive Report Dates
--
set echo off;
set feedback off;
set termout off;
set serverout on;
column s_edt new_value s_edt;
select to_char(to_date('&s_report_date' || ' ' || '&s_time' || ':00','yyyy-mm-dd HH24:MI:SS') + 5/1440,'HH24:MI') as s_edt from dual;

--
-- Derive spool file name
--
column s_spool_file new_value s_spool_file;
select :b_report_dir || '\' || :b_database || '_ash_' || replace('&s_report_date','-') || '_' || replace('&s_time',':') || '-' || replace('&s_edt',':') || '.html' as s_spool_file from dual;
set termout on;
exec dbms_output.put_line('Now spooling ASH to ' || '&s_spool_file');
set termout off;


set head off  
set trimspool on 
set trimout on
set pagesize 10000
set verify off
set echo off
set long 1000000
set sqlformat default;
set linesize 8000 

spool &s_spool_file

Select *
from table(dbms_workload_repository.ASH_report_html(
         l_dbid => (select dbid from v$database),
         l_inst_num => 1,
         l_btime => TO_DATE('&s_report_date' || ' ' || '&s_time' || ':00', 'yyyy-mm-dd HH24:MI:SS'),
         l_etime => TO_DATE('&s_report_date' || ' ' || '&s_edt' || ':00', 'yyyy-mm-dd HH24:MI:SS'),
         l_options => 0,
         l_slot_width => 0,
         l_sid => null,
         l_sql_id => null,
         l_wait_class => null,
         l_service_hash => null,
         l_module => null,
         l_action => null,
         l_client_id => null,
         l_plsql_entry => null))
;

spool off;

-- Reset options
set termout on 
set head on 
set feedback on
set pagesize 100;
set sqlformat ansiconsole;

-- Undefine substitution variables
undefine s_report_date
undefine c_currdate
undefine s_time
undefine s_spool_file
undefine s_edt