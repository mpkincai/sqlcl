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
select :b_report_dir || '\' || :b_database || '_awr_' || :b_bdt || :b_edt || '.html' as s_spool_file from dual;

-- Send feedback to the user
set termout on;
exec dbms_output.put_line('Now spooling AWR to ' || '&s_spool_file');
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

Select * from table(dbms_workload_repository.awr_report_html((select dbid from v$database),1,:b_bid,:b_eid,0));

spool off;

-- Reset options
set termout on 
set head on 
set feedback on
set pagesize 100;
set sqlformat ansiconsole;

-- Undefine substitution variables
undefine begin_snap