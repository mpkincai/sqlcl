set serverout on;
set feedback off;
set pagesize 100;
SELECT SNAP_ID
     , BEGIN_INTERVAL_TIME 
  FROM DBA_HIST_SNAPSHOT
 WHERE BEGIN_INTERVAL_TIME >= sysdate - 12/24
 ORDER BY BEGIN_INTERVAL_TIME DESC
;

prompt Please select a target snap ID
prompt Begin Snapshot Id specified: &&begin_snap

-- Define bind variables
set termout off;
set verify off;
variable b_bid number;
variable b_eid number;
variable b_bdt varchar2(12);
variable b_edt varchar2(5);

begin
  :b_bid        := &begin_snap;
  :b_eid        := :b_bid + 1;
  select to_char(begin_interval_time,'yyyymmdd_HH24MI')
       , to_char(end_interval_time,'-HH24MI')
    into :b_bdt
       , :b_edt 
    from dba_hist_snapshot 
   where snap_id = :b_eid
  ;
end;
/

-- Derive spool file name
column s_spool_file new_value s_spool_file;
select :b_report_dir || '\' || :b_database || '_addm_' || :b_bdt || :b_edt || '.txt' as s_spool_file from dual;

BEGIN
   DECLARE
      v_task_name VARCHAR2 (60);
   BEGIN
      v_task_name := 'MARTY';
      for I in(select task_name from dba_advisor_tasks where task_name = v_task_name and owner=USER)
      loop
         dbms_advisor.delete_task (v_task_name);
      END LOOP;

      dbms_advisor.create_task(advisor_name => 'ADDM', task_name => v_task_name);
      dbms_advisor.set_task_parameter(v_task_name, 'START_SNAPSHOT',:b_bid);
      dbms_advisor.set_task_parameter(v_task_name, 'END_SNAPSHOT',:b_eid);
      dbms_advisor.set_task_parameter(v_task_name, 'INSTANCE', 1);
--    dbms_advisor.set_task_parameter(v_task_name, 'DB_ID', 3951017604);
      dbms_advisor.execute_task(v_task_name);
   END;
END;
/

-- Send feedback to the user
set termout on;
exec dbms_output.put_line('Now spooling ADDM to ' || '&s_spool_file');
set termout off;

set head off 
set feedback off 
set trimspool on 
set trimout on
set pagesize 10000
set verify off
set echo off
set long 1000000
set sqlformat default;
set linesize 8000 
column get_clob format a80;

spool &s_spool_file

select DBMS_ADVISOR.GET_TASK_REPORT('MARTY','TEXT','ALL','ALL',USER) report 
  from dual
;

spool off;

-- Reset options
set termout on 
set head on 
set feedback on
set pagesize 100;
set sqlformat ansiconsole;

-- Undefine substitution variables
undefine begin_snap