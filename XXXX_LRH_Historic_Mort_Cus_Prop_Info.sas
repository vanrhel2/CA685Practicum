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
      EJ.SIK_OBJEKT_ID AS SIK_OBJEKT_ID
      ,EJ.PROPERTY_ADDR1 AS PROPERTY_ADDR_LINE_1
      ,EJ.PROPERTY_ADDR2 AS PROPERTY_ADDR_LINE_2
      ,EJ.PROPERTY_ADDR3 AS PROPERTY_ADDR_LINE_3
      ,EJ.PROPERTY_ADDR4 AS PROPERTY_ADDR_LINE_4
      ,EJ.PROPERTY_ADDR5 AS PROPERTY_ADDR_LINE_5
      ,TX14.SIK_TXT In_Dublin

    FROM  DKDDBPE_DB2P.SI.SI_EJENDOM_H EJ

	  LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_GLOBALE_TYPER_S TX14
        ON EJ.CENTRAL_LOC_TP = TX14.SIK_KODE_ID
        AND TX14.SIK_KODE_TP = 'YES_NO_TYPE'
        AND TX14.SIK_DIALOG = 'NIB'
        AND TX14.SPKD = 'EN'

	WHERE EJ.MTTS = (SELECT max(EJ1.MTTS) FROM DKDDBPE_DB2P.SI.SI_EJENDOM_H EJ1 where EJ.SIK_OBJEKT_ID = EJ1.SIK_OBJEKT_ID)
	and EJ.SIK_OBJEKT_ID in ( &proplist ) );

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
      EJ.SIK_OBJEKT_ID AS SIK_OBJEKT_ID
      ,EJ.PROPERTY_ADDR1 AS PROPERTY_ADDR_LINE_1
      ,EJ.PROPERTY_ADDR2 AS PROPERTY_ADDR_LINE_2
      ,EJ.PROPERTY_ADDR3 AS PROPERTY_ADDR_LINE_3
      ,EJ.PROPERTY_ADDR4 AS PROPERTY_ADDR_LINE_4
      ,EJ.PROPERTY_ADDR5 AS PROPERTY_ADDR_LINE_5
      ,TX14.SIK_TXT In_Dublin

    FROM  DKDDBPE_DB2P.SI.SI_EJENDOM_H EJ

	  LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_GLOBALE_TYPER_S TX14
        ON EJ.CENTRAL_LOC_TP = TX14.SIK_KODE_ID
        AND TX14.SIK_KODE_TP = 'YES_NO_TYPE'
        AND TX14.SIK_DIALOG = 'NIB'
        AND TX14.SPKD = 'EN'

	WHERE EJ.MTTS = (SELECT max(EJ1.MTTS) FROM DKDDBPE_DB2P.SI.SI_EJENDOM_H EJ1 where EJ.SIK_OBJEKT_ID = EJ1.SIK_OBJEKT_ID)
	and EJ.SIK_OBJEKT_ID in ( &proplist ) );

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
     %if %sysfunc(exist(SQLSERV.XXXX_LRH_Historic_Mort_Prop_Info)) %then %do;
       proc datasets library=SQLSERV;
       delete XXXX_LRH_Historic_Mort_Prop_Info;
      run;
     %end; 
      %mend;
      %delds;
      run;  	 

DATA    SQLSERV.XXXX_LRH_Historic_Mort_Prop_Info;
SET     Prop_Final;
RUN;
