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
	select distinct CUSTOMER_ID 
	
	from SQLSERV.XXXX_LRH_Historic_Mort_Cus_SAS 

	where row_no <= 1 
	and row_no > 0 
	;

	QUIT;

RSUBMIT M1SF;

proc upload data=temp1 out=temp1;run;

proc sql noprint;
	select distinct cat("'",CUSTOMER_ID,"'")
	into :cuslist separated by ', '
	from temp1;
	
	QUIT;

	endrsubmit;

RSUBMIT M1SF;

	proc sql;
	create table Prop as
	select * from connection to db2 (

SELECT DISTINCT
      CC.KNID AS CUSTOMER_ID
      ,RS.AFTALE_NR AS AGR_NO_WITHIN_CUST
      ,OD.sik_objekt_id AS SIK_OBJEKT_ID
      ,AG.SIK_AFTALE_ID AS AGR_UNIQUE_ID
      ,OV.sik_objekt_id AS AGR_UNIQUE_ID2
      ,TX3.SIK_TXT AS COLLATERAL_TYPE_DESC
      ,RS.UDSTED_DT AS AGREEMENT_DATE
      ,CASE WHEN SUBSTR(TX5.SIK_TXT,1,20) is null then 'Total exposure' else SUBSTR(TX5.SIK_TXT,1,20)end AS AS_SEC_FOR
      ,FA.FORRETNING_ID AS AS_SEC_FOR_ACC_ID
/*      ,FA.MTTS AS AS_SEC_FOR_ACC_TIME*/
/*      ,FA.AKTRTP AS AS_SEC_FOR_ACC_STATUS*/
      ,EJ.PROPERTY_ADDR1 AS PROPERTY_ADDR_LINE_1
      ,EJ.PROPERTY_ADDR2 AS PROPERTY_ADDR_LINE_2
      ,EJ.PROPERTY_ADDR3 AS PROPERTY_ADDR_LINE_3
      ,EJ.PROPERTY_ADDR4 AS PROPERTY_ADDR_LINE_4
      ,EJ.PROPERTY_ADDR5 AS PROPERTY_ADDR_LINE_5
      ,TX14.SIK_TXT In_Dublin

    FROM  DKDDBPE_DB2P.SI.SI_KUNDE_H CC

      JOIN DKDDBPE_DB2P.SI.SI_ROLLE_H RO
        ON CC.SIK_KUNDE_ID = RO.SIK_KUNDE_ID
        AND RO.ROLLE_TP ^= 51131

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_AFTALE_H AG
        ON RO.SIK_AFTALE_ID = AG.SIK_AFTALE_ID

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_OBJEKT_VURD_H OV
        ON AG.SIK_AFTALE_ID = OV.SIK_AFTALE_ID

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_OBJEKT_H OD
        ON OV.SIK_OBJEKT_ID = OD.SIK_OBJEKT_ID

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_EJENDOM_H EJ
        ON OV.SIK_OBJEKT_ID = EJ.SIK_OBJEKT_ID

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_ROLLE_STATUS_H RS
        ON RO.SIK_ROLLE_ID = RS.SIK_ROLLE_ID

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_GLOBALE_TYPER_S TX3
        ON AG.SIK_AFTALE_TP = TX3.SIK_KODE_ID
        AND TX3.SIK_KODE_TP = 'AFTA_SIK_AFTALE'
        AND TX3.SIK_DIALOG = 'NIB'
        AND TX3.SPKD = 'EN'

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_GLOBALE_TYPER_S TX5
        ON RS.SIK_FOR_TP = TX5.SIK_KODE_ID
        AND TX5.SIK_KODE_TP = 'ROST_SIK_FOR'
        AND TX5.SIK_DIALOG = 'NIB'
        AND TX5.SPKD = 'EN'

	  LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_GLOBALE_TYPER_S TX14
        ON EJ.CENTRAL_LOC_TP = TX14.SIK_KODE_ID
        AND TX14.SIK_KODE_TP = 'YES_NO_TYPE'
        AND TX14.SIK_DIALOG = 'NIB'
        AND TX14.SPKD = 'EN'

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_FOR_FACILITET_H FA
        ON RO.SIK_ROLLE_ID = FA.SIK_ROLLE_ID

	WHERE TX3.SIK_TXT like '%Mortgage on real property%'
    and EJ.MTTS = (SELECT max(EJ1.MTTS) FROM DKDDBPE_DB2P.SI.SI_EJENDOM_H EJ1 where EJ.SIK_OBJEKT_ID = EJ1.SIK_OBJEKT_ID)
	and RS.AFTALE_NR is not null
    and CC.KNID in ( &cuslist ) );

	QUIT;

	endrsubmit;


	%MACRO LOAD_LIST2;
%LET OBS_NO1=1;
%LET OBS_NO2=1;
%LET OBS_NO3=1;
%DO %UNTIL(&OBS_NO3=31999);
	   %LET OBS_NO2=&OBS_NO1;
       %LET OBS_NO1=%EVAL(&OBS_NO1+1);
	   %LET OBS_NO3=%EVAL(&OBS_NO3+1);

LIBNAME SQLSERV OLEDB BULKLOAD=YES INSERTBUFF=1000 PROPERTIES=('initial catalog'="ETZ335IH_PROJECT_JERSEY" 'Integrated Security' = "SSPI" 'Persist Security Info'=False)  
PROVIDER=sqloledb  PROMPT=NO  DATASOURCE="ETPEW\inst004" schema="DBO";



proc sql noprint;
create table temp1 as 
	select distinct CUSTOMER_ID 
	
	from SQLSERV.XXXX_LRH_Historic_Mort_Cus_SAS 

	where row_no <= &OBS_NO1 
	and row_no > &OBS_NO2
	;

	QUIT;

RSUBMIT M1SF;

proc upload data=temp1 out=temp1;run;

proc sql noprint;
	select distinct cat("'",CUSTOMER_ID,"'")
	into :cuslist separated by ', '
	from temp1;
	
	QUIT;

	endrsubmit;

	RSUBMIT M1SF;

	proc sql;
	create table Prop_temp as
	select * from connection to db2 (

	SELECT DISTINCT
      CC.KNID AS CUSTOMER_ID
      ,RS.AFTALE_NR AS AGR_NO_WITHIN_CUST
      ,OD.sik_objekt_id AS SIK_OBJEKT_ID
      ,AG.SIK_AFTALE_ID AS AGR_UNIQUE_ID
      ,OV.sik_objekt_id AS AGR_UNIQUE_ID2
      ,TX3.SIK_TXT AS COLLATERAL_TYPE_DESC
      ,RS.UDSTED_DT AS AGREEMENT_DATE
      ,CASE WHEN SUBSTR(TX5.SIK_TXT,1,20) is null then 'Total exposure' else SUBSTR(TX5.SIK_TXT,1,20)end AS AS_SEC_FOR
      ,FA.FORRETNING_ID AS AS_SEC_FOR_ACC_ID
/*      ,FA.MTTS AS AS_SEC_FOR_ACC_TIME*/
/*      ,FA.AKTRTP AS AS_SEC_FOR_ACC_STATUS*/
      ,EJ.PROPERTY_ADDR1 AS PROPERTY_ADDR_LINE_1
      ,EJ.PROPERTY_ADDR2 AS PROPERTY_ADDR_LINE_2
      ,EJ.PROPERTY_ADDR3 AS PROPERTY_ADDR_LINE_3
      ,EJ.PROPERTY_ADDR4 AS PROPERTY_ADDR_LINE_4
      ,EJ.PROPERTY_ADDR5 AS PROPERTY_ADDR_LINE_5
      ,TX14.SIK_TXT In_Dublin

    FROM  DKDDBPE_DB2P.SI.SI_KUNDE_H CC

      JOIN DKDDBPE_DB2P.SI.SI_ROLLE_H RO
        ON CC.SIK_KUNDE_ID = RO.SIK_KUNDE_ID
        AND RO.ROLLE_TP ^= 51131

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_AFTALE_H AG
        ON RO.SIK_AFTALE_ID = AG.SIK_AFTALE_ID

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_OBJEKT_VURD_H OV
        ON AG.SIK_AFTALE_ID = OV.SIK_AFTALE_ID

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_OBJEKT_H OD
        ON OV.SIK_OBJEKT_ID = OD.SIK_OBJEKT_ID

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_EJENDOM_H EJ
        ON OV.SIK_OBJEKT_ID = EJ.SIK_OBJEKT_ID

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_ROLLE_STATUS_H RS
        ON RO.SIK_ROLLE_ID = RS.SIK_ROLLE_ID

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_GLOBALE_TYPER_S TX3
        ON AG.SIK_AFTALE_TP = TX3.SIK_KODE_ID
        AND TX3.SIK_KODE_TP = 'AFTA_SIK_AFTALE'
        AND TX3.SIK_DIALOG = 'NIB'
        AND TX3.SPKD = 'EN'

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_GLOBALE_TYPER_S TX5
        ON RS.SIK_FOR_TP = TX5.SIK_KODE_ID
        AND TX5.SIK_KODE_TP = 'ROST_SIK_FOR'
        AND TX5.SIK_DIALOG = 'NIB'
        AND TX5.SPKD = 'EN'

	  LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_GLOBALE_TYPER_S TX14
        ON EJ.CENTRAL_LOC_TP = TX14.SIK_KODE_ID
        AND TX14.SIK_KODE_TP = 'YES_NO_TYPE'
        AND TX14.SIK_DIALOG = 'NIB'
        AND TX14.SPKD = 'EN'

      LEFT OUTER JOIN DKDDBPE_DB2P.SI.SI_FOR_FACILITET_H FA
        ON RO.SIK_ROLLE_ID = FA.SIK_ROLLE_ID

	WHERE TX3.SIK_TXT like '%Mortgage on real property%'
    and EJ.MTTS = (SELECT max(EJ1.MTTS) FROM DKDDBPE_DB2P.SI.SI_EJENDOM_H EJ1 where EJ.SIK_OBJEKT_ID = EJ1.SIK_OBJEKT_ID)
	and RS.AFTALE_NR is not null
    and CC.KNID in ( &cuslist ));

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

proc download data=Prop out=Prop;run;

endrsubmit;

	
/*################ Deletes existing table on server and uploads the new one ##############*/
  %macro delds;
     %if %sysfunc(exist(SQLSERV.XXXX_LRH_Historic_Mort_Cus_Prop)) %then %do;
       proc datasets library=SQLSERV;
       delete XXXX_LRH_Historic_Mort_Cus_Prop;
      run;
     %end; 
      %mend;
      %delds;
      run;  	 

DATA    SQLSERV.XXXX_LRH_Historic_Mort_Cus_Prop;
SET     acc;
RUN;
