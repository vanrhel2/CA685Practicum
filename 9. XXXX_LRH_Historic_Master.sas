LIBNAME SQLSERV OLEDB BULKLOAD=YES INSERTBUFF=1000 PROPERTIES=('initial catalog'="ETZ335IH_PROJECT_JERSEY" 'Integrated Security' = "SSPI" 'Persist Security Info'=False)  
PROVIDER=sqloledb  PROMPT=NO  DATASOURCE="ETPEW\inst004" schema="DBO";


proc sql noprint;
create table Master as 
	select * 
	
	from SQLSERV.XXXX_LRH_Historic_Master_Final 
 
	;

	QUIT;


proc sql noprint;
create table Master_Filter as 
	select * 
	
	from WORK.Master

	where DEFAULT_FLAG = 'N'
	or (DEFAULT_FLAG = 'Y' and PRE_DEFAULT_FLAG = 'Y') 
 
	;

	QUIT;


proc sql noprint;
create table Account_No_Default as 
	select distinct ACCOUNT_NUMBER 
	
	from WORK.Master_Filter

	where DEFAULT_FLAG = 'N'
 
	;

	QUIT;


proc sql noprint;
create table Account_Default as 
	select distinct ACCOUNT_NUMBER 
	
	from WORK.Master_Filter

	where DEFAULT_FLAG = 'Y'
 
	;

	QUIT;

data Account_No_Default_Training Account_No_Default_Testing;

   set Account_No_Default ;

   if ranuni(1) >= 0.3 then output Account_No_Default_Training;

    else output Account_No_Default_Testing;

   run;

data Account_Default_Training Account_Default_Testing;

   set Account_Default ;

   if ranuni(1) >= 0.3 then output Account_Default_Training;

    else output Account_Default_Testing;

   run;

data Account_Training;

   set Account_No_Default_Training
		Account_Default_Training;

   run;

data Account_Testing;

   set Account_No_Default_Testing
		Account_Default_Testing;

   run;

proc sort data=Master_Filter; by Account_Number; run;
proc sort data=Account_Training; by Account_Number; run;
proc sort data=Account_Testing; by Account_Number; run;


data Master_Filter_Training;
merge Master_Filter (in=a) Account_Training (in=b);
by Account_Number;
if b;
run;

data Master_Filter_Testing;
merge Master_Filter (in=a) Account_Testing (in=b);
by Account_Number;
if b;
run;


