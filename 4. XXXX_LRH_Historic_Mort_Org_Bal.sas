/*SIGNOFF;
/* Clear log*/
DM "CLE LOG";
/*Signon to M1SF*/
%LET M1SF=M1SF 9450;
SIGNON M1SF USER=_PROMPT_;

libname awork slibref=work server=M1SF; */Work-lib on host/*;
options validvarname = any;


RSUBMIT M1SF;
libname work2cd "&temp" space=(cyl,(4000,4000)) disp=new;      

options user=work2cd;      


endrsubmit;

libname bwork slibref=work2cd server=M1SF; */Work-lib on host/*;

LIBNAME SQLSERV OLEDB BULKLOAD=YES INSERTBUFF=1000 PROPERTIES=('initial catalog'="ETZ335IH_PROJECT_JERSEY" 'Integrated Security' = "SSPI" 'Persist Security Info'=False)  
PROVIDER=sqloledb  PROMPT=NO  DATASOURCE="ETPEW\inst004" schema="DBO";



proc sql noprint;
create table temp1 as 
	select distinct Account_Number 
	
	from SQLSERV.XXXX_LRH_Historic_Mort_Acc_SAS 

	where row_no <= 500 
	and row_no > 0 
	;

	QUIT;

RSUBMIT M1SF;

proc upload data=temp1 out=temp1;run;

proc sql noprint;
	select distinct cat("'",Account_Number,"A03'")
	into :acclist separated by ', '
	from temp1;
	
	QUIT;

	endrsubmit;

	RSUBMIT M1SF;

	proc sql;
	create table acc as
	select * from connection to db2 (

	SELECT distinct 

	left(ar_id,10) as Account_Number,
	case when INIT_AVY_AMT < 0 then (INIT_AVY_AMT)*-1
	else INIT_AVY_AMT 
	end as Original_Balance,
	'Original' as Original_Balance_Category, 
	GÆLDER_FRA_DT

	FROM DKDDBPE_GEPM.EW.WH_AR_AVY_H a

	where GÆLDER_FRA_DT = (select distinct min(GÆLDER_FRA_DT) FROM DKDDBPE_GEPM.EW.WH_AR_AVY_H b where a.ar_id = b.ar_id and b.ar_id in ( &acclist ) and INIT_AVY_AMT <> 0 and GÆLDER_FRA_DT >= '2011-09-23')
	and ar_id in ( &acclist ) );
	QUIT;

	endrsubmit;


%MACRO LOAD_LIST2;
%LET OBS_NO1=500;
%LET OBS_NO2=500;
%LET OBS_NO3=1;
%DO %UNTIL(&OBS_NO3=64);
	   %LET OBS_NO2=&OBS_NO1;
       %LET OBS_NO1=%EVAL(&OBS_NO1+500);
	   %LET OBS_NO3=%EVAL(&OBS_NO3+1);

LIBNAME SQLSERV OLEDB BULKLOAD=YES INSERTBUFF=1000 PROPERTIES=('initial catalog'="ETZ335IH_PROJECT_JERSEY" 'Integrated Security' = "SSPI" 'Persist Security Info'=False)  
PROVIDER=sqloledb  PROMPT=NO  DATASOURCE="ETPEW\inst004" schema="DBO";



proc sql noprint;
create table temp1 as 
	select distinct Account_Number
	
	from SQLSERV.XXXX_LRH_Historic_Mort_Acc_SAS 

	where row_no <= &OBS_NO1 
	and row_no > &OBS_NO2
	;

	QUIT;

RSUBMIT M1SF;

proc upload data=temp1 out=temp1;run;

proc sql noprint;
	select distinct cat("'",Account_Number,"A03'")
	into :acclist separated by ', '
	from temp1;
	
	QUIT;

	endrsubmit;

	RSUBMIT M1SF;

	proc sql;
	create table acc_temp as
	select * from connection to db2 (
	SELECT distinct 

	left(ar_id,10) as Account_Number,
	case when INIT_AVY_AMT < 0 then (INIT_AVY_AMT)*-1
	else INIT_AVY_AMT 
	end as Original_Balance,
	'Original' as Original_Balance_Category, 
	GÆLDER_FRA_DT

	FROM DKDDBPE_GEPM.EW.WH_AR_AVY_H a

	where GÆLDER_FRA_DT = (select distinct min(GÆLDER_FRA_DT) FROM DKDDBPE_GEPM.EW.WH_AR_AVY_H b where a.ar_id = b.ar_id and b.ar_id in ( &acclist ) and INIT_AVY_AMT <> 0 and GÆLDER_FRA_DT >= '2011-09-23')
	and ar_id in ( &acclist ) );
	QUIT;

	endrsubmit;

	RSUBMIT M1SF;
	data acc;
  	set   acc
    acc_temp;
    run;
	ENDRSUBMIT;


	%END;
%MEND LOAD_LIST2;

%LOAD_LIST2;




RSUBMIT M1SF;

proc sql;
	create table acc_check as
	
	SELECT distinct 

	trim(account_number) as account_number

	from acc ;

	QUIT;

proc download data=acc_check out=acc_check;run;

endrsubmit;

%MACRO LOAD_LIST3;
%LET OBS_NO1=0;
%LET OBS_NO2=500;
%LET OBS_NO3=0;
%DO %UNTIL(&OBS_NO3=64);
	   %LET OBS_NO2=&OBS_NO1;
       %LET OBS_NO1=%EVAL(&OBS_NO1+500);
	   %LET OBS_NO3=%EVAL(&OBS_NO3+1);


proc sql noprint;
create table temp1 as 
	select distinct a.account_number

	
	from SQLSERV.XXXX_LRH_Historic_Mort_Acc_SAS a
	

	where a.account_number not in (select distinct Account_Number from work.acc_check)
and row_no <= &OBS_NO1 
	and row_no > &OBS_NO2;
	QUIT;

RSUBMIT M1SF;

proc upload data=temp1 out=temp1;run;

proc sql noprint;
	select distinct cat("'",Account_Number,"A03'")
	into :acclist separated by ', '
	from temp1;
	
	QUIT;

	endrsubmit;

	RSUBMIT M1SF;

	proc sql;
	create table acc_temp as
	select * from connection to db2 (

	SELECT distinct 

	left(ar_id,10) as Account_Number,
	case when INIT_AVY_AMT < 0 then (INIT_AVY_AMT)*-1
	else INIT_AVY_AMT 
	end as Original_Balance,
	'DCS' as Original_Balance_Category,
	GÆLDER_FRA_DT

	FROM DKDDBPE_GEPM.EW.WH_AR_AVY_H a

	where GÆLDER_FRA_DT = (select distinct min(GÆLDER_FRA_DT) FROM DKDDBPE_GEPM.EW.WH_AR_AVY_H b where a.ar_id = b.ar_id and b.ar_id in ( &acclist ) and (INIT_AVY_AMT > 0.1 or INIT_AVY_AMT < -0.1))
	and ar_id in ( &acclist ) );

	QUIT;

	endrsubmit;

	RSUBMIT M1SF;
	data acc;
  	set   acc
    acc_temp;
    run;
	ENDRSUBMIT;

	%END;
%MEND LOAD_LIST3;

%LOAD_LIST3;


RSUBMIT M1SF;

proc download data=acc out=acc;run;

endrsubmit;
	
/*################ Deletes existing table on server and uploads the new one ##############*/
  %macro delds;
     %if %sysfunc(exist(SQLSERV.XXXX_LRH_Historic_Mort_Org_Bal)) %then %do;
       proc datasets library=SQLSERV;
       delete XXXX_LRH_Historic_Mort_Org_Bal;
      run;
     %end; 
      %mend;
      %delds;
      run;  	 

DATA    SQLSERV.XXXX_LRH_Historic_Mort_Org_Bal;
SET     acc;
RUN;

	
	 
