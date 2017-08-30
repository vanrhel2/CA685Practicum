/*SIGNOFF;
/* Clear log*/
DM "CLE LOG";
/*Signon to M1SF*/
%LET M1SF=M1SF 8450;
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
	select distinct AR_ID
	
	from SQLSERV.XXXX_LRH_Historic_Mort_Acc_SAS

	where row_no <= 1000
	and row_no > 0 ;

	QUIT;

RSUBMIT M1SF;

proc upload data=temp1 out=temp1;run;

proc sql noprint;
	select distinct cat("'",AR_ID,"'")
	into :acclist separated by ', '
	from temp1;
	
	QUIT;

	endrsubmit;

	RSUBMIT M1SF;

	proc sql;
	create table acc as
	select * from connection to db2 (

	SELECT 	*
	FROM	DKDDBPE_GEPM.EW.EWWH_OVERTRK_FEB_H 
	WHERE	ar_id in ( &acclist ) 
	);
	QUIT;

	endrsubmit;


%MACRO LOAD_LIST2;
%LET OBS_NO1=1000;
%LET OBS_NO2=1000;
%LET OBS_NO3=1;
%DO %UNTIL(&OBS_NO3=32);
	   %LET OBS_NO2=&OBS_NO1;
       %LET OBS_NO1=%EVAL(&OBS_NO1+1000);
	   %LET OBS_NO3=%EVAL(&OBS_NO3+1);

LIBNAME SQLSERV OLEDB BULKLOAD=YES INSERTBUFF=1000 PROPERTIES=('initial catalog'="ETZ335IH_PROJECT_JERSEY" 'Integrated Security' = "SSPI" 'Persist Security Info'=False)  
PROVIDER=sqloledb  PROMPT=NO  DATASOURCE="ETPEW\inst004" schema="DBO";



proc sql noprint;
create table temp1 as 
	select distinct AR_ID
	
	from SQLSERV.XXXX_LRH_Historic_Mort_Acc_SAS

	where row_no <= &OBS_NO1 
	and row_no > &OBS_NO2;

	QUIT;

RSUBMIT M1SF;

proc upload data=temp1 out=temp1;run;

proc sql noprint;
	select distinct cat("'",AR_ID,"'")
	into :acclist separated by ', '
	from temp1;
	
	QUIT;

	endrsubmit;

	RSUBMIT M1SF;

	proc sql;
	create table acc_temp as
	select * from connection to db2 
	(
		SELECT 	*
		FROM	DKDDBPE_GEPM.EW.EWWH_OVERTRK_FEB_H 
		WHERE	ar_id in ( &acclist ) 
	);
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

proc download data=acc out=acc;run;

endrsubmit;
	
/*################ Deletes existing table on server and uploads the new one ##############*/
  %macro delds;
     %if %sysfunc(exist(SQLSERV.XXXX_LRH_Historic_Mort_Arrears)) %then %do;
       proc datasets library=SQLSERV;
       delete XXXX_LRH_Historic_Mort_Arrears;
      run;
     %end; 
      %mend;
      %delds;
      run;  	 

DATA    SQLSERV.XXXX_LRH_Historic_Mort_Arrears;
SET     acc;
RUN;

	
	 
