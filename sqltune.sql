set serverout on;
set termout off;
set echo off;

DECLARE
   v_id VARCHAR2(100);
   v_task_name VARCHAR2 (60);

BEGIN   
   v_task_name := 'MARTY_SQLTUNE';
   BEGIN
      DBMS_SQLTUNE.DROP_TUNING_TASK (TASK_NAME => v_task_name);
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;
   v_id := DBMS_SQLTUNE.CREATE_TUNING_TASK (
      SQL_ID      => '&1',
      SCOPE       => DBMS_SQLTUNE.SCOPE_COMPREHENSIVE,
      TIME_LIMIT  => 600,
      TASK_NAME   => v_task_name,
      DESCRIPTION => v_task_name);

   DBMS_SQLTUNE.EXECUTE_TUNING_TASK(TASK_NAME => v_task_name);
END;
/

-- Derive spool file name
column s_spool_file new_value s_spool_file;
select :b_report_dir || '\' || :b_database || '_sqltune_' || to_char(sysdate,'yyyymmdd') || '_' || '&1' || '.txt' as s_spool_file from dual;

-- Send feedback to the user
set termout on;
exec dbms_output.put_line('Now spooling AWR to ' || '&s_spool_file');

-- Generate sqltune output
set head off 
set feedback off 
set trimspool on 
set trimout on
set pagesize 0
set verify off
set echo off
set linesize 200;
set long 100000;
--set sqlformat default;
column report_text format a80;

spool &s_spool_file

SELECT  DBMS_SQLTUNE.REPORT_TUNING_TASK('MARTY_SQLTUNE') report_text from dual;

spool off;

-- Reset options
set termout on 
set header on 
set feedback on
set pagesize 100
set verify on
--set sqlformat ansiconsole;

-- Undefine substitution variables
