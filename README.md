# CA685Practicum
CA685 Data Analytics Practicum 

This page acts as a Repository for my Practicum project.

All source code used as part of data extracting, cleaning and testing of the models is included here.

The SAS Enterprise Guide project and PDFs of the final results are also shown.


<b>SQL Scritps</b>

1. XXXX_LRH_Historic.sql 

The main SQL script use to extract the historical mortgage dataset for testing.

2. XXXX_LRH_Historic_Defaults.sql 

Used to summarise the number of active mortgages and defaults at each of the month ends in the study.


<b>SAS Scritps</b>

3. XXXX_LRH_Historic_Mort_Arrears.sas

Used to extract historical arrears data for the mortgages.

4. XXXX_LRH_Historic_Mort_Org_Bal.sas

Used to extract original balance data for the mortgages.

5. XXXX_LRH_Historic_Other_Arrears.sas

Used to extract historical arrears data for the related accounts.

6. XXXX_LRH_Historic_Mort_Cus_Prop.sas

Used to extract the properties which secure the mortgages.

7. XXXX_LRH_Historic_Mort_Cus_Prop_Info.sas

Used to extract the basic information of the properties securing the mortgages.

8. XXXX_LRH_Historic_Mort_Cus_Prop_Val.sas

Used to extract the valuation of the properties secuirng the mortgages.

9. XXXX_LRH_Historic_Master.sas 

Script used to import the final dataset from SQL server to SAS for testing.
Also splits the dataset into Training and Testing datasets in a 70:30 ratio.


<b>SAS Enterprise Guide Project</b>

XXXX_LRH_Historic.egp

SAS enterprise Guide Project which holds details of the overall process flow.
Also has the testing scripts used for Variable Selection, Logistic Regression and Proportional Hazards Survival Analysis.


<b>PDF Reports</b>

SAS Report - Logistic Regression.pdf

PDF detailing the results of the Backward Stepwise Logistic Regression model used as part of Variable Selection

SAS Report - Proportional Hazards.pdf

PDF detailing the results of the Proportional Hazards model used as part of Survival Analysis
