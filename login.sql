-- Version:  1.0
--
set termout off;
set sqlformat ansiconsole;
set linesize 400;
set pagesize 100;
set echo off;

-- Set global report directory
variable b_report_dir varchar2;
exec :b_report_dir :=  'C:\Users\ah17172\Documents\reports';

-- Get database name
variable b_database varchar2(13);
begin
   select lower(name) into :b_database from v$database;
end;
/

--
--  Load aliases
--
alias load C:\Users\ah17172\sql\simple.xml
alias load C:\Users\ah17172\sql\sqlhist.xml
alias load C:\Users\ah17172\sql\parmhist.xml
alias load C:\Users\ah17172\sql\sessions.xml
set termout on;