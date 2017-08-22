/*SIGNOFF _all_;
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
	select distinct AFTALE_ID 
	
	from SQLSERV.XXXX_LRH_Historic_Mort_Prop_SAS 

	where row_no <= 1000 
	and row_no > 0 
	;

	QUIT;

RSUBMIT M1SF;

proc upload data=temp1 out=temp1;run;

proc sql noprint;
	select distinct cat("'",AFTALE_ID,"'")
	into :proplist separated by ', '
	from temp1;
	
	QUIT;

	endrsubmit;

RSUBMIT M1SF;

	proc sql;
	create table Prop as
	select * from connection to db2 (

	SELECT DISTINCT
      SS.SIK_OBJEKT_ID AS SIK_OBJEKT_ID
      ,SS.VALUED_BY AS Valued_By
      ,SS.VALUE_DT AS Value_Date
      ,SS.VALUE_BLB AS Value_Bal
	  ,SS.VALUE_VAKD AS Value_Cur
	  ,SS.MTTS as Value_Time
      ,TX7.SIK_TXT AS Value_Type_Txt

    FROM  DKDDBPE_DB2P.SI.SI_VALUE_H SS

	LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_GLOBALE_TYPER_S TX7
    ON SS.VALUE_TP = TX7.SIK_KODE_ID
    AND TX7.SIK_KODE_TP = 'VALH_VALUE'
    AND TX7.SIK_DIALOG = 'NIB'
    AND TX7.SPKD = 'EN'

	WHERE SS.SIK_OBJEKT_ID in ( &proplist ));

	QUIT;

	endrsubmit;


	%MACRO LOAD_LIST2;
%LET OBS_NO1=1000;
%LET OBS_NO2=1000;
%LET OBS_NO3=1;
%DO %UNTIL(&OBS_NO3=47);
	   %LET OBS_NO2=&OBS_NO1;
       %LET OBS_NO1=%EVAL(&OBS_NO1+1000);
	   %LET OBS_NO3=%EVAL(&OBS_NO3+1);

LIBNAME SQLSERV OLEDB BULKLOAD=YES INSERTBUFF=1000 PROPERTIES=('initial catalog'="ETZ335IH_PROJECT_JERSEY" 'Integrated Security' = "SSPI" 'Persist Security Info'=False)  
PROVIDER=sqloledb  PROMPT=NO  DATASOURCE="ETPEW\inst004" schema="DBO";



proc sql noprint;
create table temp1 as 
	select distinct AFTALE_ID 
	
	from SQLSERV.XXXX_LRH_Historic_Mort_Prop_SAS 

	where row_no <= &OBS_NO1 
	and row_no > &OBS_NO2
	;

	QUIT;

RSUBMIT M1SF;

proc upload data=temp1 out=temp1;run;

proc sql noprint;
	select distinct cat("'",AFTALE_ID,"'")
	into :proplist separated by ', '
	from temp1;
	
	QUIT;

	endrsubmit;

RSUBMIT M1SF;

	proc sql;
	create table Prop_temp as
	select * from connection to db2 (

SELECT DISTINCT
      SS.SIK_OBJEKT_ID AS SIK_OBJEKT_ID
      ,SS.VALUED_BY AS Valued_By
      ,SS.VALUE_DT AS Value_Date
      ,SS.VALUE_BLB AS Value_Bal
	  ,SS.VALUE_VAKD AS Value_Cur
	  ,SS.MTTS as Value_Time
      ,TX7.SIK_TXT AS Value_Type_Txt

    FROM  DKDDBPE_DB2P.SI.SI_VALUE_H SS

	LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_GLOBALE_TYPER_S TX7
    ON SS.VALUE_TP = TX7.SIK_KODE_ID
    AND TX7.SIK_KODE_TP = 'VALH_VALUE'
    AND TX7.SIK_DIALOG = 'NIB'
    AND TX7.SPKD = 'EN'

	WHERE SS.SIK_OBJEKT_ID in ( &proplist ));

	QUIT;

	endrsubmit;

	RSUBMIT M1SF;
	data Prop;
  	set   Prop
    Prop_temp;
    run;
	ENDRSUBMIT;


	%END;
%MEND LOAD_LIST2;

%LOAD_LIST2;


RSUBMIT M1SF;

data Prop_Final; SET Prop;

SIK_OBJEKT_ID_TXT=left(put(SIK_OBJEKT_ID,datetime26.6));
SIK_OBJEKT_ID_DT=put(datepart(SIK_OBJEKT_ID),yymmddd10.)!!'-'!!substr(SIK_OBJEKT_ID_TXT,11,2)!!'.'!!substr(SIK_OBJEKT_ID_TXT,14,2)!!'.'!!substr(SIK_OBJEKT_ID_TXT,17);  

RUN;


proc download data=Prop_Final out=Prop_Final;run;

endrsubmit;

	
/*################ Deletes existing table on server and uploads the new one ##############*/
  %macro delds;
     %if %sysfunc(exist(SQLSERV.XXXX_LRH_Historic_Mort_Prop_Val)) %then %do;
       proc datasets library=SQLSERV;
       delete XXXX_LRH_Historic_Mort_Prop_Val;
      run;
     %end; 
      %mend;
      %delds;
      run;  	 

DATA    SQLSERV.XXXX_LRH_Historic_Mort_Prop_Val;
SET     Prop_Final;
RUN;
