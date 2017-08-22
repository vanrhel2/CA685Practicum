DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan]

SELECT distinct a.*
				,left(f.[IP_ID],10) as [PRIMARY_CUSTOMER_ID]
				,case when d.[PRIMARY_CUSTOMER] <> '' and d.[PRIMARY_CUSTOMER] <> left(f.[IP_ID],10) then d.[PRIMARY_CUSTOMER]
				when e.[SECONDARY_CUSTOMER] <> '' and e.[SECONDARY_CUSTOMER] <> left(f.[IP_ID],10) then e.[SECONDARY_CUSTOMER]
				else NULL end as [SECONDARY_CUSTOMER_ID]
				,case when B.[account_number] IS not null then B.[CLOSURE_DATE]
				when B.[account_number] IS null and C.[account_number] IS not null then C.[CLOSURE_DATE]
				else NULL end as [CLOSURE_DATE]
				,case when A.[PRODUKT_NR] in ('48C','48D','48E','48F','48G','48R','48V','48W','48X') then 'Mortgage'
				when A.[PRODUKT_NR] in ('48N','48Q') then 'Bridging Mortgage'
				when A.[PRODUKT_NR] in ('317','318','45A','45C','45D','45E','45F','45G','45H','45J','45L','45K','54A','54B','54C','55L','46A','46B','46C','46D','55A','55B','55C','55D','55E','54D','54E','49U','54Q','49G','49J','46E','628','627','603','55N','55O','55P','55Q','303','2AB','14G','55R','801','45M','55S','58I') then 'Current'
				when A.[PRODUKT_NR] in ('47N','47O','47A','47B','47C','47D','47E','47G','47H','47I','47J','47L','47M','47P','47Q','56A','56B','8IA','8IC','8IE','8IF','8IG','8IH','8IM','8IN','8IO','8IP','8IU','8IW','8IY','49F','44X','49A','49B','46T','46Q','46R','46L','46S','58A','46J','46K','46M','46N','46O','46P','49N', '54N','46G','46Y','47K','49C','7AD','8IB','8ID','8II','8IK','8IQ','8IR','8IV','8IX','8IZ','47R','47S','47T','49D','6EA','7AC') then 'Savings'
				when A.[PRODUKT_NR] in ('50A','50B','50C','50D','50E','50F','50G','50H','50I','50J','50K','48A','48B','48H','48I','48J','48L','48Y','49K','49R','48S','48U','48M','410','433','420','430','431','437','450','460','467','50M','58K','14E','14I','300','43D','48K','48T','49H','50L') then 'Loan'
				else 'Other' end as [PRODUCT_TYPE]
				,case when A.[PRODUKT_NR] in ('48C','48D','48E','48F','48G','48R','48V','48W','48X') then 'Personal'
				when A.[PRODUKT_NR] in ('48N','48Q') then 'Personal'
				when left(f.[IP_ID],1) = '8' then 'Personal'
				else 'Business' end as [BORROWER_TYPE]

INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] a

left join (
			SELECT
			d.[ACCOUNT_NUMBER],
			max([VALID_FROM]) as [CLOSURE_DATE]

			from [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] d
			where
			ACCOUNT_STATUS ='UDGÅET'
			and 
			[VALID_FROM] = 
			(
				select max([VALID_TO]) 
				from  [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] e 
				where ACCOUNT_STATUS <>'UDGÅET' and d.[ar_id] = e.[ar_id]
			 )
			 and
			 right(left(d.[AR_ID],13),3) = 'A03'
			 group by d.[ACCOUNT_NUMBER]
		  ) B
ON A.[ACCOUNT_NUMBER] = B.[ACCOUNT_NUMBER]

left join (
			SELECT
			d.[ACCOUNT_NUMBER],
			max([VALID_FROM]) as [CLOSURE_DATE]

			from [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] d
			where
			[DELETE_FLAG] = 'J'
			and 
			[VALID_FROM] = 
			(
				select max([VALID_TO]) 
				from  [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] e 
				where [DELETE_FLAG] <> 'J' and d.[ar_id] = e.[ar_id]
			 )
			 and
			 right(left(d.[AR_ID],13),3) = 'A03'
			 group by d.[ACCOUNT_NUMBER]
		  ) C
ON A.[ACCOUNT_NUMBER] = C.[ACCOUNT_NUMBER]

left join (
			SELECT distinct a.[ACCOUNT_NUMBER]
				,a.[PRIMARY_CUSTOMER]
     
			FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] a

			where a.ORIGINAL_SYSTEM = 'FEBOS'

			and a.VALID_FROM = (SELECT MAX(a2.VALID_FROM) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] a2 WHERE a.[ACCOUNT_NUMBER] = a2.[ACCOUNT_NUMBER] and a2.ORIGINAL_SYSTEM = 'FEBOS')
			) d
 on a.[ACCOUNT_NUMBER] = d.[ACCOUNT_NUMBER]

 left join (
				SELECT distinct a.[ACCOUNT_NUMBER]
					,a.[SECONDARY_CUSTOMER]
     
				FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] a

				where a.ORIGINAL_SYSTEM = 'FEBOS'

				and a.VALID_FROM = (SELECT MAX(a2.VALID_FROM) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] a2 WHERE a.[ACCOUNT_NUMBER] = a2.[ACCOUNT_NUMBER] and a2.ORIGINAL_SYSTEM = 'FEBOS')
			) e
 on a.[ACCOUNT_NUMBER] = e.[ACCOUNT_NUMBER]

 left join (
				SELECT distinct a.[ACCOUNT_NUMBER]
					,a.[IP_ID]
     
				FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] a

				where a.ORIGINAL_SYSTEM = 'FEBOS'

				and a.VALID_FROM = (SELECT MAX(a2.VALID_FROM) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[TBL_HISTORIC_LOAN_20170628] a2 WHERE a.[ACCOUNT_NUMBER] = a2.[ACCOUNT_NUMBER] and a2.ORIGINAL_SYSTEM = 'FEBOS')
			) f
 on a.[ACCOUNT_NUMBER] = f.[ACCOUNT_NUMBER]

WHERE a.[VALID_FROM] <= '2013-12-31'
AND a.[VALID_TO] > '2007-01-01'


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort]

SELECT DISTINCT [ACCOUNT_NUMBER]
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort]  
    
FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan]

WHERE [PRODUCT_TYPE] = 'Mortgage'
AND ([CLOSURE_DATE] >= '2007-01-01' or [CLOSURE_DATE] is null)


--------------------------------------------------------------------------------------------------------------------------------------------
----------------------------      GET HISTORIC BALANCES FOR MORTGAGE ACCOUNTS 2007 - 2013    ----------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------         2013        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2013]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2013]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2013_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2012        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2012]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2012]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2012_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2011        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2011]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2011]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2011_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2010        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2010]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2010]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2010_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2009       -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2009]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2009]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2009_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2008        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2008]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2008]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2008_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2007        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2007]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Balance_2007]
  FROM [ETZ3EW_Archive].[dbo].[ZW_FACT_GRU_2007_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''



----------------------------     COMBINE HISTORIC BALANCES FOR MORTGAGE ACCOUNTS INTO ONE TABLE 2007 - 2013    ----------------------------------------------

	DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
	SELECT  *
	into [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_2013]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_2012]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_2011]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_2010]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_2009]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_2008]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_2007]



-- Delete accounts that have no balance information from JAN 2007 to DEC 2013.
DELETE FROM		[ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort]
WHERE			ACCOUNT_NUMBER NOT IN
				(
					SELECT	DISTINCT [ACCOUNT_NUMBER]
					FROM	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
					WHERE	[DATE] > '2007-01-01' AND [DATE] <= '2013-12-31'
				)

-- Delete accounts that only have a positive or zero balance from JAN 2007 to DEC 2013.
DELETE FROM		[ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort]
WHERE			ACCOUNT_NUMBER IN
				(
					SELECT		DISTINCT [Account_Number]
					FROM		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
					WHERE		[DATE] > '2007-01-01' AND [DATE] <= '2013-12-31'
					GROUP BY	[Account_Number]
					HAVING		MAX([Eur_Exposure]) = 0
				)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Acc_SAS]

SELECT DISTINCT [ACCOUNT_NUMBER]
				,[ACCOUNT_NUMBER] + 'A03' as [AR_ID]
				,ROW_NUMBER() OVER (ORDER BY [ACCOUNT_NUMBER]) AS Row_No
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Acc_SAS]  
    
FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Cus_SAS]

SELECT DISTINCT a.[CUSTOMER_ID]
				,a.[CUSTOMER_ID] + 'I01' as [IP_ID]
				,ROW_NUMBER() OVER (ORDER BY [CUSTOMER_ID]) AS Row_No
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Cus_SAS]  
    
FROM (

		SELECT DISTINCT a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
						
		FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] a

		LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort] b
		on a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

		WHERE b.[ACCOUNT_NUMBER] is not null

		AND a.ORIGINAL_SYSTEM = 'FEBOS'

		UNION

		SELECT DISTINCT a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
						
		FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] a

		LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort] b
		on a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

		WHERE b.[ACCOUNT_NUMBER] is not null

		AND a.[SECONDARY_CUSTOMER_ID] is not null

		AND a.ORIGINAL_SYSTEM = 'FEBOS'

	) a


  DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static]

  SELECT distinct a.[ACCOUNT_NUMBER]
				  ,c.[PRIMARY_CUSTOMER_ID]
				  ,c.[SECONDARY_CUSTOMER_ID]
				  ,CAST(b.[CREATION_DATE] as date) AS [CREATION_DATE]
				  ,case when c.[CLOSURE_DATE] > '2013-12-31' then NULL 
				  else c.[CLOSURE_DATE] 
				  end as [CLOSURE_DATE]
				  ,d.[DCS_DATE]
  
  INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static]
				
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort] a

  LEFT JOIN (
			 SELECT distinct a.[ACCOUNT_NUMBER]
							 ,min(CAST([CREATION_DATE] as date)) as [CREATION_DATE]
			 FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Loan] a
			 INNER JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort] b
			 ON a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]
			 where [CREATION_DATE] <> ''
			 and [ORIGINAL_SYSTEM] = 'FEBOS'
			 group by a.[ACCOUNT_NUMBER]
		    ) b
  ON a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

  LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Loan] c
  ON a.[ACCOUNT_NUMBER] = c.[ACCOUNT_NUMBER]

  LEFT JOIN (
			 SELECT 
			 [Account_Number],
			 min([VALID_FROM]) as [DCS_DATE]
			 FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Loan]
			 where PRODUKT_NR like '%2%'
			 and [ORIGINAL_SYSTEM] = 'FEBOS'
			 group by [Account_Number]
		    ) d
  ON a.[ACCOUNT_NUMBER] = d.[ACCOUNT_NUMBER]

  
  DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base]

  SELECT distinct b.[Month]
				  ,b.[Date]
				  ,a.[ACCOUNT_NUMBER]
				  ,c.[PRIMARY_CUSTOMER_ID]
				  ,c.[SECONDARY_CUSTOMER_ID]
				  ,c.[CREATION_DATE]
				  ,c.[CLOSURE_DATE]
				  ,c.[DCS_DATE]
  
  INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base]
				
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort] a

  CROSS JOIN ( 
			  SELECT distinct [Month]
				    		  ,[Date]
			  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist]
			 ) b

  LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] c
  ON a.[ACCOUNT_NUMBER] = c.[ACCOUNT_NUMBER]

  WHERE b.[Date] >= c.[CREATION_DATE] and (b.[Date] < c.[CLOSURE_DATE] or c.[CLOSURE_DATE] is null)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Payments_Raw]

SELECT *

INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Payments_Raw]

FROM [ETZ3EDW].[dbo].[EWWH_MAX_INFO_HV]

WHERE [AR_ID] in (
				  SELECT distinct [AR_ID]
				  FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Acc_SAS]
			     )


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Payments_Temp]

SELECT distinct [IDKT] as [ACCOUNT_NUMBER]
				,[NSBL] as [REPAYMENT_AMOUNT]
				,[MXNSDT] as [NEXT_REPAYMENT_DATE]
				,[NSKD] as [REPAYMENT_FREQUENCY]

INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Payments_Temp]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Payments_Raw] a

where  a.[GÆLDER_FRA_DT] = (Select max(a1.[GÆLDER_FRA_DT]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Payments_Raw] a1 where a.[IDKT] = a1.[IDKT] and a.[MXNSDT] = a1.[MXNSDT] and a1.[TRANSAKTIONS_TP] <> 'S')
and a.[MXNSDT] <> ''


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Payments_Final]

SELECT distinct a.[Month]
				,a.[Date]
				,a.[ACCOUNT_NUMBER]
				,b.[REPAYMENT_AMOUNT]
				,case when b.[REPAYMENT_FREQUENCY] = '0' then 'N/A'
					  when b.[REPAYMENT_FREQUENCY] = '1' then 'Annually'
					  when b.[REPAYMENT_FREQUENCY] = '2' then 'Half yearly'
					  when b.[REPAYMENT_FREQUENCY] = '3' then 'Quarterly'
					  when b.[REPAYMENT_FREQUENCY] = '4' then 'Monthly'
					  when b.[REPAYMENT_FREQUENCY] = '5' then 'Once off'
					  when b.[REPAYMENT_FREQUENCY] = '6' then 'Fortnightly'
					  when b.[REPAYMENT_FREQUENCY] = '7' then 'Weekly'
					  when b.[REPAYMENT_FREQUENCY] = '8' then 'Twice monthly'
					  when b.[REPAYMENT_FREQUENCY] = '9' then 'Every other month'
					  else NULL end as [REPAYMENT_FREQUENCY] 
				,case when b.[REPAYMENT_FREQUENCY] = '0' then NULL
					  when b.[REPAYMENT_FREQUENCY] = '1' then b.[REPAYMENT_AMOUNT] / 12
					  when b.[REPAYMENT_FREQUENCY] = '2' then b.[REPAYMENT_AMOUNT] / 6
					  when b.[REPAYMENT_FREQUENCY] = '3' then b.[REPAYMENT_AMOUNT] / 3
					  when b.[REPAYMENT_FREQUENCY] = '4' then b.[REPAYMENT_AMOUNT]
					  when b.[REPAYMENT_FREQUENCY] = '5' then NULL
					  when b.[REPAYMENT_FREQUENCY] = '6' then b.[REPAYMENT_AMOUNT] * 26 / 12
					  when b.[REPAYMENT_FREQUENCY] = '7' then b.[REPAYMENT_AMOUNT] * 52 /12
					  when b.[REPAYMENT_FREQUENCY] = '8' then b.[REPAYMENT_AMOUNT] * 24 / 12
					  when b.[REPAYMENT_FREQUENCY] = '9' then b.[REPAYMENT_AMOUNT] / 2
					  else NULL end as [AVERAGE_MONTHLY_REPAYMENT_AMOUNT] 
				
  INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Mort_Payments_Final]
  
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

  LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Payments_Temp] b
  ON a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

  WHERE b.[NEXT_REPAYMENT_DATE] = (SELECT MAX(b1.[NEXT_REPAYMENT_DATE]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Payments_Temp] b1 WHERE b.[ACCOUNT_NUMBER] = b1.[ACCOUNT_NUMBER] and b1.[NEXT_REPAYMENT_DATE] <= a.[Date])


-- Get arrears start and end date

DROP TABLE	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Dates]

SELECT		distinct left(a.ar_id,10) as Account_number, 
			a.[OTDT] as Start_DT 
			,case when a.TRANSAKTIONS_TP <> 'S' then NULL else a.[GÆLDER_FRA_DT] end as End_DT
			,CASE WHEN a.TRANSAKTIONS_TP = 'S' THEN DATEDIFF(DAY,a.[OTDT],a.[GÆLDER_FRA_DT]) END AS Days_in_Arrears

INTO		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Dates]

FROM		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Raw] a

LEFT JOIN	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Raw] b
on			a.ar_id = b.ar_id
where		(	-- Came out of arrears
				(
					a.[TRANSAKTIONS_TP] = 'S'
				)
				or
				--Still in arrears
				(
					a.[GÆLDER_FRA_DT] =
					(
						select	max([GÆLDER_FRA_DT])
						from	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Raw] d
						where	a.AR_ID = d.AR_ID
					)
					and a.[TRANSAKTIONS_TP] <> 'S'
				)
			)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Temp]

SELECT		a.[Date]
					,b.[Account_number]
					,b.[Start_DT] as [Arrears_Start_Date]
					,b.[End_DT] as [Arrears_End_Date]
					,DATEDIFF(DAY,b.[Start_DT],a.[Date]) + 1 as [Days_In_Arrears]

		INTO		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Temp]

		FROM		(Select distinct [Date] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base]) A
		
		CROSS JOIN 	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Dates] B

		WHERE       [Start_DT] = 
					(
					SELECT	MAX(C.Start_DT)
					FROM	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Dates] C
					WHERE	B.Account_number = C.Account_number
							and c.Start_DT <= a.[Date]
							and (c.End_DT > a.[Date] or c.End_DT is null)

							-- Filter out Technical Arrears from Incident Log

							AND 
							(
								-- End of year technical arrears
								(YEAR(B.Start_DT) <> YEAR(B.End_DT) AND DATEDIFF(DAY, B.Start_DT, B.End_DT) > 2 AND B.End_DT NOT IN ('2013-01-03')) 
								OR
								(YEAR(B.Start_DT) <> YEAR(B.End_DT) AND DATEDIFF(DAY, B.Start_DT, B.End_DT) > 3 AND B.End_DT IN ('2013-01-03'))
								OR
								(YEAR(B.Start_DT) = YEAR(B.End_DT) AND B.End_DT NOT IN ('2013-11-19', '2013-05-17', '2007-07-02','2008-05-01') )
								OR
								(YEAR(B.Start_DT) = YEAR(B.End_DT) AND B.End_DT IN ('2013-11-19', '2013-05-17') AND DATEDIFF(DAY, B.Start_DT, B.End_DT) > 5)
								OR
								(YEAR(B.Start_DT) = YEAR(B.End_DT) AND B.End_DT IN ('2007-07-02') AND DATEDIFF(DAY, B.Start_DT, B.End_DT) > 3)
								OR
								(YEAR(B.Start_DT) = YEAR(B.End_DT) AND B.End_DT IN ('2008-05-01') AND DATEDIFF(DAY, B.Start_DT, B.End_DT) > 1)

								OR B.End_DT IS NULL
							)

					)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Final]

SELECT		 a.[Account_number]
			,a.[Date]
			,b.[Month]
			,a.[Arrears_Start_Date]
			,case when a.[Arrears_End_Date] > '2013-12-31' then NULL 
			else a.[Arrears_End_Date] end as [Arrears_End_Date]
			,a.[Days_In_Arrears]
			,b.[Eur_Arrears]
INTO		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Final]
FROM		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Temp] A

left join	(
			select	distinct 
					[Account_Number]
					,[Month]
					,[Eur_Arrears] 
			from	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist] c 
			where	[Date] = 
					(select		max([Date]) 
					 from		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist] d 
					 where		c.[month] = d.[month] 
								and c.[Account_Number] = d.[Account_Number]
					)
			)  b
on			a.[Account_Number] = b.[Account_Number] and left(a.[Date],4) + substring(a.[Date],6,2) = b.[Month]


WHERE       b.[Eur_Arrears] is not null and b.[Eur_Arrears] <> 0


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Rate_Raw]

SELECT *

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Rate_Raw]

FROM (

SELECT [IDKT]
      ,[GÆLDER_FRA_DT]
      ,[DBSA]
	  ,TRANSAKTIONS_TP
     
  FROM [ETZ3EDW].[dbo].[EWWH_RENTE_MD_HV] a

  inner join [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort] b
  on a.[IDKT] = b.[ACCOUNT_NUMBER]

  UNION ALL

  	  SELECT a.[IDKT]
      ,a.[GÆLDER_FRA_DT]
      ,a.[BTVR]/100000 as [DBSA]
	  ,a.TRANSAKTIONS_TP
 
  FROM [ETZ3EDW].[dbo].[EWWH_KTO_SATS_HV] a

  inner join [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort] b
  on a.[IDKT] = b.[ACCOUNT_NUMBER]

  left join (
				SELECT [IDKT]
					  ,[GÆLDER_FRA_DT]
					  ,[DBSA]
					  ,TRANSAKTIONS_TP
					
				  FROM [ETZ3EDW].[dbo].[EWWH_RENTE_MD_HV] a

				  inner join [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort] b
				  on a.[IDKT] = b.[ACCOUNT_NUMBER]
		  			) c
  on a.[IDKT] = c.[IDKT]
  
  where c.[IDKT] is null
  and a.[BRMO] = 'STDR'
  and a.[BRMOLI] = '002'
) a


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Rate_Final]

SELECT a.[Month]
	   ,a.[Date]
	   ,a.[ACCOUNT_NUMBER]
	   ,b.[DBSA] as [INTEREST_RATE]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Rate_Final]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Rate_Raw] b
ON a.[ACCOUNT_NUMBER] = b.[IDKT]

WHERE b.[GÆLDER_FRA_DT] = (SELECT MAX(c.[GÆLDER_FRA_DT]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Rate_Raw] c where b.[IDKT] = c.[IDKT] and c.[GÆLDER_FRA_DT] <= a.[Date])

and b.[TRANSAKTIONS_TP] <> 'S'


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Charged_Raw]

SELECT distinct a.[ACCOUNT_NUMBER]
				,[BOOKING_DATE]
				,Cast(Year([BOOKING_DATE]) as varchar(4)) + Right('00' + Cast(Month([BOOKING_DATE]) as varchar(2)), 2) as [MONTH]
				,[YEAR]
				,[INTEREST_AMOUNT]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Charged_Raw]

FROM [35IH_Non_CORE_DB].[dbo].[TBL_Neptune_Historic_Int_W_Purged] a

INNER JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort] b
on a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Charged_Final]

SELECT a.[Month]
	   ,a.[Date]
	   ,a.[ACCOUNT_NUMBER]
	   ,b.[INTEREST_CHARGED]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Charged_Final]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

LEFT JOIN (
			SELECT distinct [ACCOUNT_NUMBER]
							,[MONTH]
							,sum([INTEREST_AMOUNT]) as [INTEREST_CHARGED] 
			
			FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Charged_Raw]
			
			GROUP BY [Account_Number], [MONTH]
		  )b
ON a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER] and a.[MONTH] = b.[MONTH]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp]

SELECT distinct a.[MONTH]
				,a.[DATE]
				,a.[ACCOUNT_NUMBER]
				,a.[PRIMARY_CUSTOMER_ID]
				,a.[SECONDARY_CUSTOMER_ID]
				,a.[CREATION_DATE]
				,a.[CLOSURE_DATE]
				,a.[DCS_DATE]
				,b.[PRODUKT_NR]
				,b.[EUR_BALANCE]
				,b.[EUR_LIMIT]
				,c.[EUR_ARREARS]
				,c.[DAYS_IN_ARREARS]
				,case when d.[AVERAGE_MONTHLY_REPAYMENT_AMOUNT] = 0 then NULL
				else round(c.[EUR_ARREARS]/d.[AVERAGE_MONTHLY_REPAYMENT_AMOUNT],2) end as [AVERAGE_MONTHS_IN_ARREARS]
				,d.[REPAYMENT_AMOUNT]
				,d.[REPAYMENT_FREQUENCY] 
				,d.[AVERAGE_MONTHLY_REPAYMENT_AMOUNT]
				,e.[INTEREST_RATE]
				,f.[INTEREST_CHARGED]
				,case when i.[ACCOUNT_NUMBER] is null then NULL
				else round((isnull(b.[EUR_BALANCE],0) - isnull(g.[EUR_BALANCE],0)),2) end as [BALANCE_MOVEMENT]
				,case when i.[Account_Number] is null then NULL
				when j.[Account_Number] is null and round((isnull(b.[EUR_BALANCE],0) - isnull(g.[EUR_BALANCE],0) - isnull(h.[INTEREST_CHARGED],0) - d.[AVERAGE_MONTHLY_REPAYMENT_AMOUNT]),2) < 0 then 0
				when j.[Account_Number] is null then round((isnull(b.[EUR_BALANCE],0) - isnull(g.[EUR_BALANCE],0) - isnull(h.[INTEREST_CHARGED],0) - d.[AVERAGE_MONTHLY_REPAYMENT_AMOUNT]),2)
				else round((isnull(b.[EUR_BALANCE],0) - isnull(g.[EUR_BALANCE],0) - isnull(h.[INTEREST_CHARGED],0) - d.[AVERAGE_MONTHLY_REPAYMENT_AMOUNT]),2) end as [CASHFLOW]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist] b
ON a.[Account_Number] = b.[ACCOUNT_NUMBER] and a.[Date] = b.[Date]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Arrears_Final] c
ON a.[ACCOUNT_NUMBER] = c.[ACCOUNT_NUMBER] and a.[Date] = c.[Date]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Payments_Final] d
ON a.[ACCOUNT_NUMBER] = d.[ACCOUNT_NUMBER] and a.[Date] = d.[Date]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Rate_Final] e
ON a.[ACCOUNT_NUMBER] = e.[ACCOUNT_NUMBER] and a.[Date] = e.[Date]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Charged_Final] f
ON a.[ACCOUNT_NUMBER] = f.[ACCOUNT_NUMBER] and a.[Date] = f.[Date]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Balance_Masterlist] g
ON a.[ACCOUNT_NUMBER] = g.[ACCOUNT_NUMBER] and a.[Month] = Cast(Year(Dateadd(m,1,g.[Date])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,1,g.[Date])) as varchar(2)), 2)

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Int_Charged_Final] h
ON a.[ACCOUNT_NUMBER] = h.[ACCOUNT_NUMBER] and a.[Month] = Cast(Year(Dateadd(m,1,h.[Date])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,1,h.[Date])) as varchar(2)), 2)

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] i
ON a.[ACCOUNT_NUMBER] = i.[ACCOUNT_NUMBER] and a.[Month] = Cast(Year(Dateadd(m,1,i.[Date])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,1,i.[Date])) as varchar(2)), 2)

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] j
ON a.[ACCOUNT_NUMBER] = j.[ACCOUNT_NUMBER] and a.[Month] = Cast(Year(Dateadd(m,-1,j.[Date])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,-1,j.[Date])) as varchar(2)), 2)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Raw]

SELECT distinct [KNID]
				,[GÆLDER_FRA_DT]
				,[KNENDT]
				,[ADLI03]
				,[ADLI04]
				,[ADLI05]
				,[ADLI06]
				,[ADLI07]
				,[TRANSAKTIONS_TP]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Raw]

FROM [ETZ3EDW].[dbo].[EWWH_KUNDESTAM_HV]

where [KNID] in (SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS])

and TRANSAKTIONS_TP <> 'S'


--SELECT [KNID]
--      ,[GÆLDER_FRA_DT]
--      ,[KNENDT]
--      ,[ADLI03]
--      ,[ADLI04]
--      ,[ADLI05]
--      ,[ADLI06]
--      ,[ADLI07]
--	  ,case when [ADLI06] <> '' then [ADLI06]
--			when [ADLI05] <> '' then [ADLI05]
--			when [ADLI04] <> '' then [ADLI04]
--			when [ADLI03] <> '' then [ADLI03]
--	   else [ADLI07] end as [ADDRESS_CLEANED]
--      ,[TRANSAKTIONS_TP]
--  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Raw]

--  order by [KNID], [GÆLDER_FRA_DT]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp]

SELECT distinct a.[Month]
				,a.[Date]
				,a.[ACCOUNT_NUMBER]
				,a.[PRIMARY_CUSTOMER_ID]
				,a.[SECONDARY_CUSTOMER_ID]
				,b.[KNENDT] as [PRIMARY_CUSTOMER_START_DATE]
				,c.[KNENDT] as [SECONDARY_CUSTOMER_START_DATE]
				,d.[ADDRESS_CLEANED] as [PRIMARY_CUSTOMER_ADDRESS]
				,e.[ADDRESS_CLEANED] as [SECONDARY_CUSTOMER_ADDRESS]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp]
      
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Cleaned] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[KNID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Cleaned] c
ON a.[SECONDARY_CUSTOMER_ID] = c.[KNID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Cleaned] d
ON a.[PRIMARY_CUSTOMER_ID] = d.[KNID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Cleaned] e
ON a.[SECONDARY_CUSTOMER_ID] = e.[KNID]

where b.[GÆLDER_FRA_DT] = (SELECT max(b2.[GÆLDER_FRA_DT]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Cleaned] b2 where b.[KNID] = b2.[KNID])

and (c.[GÆLDER_FRA_DT] = (SELECT max(c2.[GÆLDER_FRA_DT]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Cleaned] c2 where c.[KNID] = c2.[KNID]) or a.[SECONDARY_CUSTOMER_ID] is null)

and d.[GÆLDER_FRA_DT] = (SELECT max(d2.[GÆLDER_FRA_DT]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Cleaned] d2 where d.[KNID] = d2.[KNID] and d2.[GÆLDER_FRA_DT] <= a.[Date] and d2.[ADDRESS_CLEANED] is not null)

and (e.[GÆLDER_FRA_DT] = (SELECT max(e2.[GÆLDER_FRA_DT]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Cleaned] e2 where e.[KNID] = e2.[KNID] and e2.[GÆLDER_FRA_DT] <= a.[Date] and e2.[ADDRESS_CLEANED] is not null) or a.[SECONDARY_CUSTOMER_ID] is null)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp]

SELECT distinct a.[Month]
				,a.[Date]
				,a.[ACCOUNT_NUMBER]
				,a.[PRIMARY_CUSTOMER_ID]
				,a.[SECONDARY_CUSTOMER_ID]
				,case when b.[OCCUPATION_STATUS] = 'Economically Inactive' then 'Unemployed'
				when b.[OCCUPATION_STATUS] in ('Retired', 'Student', 'Unemployed') then b.[OCCUPATION_STATUS]
				else b.[OCCUPATION_CATEGORY]
				end as [PRIMARY_CUSTOMER_OCCUPATION]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp]
      
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_NIB_CAT_HISTORIC_OCCUPATION] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

where b.[OCCUPATION_DATE] = (SELECT max(b2.[OCCUPATION_DATE]) FROM [35IH_Non_CORE_DB].[dbo].[TBL_NIB_CAT_HISTORIC_OCCUPATION] b2 where b.[CUSTOMER_ID] = b2.[CUSTOMER_ID] and Cast(b2.[OCCUPATION_DATE] as date) <= a.[Date])


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp]

SELECT distinct a.[Month]
				,a.[Date]
				,a.[ACCOUNT_NUMBER]
				,a.[PRIMARY_CUSTOMER_ID]
				,a.[SECONDARY_CUSTOMER_ID]
				,case when b.[OCCUPATION_STATUS] = 'Economically Inactive' then 'Unemployed'
				when b.[OCCUPATION_STATUS] in ('Retired', 'Student', 'Unemployed') then b.[OCCUPATION_STATUS]
				else b.[OCCUPATION_CATEGORY]
				end as [SECONDARY_CUSTOMER_OCCUPATION]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp]
      
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_NIB_CAT_HISTORIC_OCCUPATION] b
ON a.[SECONDARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

where b.[OCCUPATION_DATE] = (SELECT max(b2.[OCCUPATION_DATE]) FROM [35IH_Non_CORE_DB].[dbo].[TBL_NIB_CAT_HISTORIC_OCCUPATION] b2 where b.[CUSTOMER_ID] = b2.[CUSTOMER_ID] and Cast(b2.[OCCUPATION_DATE] as date) <= a.[Date]) or a.[SECONDARY_CUSTOMER_ID] is null


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp]

SELECT distinct a.[Month]
				,a.[Date]
				,a.[ACCOUNT_NUMBER]
				,a.[PRIMARY_CUSTOMER_ID]
				,a.[SECONDARY_CUSTOMER_ID]
				,b.[SALARY_PA] as [PRIMARY_CUSTOMER_SALARY]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp]
      
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_NIB_CAT_HISTORIC_INCOME] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

where b.[MTTS] = (SELECT max(b2.[MTTS]) FROM [35IH_Non_CORE_DB].[dbo].[TBL_NIB_CAT_HISTORIC_INCOME] b2 where b.[CUSTOMER_ID] = b2.[CUSTOMER_ID] and Cast(b2.[MTTS] as date) <= a.[Date] and b2.[SALARY_PA] is not null and b2.[SALARY_PA] >= 600)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp]

SELECT distinct a.[Month]
				,a.[Date]
				,a.[ACCOUNT_NUMBER]
				,a.[PRIMARY_CUSTOMER_ID]
				,a.[SECONDARY_CUSTOMER_ID]
				,b.[SALARY_PA] as [SECONDARY_CUSTOMER_SALARY]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp]
      
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_NIB_CAT_HISTORIC_INCOME] b
ON a.[SECONDARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

where b.[MTTS] = (SELECT max(b2.[MTTS]) FROM [35IH_Non_CORE_DB].[dbo].[TBL_NIB_CAT_HISTORIC_INCOME] b2 where b.[CUSTOMER_ID] = b2.[CUSTOMER_ID] and Cast(b2.[MTTS] as date) <= a.[Date] and b2.[SALARY_PA] is not null and b2.[SALARY_PA] >= 600) or a.[SECONDARY_CUSTOMER_ID] is null


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_DOB_Raw]

SELECT distinct [INV_ID]
				,[IN_BIRTH_DT]
				,[GÆLDER_FRA_DT]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_DOB_Raw]

FROM [ETZ3EDW].[dbo].[EWWH_INDIVID_H]

where [INV_ID] in (SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS])

and TRANSAKTIONS_TP <> 'S'


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_DOB_Temp]

SELECT distinct [INV_ID] as [CUSTOMER_ID]
				,case when YEAR(a.[IN_BIRTH_DT]) < 1914 then NULL
				when YEAR(a.[IN_BIRTH_DT]) > 1995 then NULL
				else a.[IN_BIRTH_DT] end as [DOB]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_DOB_Temp]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_DOB_Raw] a

where a.[GÆLDER_FRA_DT] = (SELECT max(b.[GÆLDER_FRA_DT]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_DOB_Raw] b where a.[INV_ID] = b.[INV_ID])


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Final]

SELECT a.[Month]
      ,a.[Date]
      ,a.[ACCOUNT_NUMBER]
      ,a.[PRIMARY_CUSTOMER_ID]
      ,a.[SECONDARY_CUSTOMER_ID]
      ,case when b.[Date] < a2.[PRIMARY_CUSTOMER_START_DATE] then b.[Date]
	  else a2.[PRIMARY_CUSTOMER_START_DATE] end as [PRIMARY_CUSTOMER_START_DATE]
      ,case when c.[Date] < a3.[SECONDARY_CUSTOMER_START_DATE] then c.[Date]
	  else a3.[SECONDARY_CUSTOMER_START_DATE] end as [SECONDARY_CUSTOMER_START_DATE]
      ,case when d.[PRIMARY_CUSTOMER_ADDRESS] is null then e.[ADDRESS]
	  else d.[PRIMARY_CUSTOMER_ADDRESS]
	  end as [PRIMARY_CUSTOMER_ADDRESS]
      ,case when d.[SECONDARY_CUSTOMER_ADDRESS] is null then f.[ADDRESS]
	  else d.[SECONDARY_CUSTOMER_ADDRESS]
	  end as [SECONDARY_CUSTOMER_ADDRESS]
	  ,case when g1.[PRIMARY_CUSTOMER_OCCUPATION] is null then h.[OCCUPATION]
	  else g1.[PRIMARY_CUSTOMER_OCCUPATION]
	  end as [PRIMARY_CUSTOMER_OCCUPATION]
      ,case when g2.[SECONDARY_CUSTOMER_OCCUPATION] is null then i.[OCCUPATION]
	  else g2.[SECONDARY_CUSTOMER_OCCUPATION]
	  end as [SECONDARY_CUSTOMER_OCCUPATION]
	  ,case when j1.[PRIMARY_CUSTOMER_SALARY] is null then k.[SALARY]
	  else j1.[PRIMARY_CUSTOMER_SALARY]
	  end as [PRIMARY_CUSTOMER_SALARY]
      ,case when j2.[SECONDARY_CUSTOMER_SALARY] is null then l.[SALARY]
	  else j2.[SECONDARY_CUSTOMER_SALARY]
	  end as [SECONDARY_CUSTOMER_SALARY]
	  ,case when m.[DOB] is null then NULL
	  when DATEADD(YEAR,DATEDIFF(YEAR,m.[DOB],a.[Date]),m.[DOB]) <= a.[Date] then DATEDIFF(YEAR,m.[DOB],a.[Date])
	  else DATEDIFF(YEAR,m.[DOB],a.[Date]) -1
	  end as [PRIMARY_CUSTOMER_AGE]
      ,case when n.[DOB] is null then NULL
	  when DATEADD(YEAR,DATEDIFF(YEAR,n.[DOB],a.[Date]),n.[DOB]) <= a.[Date] then DATEDIFF(YEAR,n.[DOB],a.[Date])
	  else DATEDIFF(YEAR,n.[DOB],a.[Date]) -1
	  end as [SECONDARY_CUSTOMER_AGE]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Final]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

LEFT JOIN (SELECT distinct [PRIMARY_CUSTOMER_ID]
						   ,[PRIMARY_CUSTOMER_START_DATE]

		   FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] 
) a2
ON a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID]

LEFT JOIN (SELECT distinct [SECONDARY_CUSTOMER_ID]
						   ,[SECONDARY_CUSTOMER_START_DATE]

		   FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] 
) a3
ON a.[SECONDARY_CUSTOMER_ID] = a3.[SECONDARY_CUSTOMER_ID]

LEFT JOIN (

SELECT distinct a.[CUSTOMER_ID]
				,a.[Date]

FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID])

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID])

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a

  where a.[Date] = (SELECT min(a2.[Date]) FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
			    ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID])

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID] 
			      ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID])

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a2 where a.[CUSTOMER_ID] = a2.[CUSTOMER_ID])

  ) b
  ON a.[PRIMARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

    LEFT JOIN (

SELECT distinct a.[CUSTOMER_ID]
				,a.[Date]

FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID])

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID])

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a

  where a.[Date] = (SELECT min(a2.[Date]) FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
			    ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID])

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
			      ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Base] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID])

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a2 where a.[CUSTOMER_ID] = a2.[CUSTOMER_ID])

  ) c
  ON a.[SECONDARY_CUSTOMER_ID] = c.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] d
ON a.[ACCOUNT_NUMBER] = d.[ACCOUNT_NUMBER] and a.[Date] = d.[Date]

LEFT JOIN (

SELECT distinct a.[CUSTOMER_ID]
				,a.[ADDRESS]

FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_ADDRESS] as [ADDRESS]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_ADDRESS] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_ADDRESS] as [ADDRESS]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_ADDRESS] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a

  where a.[Date] = (SELECT min(a2.[Date]) FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_ADDRESS] as [ADDRESS]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_ADDRESS] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_ADDRESS] as [ADDRESS]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_ADDRESS] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a2 where a.[CUSTOMER_ID] = a2.[CUSTOMER_ID])

  ) e
  ON a.[PRIMARY_CUSTOMER_ID] = e.[CUSTOMER_ID]

LEFT JOIN (

SELECT distinct a.[CUSTOMER_ID]
				,a.[ADDRESS]

FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_ADDRESS] as [ADDRESS]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_ADDRESS] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_ADDRESS] as [ADDRESS]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_ADDRESS] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a

  where a.[Date] = (SELECT min(a2.[Date]) FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_ADDRESS] as [ADDRESS]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_ADDRESS] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_ADDRESS] as [ADDRESS]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_ADDRESS] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a2 where a.[CUSTOMER_ID] = a2.[CUSTOMER_ID])

  ) f
ON a.[SECONDARY_CUSTOMER_ID] = f.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp] g1
ON a.[ACCOUNT_NUMBER] = g1.[ACCOUNT_NUMBER] and a.[Date] = g1.[Date]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp] g2
ON a.[ACCOUNT_NUMBER] = g2.[ACCOUNT_NUMBER] and a.[Date] = g2.[Date]

LEFT JOIN (

SELECT distinct a.[CUSTOMER_ID]
				,a.[OCCUPATION]

FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_OCCUPATION] as [OCCUPATION]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_OCCUPATION] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_OCCUPATION] as [OCCUPATION]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_OCCUPATION] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a

  where a.[Date] = (SELECT min(a2.[Date]) FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_OCCUPATION] as [OCCUPATION]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_OCCUPATION] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_OCCUPATION] as [OCCUPATION]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_OCCUPATION] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a2 where a.[CUSTOMER_ID] = a2.[CUSTOMER_ID])

  ) h
  ON a.[PRIMARY_CUSTOMER_ID] = h.[CUSTOMER_ID]

LEFT JOIN (

SELECT distinct a.[CUSTOMER_ID]
				,a.[OCCUPATION]

FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_OCCUPATION] as [OCCUPATION]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_OCCUPATION] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_OCCUPATION] as [OCCUPATION]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_OCCUPATION] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a

  where a.[Date] = (SELECT min(a2.[Date]) FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_OCCUPATION] as [OCCUPATION]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Pri_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_OCCUPATION] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_OCCUPATION] as [OCCUPATION]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Occ_Sec_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_OCCUPATION] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a2 where a.[CUSTOMER_ID] = a2.[CUSTOMER_ID])

  ) i
ON a.[SECONDARY_CUSTOMER_ID] = i.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp] j1
ON a.[ACCOUNT_NUMBER] = j1.[ACCOUNT_NUMBER] and a.[Date] = j1.[Date]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp] j2
ON a.[ACCOUNT_NUMBER] = j2.[ACCOUNT_NUMBER] and a.[Date] = j2.[Date]

LEFT JOIN (

SELECT distinct a.[CUSTOMER_ID]
				,a.[SALARY]

FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_SALARY] as [SALARY]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_SALARY] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_SALARY] as [SALARY]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_SALARY] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a

  where a.[Date] = (SELECT min(a2.[Date]) FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_SALARY] as [SALARY]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_SALARY] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_SALARY] as [SALARY]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_SALARY] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a2 where a.[CUSTOMER_ID] = a2.[CUSTOMER_ID])

  ) k
  ON a.[PRIMARY_CUSTOMER_ID] = k.[CUSTOMER_ID]

LEFT JOIN (

SELECT distinct a.[CUSTOMER_ID]
				,a.[SALARY]

FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_SALARY] as [SALARY]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_SALARY] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_SALARY] as [SALARY]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_SALARY] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a

  where a.[Date] = (SELECT min(a2.[Date]) FROM (

SELECT distinct a.[PRIMARY_CUSTOMER_ID] as [CUSTOMER_ID]
		        ,a.[PRIMARY_CUSTOMER_SALARY] as [SALARY]
				,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Pri_Temp] a2 where a.[PRIMARY_CUSTOMER_ID] = a2.[PRIMARY_CUSTOMER_ID] and a2.[PRIMARY_CUSTOMER_SALARY] is not null)

  UNION

  SELECT distinct a.[SECONDARY_CUSTOMER_ID] as [CUSTOMER_ID]
				  ,a.[SECONDARY_CUSTOMER_SALARY] as [SALARY]
				  ,a.[Date]
      
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp] a

  where a.[Date] = (Select min(a2.[Date]) FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Sal_Sec_Temp] a2 where a.[SECONDARY_CUSTOMER_ID] = a2.[SECONDARY_CUSTOMER_ID] and a2.[SECONDARY_CUSTOMER_SALARY] is not null)

  and a.[SECONDARY_CUSTOMER_ID] is not null

  ) a2 where a.[CUSTOMER_ID] = a2.[CUSTOMER_ID])

  ) l
ON a.[SECONDARY_CUSTOMER_ID] = l.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_DOB_Temp] m
ON a.[PRIMARY_CUSTOMER_ID] = m.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_DOB_Temp] n
ON a.[SECONDARY_CUSTOMER_ID] = n.[CUSTOMER_ID]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]

SELECT distinct [INV_ID] as [GROUP_ID]
				,[INV_ID_2] as [CUSTOMER_ID]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]

FROM [ETZ3EDW].[dbo].[EWWH_IP_RELATION_HV]

WHERE [INV_ID] in (SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS])

AND [IR_TP] = 'KONCERN'

AND [INV_ID_2] like '9%'


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Curr]

SELECT DISTINCT [ACCOUNT_NUMBER]
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Curr]  
    
FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan]

WHERE [PRODUCT_TYPE] = 'Current'
and (
	 [PRIMARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
or [SECONDARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
)
AND ([CLOSURE_DATE] >= '2007-01-01' or [CLOSURE_DATE] is null)
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort])


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Sav]

SELECT DISTINCT [ACCOUNT_NUMBER]
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Sav]  
    
FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan]

WHERE [PRODUCT_TYPE] = 'Savings'
and (
	 [PRIMARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
or [SECONDARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
)
AND ([CLOSURE_DATE] >= '2007-01-01' or [CLOSURE_DATE] is null)
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort])
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Curr])


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Loan]

SELECT DISTINCT [ACCOUNT_NUMBER]
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Loan]  
    
FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan]

WHERE [PRODUCT_TYPE] = 'Loan'
and (
	 [PRIMARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
or [SECONDARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
)
AND ([CLOSURE_DATE] >= '2007-01-01' or [CLOSURE_DATE] is null)
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort])
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Curr])
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Sav])


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Bridg]

SELECT DISTINCT [ACCOUNT_NUMBER]
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Bridg]  
    
FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan]

WHERE [PRODUCT_TYPE] = 'Bridging Mortgage'
and (
	 [PRIMARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
or [SECONDARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
)
AND ([CLOSURE_DATE] >= '2007-01-01' or [CLOSURE_DATE] is null)
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort])
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Curr])
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Sav])
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Loan])


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Other]

SELECT DISTINCT [ACCOUNT_NUMBER]
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Other]  
    
FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan]

WHERE [PRODUCT_TYPE] = 'Other'
and (
	 [PRIMARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
or [SECONDARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
)
AND ([CLOSURE_DATE] >= '2007-01-01' or [CLOSURE_DATE] is null)
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort])
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Curr])
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Sav])
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Loan])
AND [ACCOUNT_NUMBER] not in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Bridg])
AND [ORIGINAL_SYSTEM] = 'FEBOS'


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other]

SELECT DISTINCT [ACCOUNT_NUMBER]
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other]

FROM (
		SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Curr]
		UNION
		SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Sav]
		UNION
		SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Loan]
		UNION
		SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Bridg]
		UNION
		SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Other]
) a


--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------      GET HISTORIC BALANCES FOR OTHER ACCOUNTS 2007 - 2013    ----------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------         2013        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2013]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2013]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2013_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2012        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2012]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2012]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2012_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2011        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2011]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2011]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2011_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2010        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2010]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2010]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2010_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2009       -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2009]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2009]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2009_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2008        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2008]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2008]
  FROM [ETZ3EW].[dbo].[ZW_FACT_GRU_2008_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''


-----------------------------------------------         2007        -----------------------------------------------------------------------

  DROP TABLE   [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2007]
  SELECT 
   ds1.[FACILITET_EXT_ID],
	   left([FACT_DT],4) + substring([FACT_DT],6,2) as[Month]
      ,left(ds1.[IP_ID],10) as [Customer_ID]
      ,[VAKD_OPR] as [Currency]
      ,[FACT_DT] as [Date]
      ,left([IDKT],10) as [Account_Number]
   --   ,[REST_LOEBETID_DG] as [Period_to_Maturity_Days]
	  --,[REST_LØBETID_GRP] as [Period_to_Maturity_Months]
      ,[BETYD_MAX_OPR] as [Base_Limit]
      ,[UDNYTTELSE_OPR] as [Base_Exposure]
      ,[SALDO_OPR] as [Base_Balance]
      ,[BETYD_MAX_BASIS] as [Eur_Limit]
      ,[UDNYTTELSE_BASIS]  as [Eur_Exposure]
	  ,case when [UDNYTTELSE_BASIS]>[BETYD_MAX_BASIS] then [UDNYTTELSE_BASIS]-[BETYD_MAX_BASIS] else 0 end as [Eur_Arrears]
      ,[SALDO_BASIS] as [Eur_Balance]
      ,[VAKD_BASIS]
      ,ds1.[PRODUKT_NR] 
      ,[LTV_VAERDI] as [LTV_Market]
      ,[KOERSELS_DT] as [Run_Date]

	  ,ds3.[HOLDING_BRANCH]
      ,ds3.[ORIGINAL_SYSTEM]
      ,ds3.[ORIGINAL_TERM]
      ,ds3.[CREATION_DATE]
      ,ds3.[CREDIT_START_DATE]
      ,ds3.[MATURITY_DATE]
      ,ds3.[PRIMARY_CUSTOMER]
      ,ds3.[SECONDARY_CUSTOMER]
      ,ds3.[OWNERS]
	  ,ds3.[NO_INTEREST]
	  ,ds3.[ORIGINAL_BALANCE]
	  ,CASE WHEN ds3.[ACCOUNT_STATUS] ='AKTIV' THEN 'ACTIVE' ELSE 'CLOSED' END AS [ACCOUNT_STATUS]
	  
  INTO  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Balance_2007]
  FROM [ETZ3EW_Archive].[dbo].[ZW_FACT_GRU_2007_HV]ds1
  inner JOIN [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other] ds2
  on ds1.[IDKT] = ds2.[Account_Number]
  LEFT JOIN  [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan] ds3
  on ds1.[FACILITET_EXT_ID] = ds3.[FACILITET_EXT_ID]
  --where ds2.[Account_Number] <>''



----------------------------     COMBINE HISTORIC BALANCES FOR MORTGAGE ACCOUNTS INTO ONE TABLE 2007 - 2013    ----------------------------------------------

	DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
	SELECT  *
	into [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_2013]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_2012]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_2011]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_2010]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_2009]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_2008]
    INSERT INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
	SELECT  *
	FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_2007]



-- Delete accounts that have no balance information from JAN 2007 to DEC 2013.
DELETE FROM		[ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other]
WHERE			ACCOUNT_NUMBER NOT IN
				(
					SELECT	DISTINCT [ACCOUNT_NUMBER]
					FROM	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
					WHERE	[DATE] > '2007-01-01' AND [DATE] <= '2013-12-31'
				)

-- Delete accounts that only have a positive or zero balance from JAN 2007 to DEC 2013.
DELETE FROM		[ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other]
WHERE			ACCOUNT_NUMBER IN
				(
					SELECT		DISTINCT [Account_Number]
					FROM		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
					WHERE		[DATE] > '2007-01-01' AND [DATE] <= '2013-12-31'
					GROUP BY	[Account_Number]
					HAVING		MAX([Eur_Balance]) = 0 AND MIN([Eur_Balance]) = 0
				)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Acc_SAS]

SELECT DISTINCT [ACCOUNT_NUMBER]
				,[ACCOUNT_NUMBER] + 'A03' as [AR_ID]
				,ROW_NUMBER() OVER (ORDER BY [ACCOUNT_NUMBER]) AS Row_No
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Acc_SAS]  
    
FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Bus]

SELECT DISTINCT [ACCOUNT_NUMBER]
  
INTO [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Other_Bus]  
    
FROM [ETZ335IH_PROJECT_JERSEY].[DBO].[XXXX_LRH_Historic_Loan]

WHERE [BORROWER_TYPE] = 'Business'
and (
	 [PRIMARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
or [SECONDARY_CUSTOMER_ID] in (
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS]
								UNION
								SELECT distinct [CUSTOMER_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final]
							  )
)
AND ([CLOSURE_DATE] >= '2007-01-01' or [CLOSURE_DATE] is null)
AND [ACCOUNT_NUMBER] in (SELECT distinct [ACCOUNT_NUMBER] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other])


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static]

SELECT distinct a.[ACCOUNT_NUMBER]
				,c.[PRIMARY_CUSTOMER_ID]
				,c.[SECONDARY_CUSTOMER_ID]
				,CAST(b.[CREATION_DATE] as date) AS [CREATION_DATE]
				,case when c.[CLOSURE_DATE] > '2013-12-31' then NULL 
				else c.[CLOSURE_DATE] 
				end as [CLOSURE_DATE]
				,d.[DCS_DATE]
  
INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static]
				
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other] a

LEFT JOIN (
			SELECT distinct a.[ACCOUNT_NUMBER]
							,min(CAST([CREATION_DATE] as date)) as [CREATION_DATE]
			FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Loan] a
			INNER JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other] b
			ON a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]
			where [CREATION_DATE] <> ''
			and [ORIGINAL_SYSTEM] = 'FEBOS'
			group by a.[ACCOUNT_NUMBER]
		) b
ON a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Loan] c
ON a.[ACCOUNT_NUMBER] = c.[ACCOUNT_NUMBER]

LEFT JOIN (
			SELECT 
			[Account_Number],
			min([VALID_FROM]) as [DCS_DATE]
			FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Loan]
			where PRODUKT_NR like '%2%'
			and [ORIGINAL_SYSTEM] = 'FEBOS'
			group by [Account_Number]
		) d
ON a.[ACCOUNT_NUMBER] = d.[ACCOUNT_NUMBER]

  
DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Base]

SELECT distinct b.[Month]
				,b.[Date]
				,a.[ACCOUNT_NUMBER]
				,c.[PRIMARY_CUSTOMER_ID]
				,c.[SECONDARY_CUSTOMER_ID]
				,c.[CREATION_DATE]
				,c.[CLOSURE_DATE]
				,c.[DCS_DATE]
  
INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Base]
				
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other] a

CROSS JOIN ( 
			SELECT distinct [Month]
				    		,[Date]
			FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist]
			) b

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static] c
ON a.[ACCOUNT_NUMBER] = c.[ACCOUNT_NUMBER]

WHERE b.[Date] >= c.[CREATION_DATE] and (b.[Date] < c.[CLOSURE_DATE] or c.[CLOSURE_DATE] is null)


-- Get arrears start and end date

DROP TABLE	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Dates]

SELECT		distinct left(a.ar_id,10) as Account_number, 
			a.[OTDT] as Start_DT 
			,case when a.TRANSAKTIONS_TP <> 'S' then NULL else a.[GÆLDER_FRA_DT] end as End_DT
			,CASE WHEN a.TRANSAKTIONS_TP = 'S' THEN DATEDIFF(DAY,a.[OTDT],a.[GÆLDER_FRA_DT]) END AS Days_in_Arrears

INTO		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Dates]

FROM		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Raw] a

LEFT JOIN	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Raw] b
on			a.ar_id = b.ar_id
where		(	-- Came out of arrears
				(
					a.[TRANSAKTIONS_TP] = 'S'
				)
				or
				--Still in arrears
				(
					a.[GÆLDER_FRA_DT] =
					(
						select	max([GÆLDER_FRA_DT])
						from	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Raw] d
						where	a.AR_ID = d.AR_ID
					)
					and a.[TRANSAKTIONS_TP] <> 'S'
				)
			)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Temp]

SELECT		a.[Date]
			,b.[Account_number]
			,b.[Start_DT] as [Arrears_Start_Date]
			,b.[End_DT] as [Arrears_End_Date]
			,DATEDIFF(DAY,b.[Start_DT],a.[Date]) + 1 as [Days_In_Arrears]

INTO		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Temp]

FROM		(Select distinct [Date] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Base]) A
		
CROSS JOIN 	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Dates] B

WHERE       [Start_DT] = 
			(
			SELECT	MAX(C.Start_DT)
			FROM	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Dates] C
			WHERE	B.Account_number = C.Account_number
					and c.Start_DT <= a.[Date]
					and (c.End_DT > a.[Date] or c.End_DT is null)

					-- Filter out Technical Arrears from Incident Log

					AND 
					(
						-- End of year technical arrears
						(YEAR(B.Start_DT) <> YEAR(B.End_DT) AND DATEDIFF(DAY, B.Start_DT, B.End_DT) > 2 AND B.End_DT NOT IN ('2013-01-03')) 
						OR
						(YEAR(B.Start_DT) <> YEAR(B.End_DT) AND DATEDIFF(DAY, B.Start_DT, B.End_DT) > 3 AND B.End_DT IN ('2013-01-03'))
						OR
						(YEAR(B.Start_DT) = YEAR(B.End_DT) AND B.End_DT NOT IN ('2013-11-19', '2013-05-17', '2007-07-02','2008-05-01') )
						OR
						(YEAR(B.Start_DT) = YEAR(B.End_DT) AND B.End_DT IN ('2013-11-19', '2013-05-17') AND DATEDIFF(DAY, B.Start_DT, B.End_DT) > 5)
						OR
						(YEAR(B.Start_DT) = YEAR(B.End_DT) AND B.End_DT IN ('2007-07-02') AND DATEDIFF(DAY, B.Start_DT, B.End_DT) > 3)
						OR
						(YEAR(B.Start_DT) = YEAR(B.End_DT) AND B.End_DT IN ('2008-05-01') AND DATEDIFF(DAY, B.Start_DT, B.End_DT) > 1)

						OR B.End_DT IS NULL
					)

			)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Final]

SELECT		 a.[Account_number]
			,a.[Date]
			,b.[Month]
			,a.[Arrears_Start_Date]
			,case when a.[Arrears_End_Date] > '2013-12-31' then NULL 
			else a.[Arrears_End_Date] end as [Arrears_End_Date]
			,a.[Days_In_Arrears]
			,b.[Eur_Arrears]
INTO		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Final]
FROM		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Temp] A

left join	(
			select	distinct 
					[Account_Number]
					,[Month]
					,[Eur_Arrears] 
			from	[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist] c 
			where	[Date] = 
					(select		max([Date]) 
					 from		[ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist] d 
					 where		c.[month] = d.[month] 
								and c.[Account_Number] = d.[Account_Number]
					)
			)  b
on			a.[Account_Number] = b.[Account_Number] and left(a.[Date],4) + substring(a.[Date],6,2) = b.[Month]


WHERE       b.[Eur_Arrears] is not null and b.[Eur_Arrears] <> 0


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Master_Temp]

SELECT distinct a.[MONTH]
				,a.[DATE]
				,a.[ACCOUNT_NUMBER]
				,a.[PRIMARY_CUSTOMER_ID]
				,a.[SECONDARY_CUSTOMER_ID]
				,a.[CREATION_DATE]
				,a.[CLOSURE_DATE]
				,a.[DCS_DATE]
				,b.[PRODUKT_NR]
				,b.[EUR_BALANCE]
				,b.[EUR_LIMIT]
				,c.[EUR_ARREARS]
				,c.[DAYS_IN_ARREARS]
				,case when c.[DAYS_IN_ARREARS] is null then NULL
				else round(c.[DAYS_IN_ARREARS]/30.4375,2) end as [AVERAGE_MONTHS_IN_ARREARS]
				,case when k.[ACCOUNT_NUMBER] is null then NULL
				else round((isnull(b.[EUR_BALANCE],0) - isnull(d.[EUR_BALANCE],0)),2) end as [BALANCE_MOVEMENT]
				,case when e.[ACCOUNT_NUMBER] is not null then 'Current'
				when f.[ACCOUNT_NUMBER] is not null then 'Savings'
				when g.[ACCOUNT_NUMBER] is not null then 'Loan'
				when h.[ACCOUNT_NUMBER] is not null then 'Bridging Mortgage'
				when i.[ACCOUNT_NUMBER] is not null then 'Other'
				end as [PRODUCT_TYPE]
				,case when j.[ACCOUNT_NUMBER] is not null then 'Business'
				else 'Personal'	end as [BORROWER_TYPE]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Master_Temp]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Base] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist] b
ON a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER] and a.[Date] = b.[Date]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Arrears_Final] c
ON a.[ACCOUNT_NUMBER] = c.[ACCOUNT_NUMBER] and a.[Date] = c.[Date]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Balance_Masterlist] d
ON a.[ACCOUNT_NUMBER] = d.[ACCOUNT_NUMBER] and a.[Month] = Cast(Year(Dateadd(m,1,d.[Date])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,1,d.[Date])) as varchar(2)), 2)

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Curr] e
ON a.[ACCOUNT_NUMBER] = e.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Sav] f
ON a.[ACCOUNT_NUMBER] = f.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Loan] g
ON a.[ACCOUNT_NUMBER] = g.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Bridg] h
ON a.[ACCOUNT_NUMBER] = h.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Other] i
ON a.[ACCOUNT_NUMBER] = i.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Bus] j
ON a.[ACCOUNT_NUMBER] = j.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Base] k
ON a.[ACCOUNT_NUMBER] = k.[ACCOUNT_NUMBER] and a.[Month] = Cast(Year(Dateadd(m,1,k.[Date])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,1,k.[Date])) as varchar(2)), 2)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Other]

SELECT distinct [MORT_ACCOUNT]
				,[OTHER_ACCOUNT]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Other]

FROM (

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,b.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[PRIMARY_CUSTOMER_ID]

WHERE b.[ACCOUNT_NUMBER] is not null

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,b.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[SECONDARY_CUSTOMER_ID]

WHERE b.[ACCOUNT_NUMBER] is not null

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,b.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static] b
ON a.[SECONDARY_CUSTOMER_ID] = b.[PRIMARY_CUSTOMER_ID]

WHERE b.[ACCOUNT_NUMBER] is not null

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,b.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static] b
ON a.[SECONDARY_CUSTOMER_ID] = b.[SECONDARY_CUSTOMER_ID]

WHERE b.[ACCOUNT_NUMBER] is not null

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,c.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static] c
ON b.[GROUP_ID] = c.[PRIMARY_CUSTOMER_ID]

WHERE c.[ACCOUNT_NUMBER] is not null

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,c.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static] c
ON b.[GROUP_ID] = c.[SECONDARY_CUSTOMER_ID]

WHERE c.[ACCOUNT_NUMBER] is not null

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,c.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final] b
ON a.[SECONDARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static] c
ON b.[GROUP_ID] = c.[PRIMARY_CUSTOMER_ID]

WHERE c.[ACCOUNT_NUMBER] is not null

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,c.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final] b
ON a.[SECONDARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Static] c
ON b.[GROUP_ID] = c.[SECONDARY_CUSTOMER_ID]

WHERE c.[ACCOUNT_NUMBER] is not null

) a


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Mort]

SELECT distinct [MORT_ACCOUNT]
				,[OTHER_ACCOUNT]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Mort]

FROM (

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,b.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[PRIMARY_CUSTOMER_ID]

WHERE b.[ACCOUNT_NUMBER] is not null
AND a.[ACCOUNT_NUMBER] <> b.[ACCOUNT_NUMBER]

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,b.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[SECONDARY_CUSTOMER_ID]

WHERE b.[ACCOUNT_NUMBER] is not null
AND a.[ACCOUNT_NUMBER] <> b.[ACCOUNT_NUMBER]

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,b.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] b
ON a.[SECONDARY_CUSTOMER_ID] = b.[PRIMARY_CUSTOMER_ID]

WHERE b.[ACCOUNT_NUMBER] is not null
AND a.[ACCOUNT_NUMBER] <> b.[ACCOUNT_NUMBER]

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,b.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] b
ON a.[SECONDARY_CUSTOMER_ID] = b.[SECONDARY_CUSTOMER_ID]

WHERE b.[ACCOUNT_NUMBER] is not null
AND a.[ACCOUNT_NUMBER] <> b.[ACCOUNT_NUMBER]

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,c.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] c
ON b.[GROUP_ID] = c.[PRIMARY_CUSTOMER_ID]

WHERE c.[ACCOUNT_NUMBER] is not null
AND a.[ACCOUNT_NUMBER] <> c.[ACCOUNT_NUMBER]

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,c.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final] b
ON a.[PRIMARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] c
ON b.[GROUP_ID] = c.[SECONDARY_CUSTOMER_ID]

WHERE c.[ACCOUNT_NUMBER] is not null
AND a.[ACCOUNT_NUMBER] <> c.[ACCOUNT_NUMBER]

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,c.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final] b
ON a.[SECONDARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] c
ON b.[GROUP_ID] = c.[PRIMARY_CUSTOMER_ID]

WHERE c.[ACCOUNT_NUMBER] is not null
AND a.[ACCOUNT_NUMBER] <> c.[ACCOUNT_NUMBER]

UNION

SELECT distinct a.[ACCOUNT_NUMBER] as [MORT_ACCOUNT]
				,c.[ACCOUNT_NUMBER] as [OTHER_ACCOUNT]
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Group_Final] b
ON a.[SECONDARY_CUSTOMER_ID] = b.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] c
ON b.[GROUP_ID] = c.[SECONDARY_CUSTOMER_ID]

WHERE c.[ACCOUNT_NUMBER] is not null
AND a.[ACCOUNT_NUMBER] <> c.[ACCOUNT_NUMBER]

) a


--Default Date

DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Default_Date]

SELECT distinct [ACCOUNT_NUMBER]
				,min([DATE]) as [DEFAULT_DATE]
  
INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Default_Date]

FROM (

		SELECT distinct [ACCOUNT_NUMBER]
						,min([DATE]) as [DATE]
  
		FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp]

		where [AVERAGE_MONTHS_IN_ARREARS] >= 3
		group by [ACCOUNT_NUMBER]

		UNION

		SELECT distinct [ACCOUNT_NUMBER]
						,[DCS_DATE] as [DATE]
      
		FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp]

		where [DCS_DATE] is not null

	) a

Group by [ACCOUNT_NUMBER]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Default_Date]

SELECT distinct [ACCOUNT_NUMBER]
				,min([DATE]) as [DEFAULT_DATE]
  
INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Default_Date]

FROM (

		SELECT distinct [ACCOUNT_NUMBER]
						,min([DATE]) as [DATE]
  
		FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Master_Temp]

		where [AVERAGE_MONTHS_IN_ARREARS] >= 3
		group by [ACCOUNT_NUMBER]

		UNION

		SELECT distinct [ACCOUNT_NUMBER]
						,[DCS_DATE] as [DATE]
      
		FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Master_Temp]

		where [DCS_DATE] is not null

	) a

Group by [ACCOUNT_NUMBER]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Org_Bal_Temp]

SELECT distinct a.[ACCOUNT_NUMBER]
				,case when b.[ORIGINAL_BALANCE] is not null and b.[ORIGINAL_BALANCE] <> 0 then b.[ORIGINAL_BALANCE]
				when (c.[ORIGINAL_BALANCE] is null or c.[ORIGINAL_BALANCE] = 0) then abs(d.[ORIGINAL_BALANCE]) 
				else abs(c.[ORIGINAL_BALANCE]) end as [ORIGINAL_BALANCE]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Org_Bal_Temp]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_NIB_Accounts] b
ON a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_NIB_Accounts_His_2006] c
ON a.[ACCOUNT_NUMBER] = c.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Org_Bal_Raw] d
ON a.[ACCOUNT_NUMBER] = d.[ACCOUNT_NUMBER]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Loan_Purpose]

SELECT distinct a.[ACCOUNT_NUMBER]
				,case when c.[PPR_BTL] in ('PPR', 'BTL') then c.[PPR_BTL]
				when b.[ACCOUNT_NUMBER] is not null and b.[LOAN_PURPOSE_CODE] in ('I1','I2','I3','I4','I5') then 'BTL'
				when b.[ACCOUNT_NUMBER] is not null and b.[LOAN_PURPOSE_CODE] not in ('I1','I2','I3','I4','I5') and b.[LOAN_PURPOSE_CODE] is not null then 'PPR'
				when e.[ACCOUNT_NUMBER] is not null and e.[LOAN_PURPOSE_CODE] in ('I1','I2','I3','I4','I5') then 'BTL'
				when e.[ACCOUNT_NUMBER] is not null and e.[LOAN_PURPOSE_CODE] not in ('I1','I2','I3','I4','I5') and e.[LOAN_PURPOSE_CODE] is not null then 'PPR'
				when f.[AS_SEC_FOR_ACC_ID] is null and g.[AS_SEC_FOR_ACC_ID] is null then 'BTL'
				when d.[IDKT] is not null and d.[LNFM] in ('I1','I2','I3','I4','I5') then 'BTL'
				when d.[IDKT] is not null and d.[LNFM] not in ('I1','I2','I3','I4','I5') and d.[LNFM] is not null then 'PPR'
				else NULL end as [LOAN_PURPOSE]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Loan_Purpose]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Static] a

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_NIB_Accounts] b
ON a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_NIB_MORTGAGES 201707] c
ON a.[ACCOUNT_NUMBER] = c.[ACCOUNT_NUMBER]

left join (
			select IDKT, LNFM 
			from [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Payments_Raw] b
			where b.[GÆLDER_FRA_DT] = (
										select MAX(b1.GÆLDER_FRA_DT) 
										from [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Payments_Raw] b1
										where b.IDKT = b1.IDKT
										and b1.[TRANSAKTIONS_TP] <> 'S'
									  )
			and b.[TRANSAKTIONS_TP] <> 'S'
		  ) d
ON a.[ACCOUNT_NUMBER] = d.[IDKT]

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_NIB_Accounts 20161021] e
ON a.[ACCOUNT_NUMBER] = e.[ACCOUNT_NUMBER]

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_DTRM_Collateral_Accounts_Prop] f
ON a.[ACCOUNT_NUMBER] = f.[AS_SEC_FOR_ACC_ID]

LEFT JOIN [35IH_Non_CORE_DB].[dbo].[TBL_DTRM_Collateral_Accounts_Life] g
ON a.[ACCOUNT_NUMBER] = g.[AS_SEC_FOR_ACC_ID]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Raw]

SELECT *

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Raw]

FROM (
		SELECT distinct [FACT_DT]
						,[IP_ID]
						,[AR_ID]
						,[AFTALE_ID]
						,[SIK_TP]
						,[NOM_SIK_BEL]
		FROM [ETZ3EW_Archive].[dbo].[ZW_FACT_EST_2007_HV]

		WHERE [AR_ID] in (SELECT distinct [AR_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Acc_SAS])

		UNION

		SELECT distinct [FACT_DT]
						,[IP_ID]
						,[AR_ID]
						,[AFTALE_ID]
						,[SIK_TP]
						,[NOM_SIK_BEL]
		FROM [ETZ3EW].[dbo].[ZW_FACT_EST_2008_HV]

		WHERE [AR_ID] in (SELECT distinct [AR_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Acc_SAS])

		UNION

		SELECT distinct [FACT_DT]
						,[IP_ID]
						,[AR_ID]
						,[AFTALE_ID]
						,[SIK_TP]
						,[NOM_SIK_BEL]
		FROM [ETZ3EW].[dbo].[ZW_FACT_EST_2009_HV]

		WHERE [AR_ID] in (SELECT distinct [AR_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Acc_SAS])

		UNION

		SELECT distinct [FACT_DT]
						,[IP_ID]
						,[AR_ID]
						,[AFTALE_ID]
						,[SIK_TP]
						,[NOM_SIK_BEL]
		FROM [ETZ3EW].[dbo].[ZW_FACT_EST_2010_HV]

		WHERE [AR_ID] in (SELECT distinct [AR_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Acc_SAS])

		UNION

		SELECT distinct [FACT_DT]
						,[IP_ID]
						,[AR_ID]
						,[AFTALE_ID]
						,[SIK_TP]
						,[NOM_SIK_BEL]
		FROM [ETZ3EW].[dbo].[ZW_FACT_EST_2011_HV]

		WHERE [AR_ID] in (SELECT distinct [AR_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Acc_SAS])

		UNION

		SELECT distinct [FACT_DT]
						,[IP_ID]
						,[AR_ID]
						,[AFTALE_ID]
						,[SIK_TP]
						,[NOM_SIK_BEL]
		FROM [ETZ3EW].[dbo].[ZW_FACT_EST_2012_HV]

		WHERE [AR_ID] in (SELECT distinct [AR_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Acc_SAS])

		UNION

		SELECT distinct [FACT_DT]
						,[IP_ID]
						,[AR_ID]
						,[AFTALE_ID]
						,[SIK_TP]
						,[NOM_SIK_BEL]
		FROM [ETZ3EW].[dbo].[ZW_FACT_EST_2013_HV]

		WHERE [AR_ID] in (SELECT distinct [AR_ID] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Acc_SAS])
) a


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_SAS]

SELECT distinct [AFTALE_ID]
				,ROW_NUMBER() OVER (ORDER BY [AFTALE_ID]) AS Row_No

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_SAS]

FROM (
		SELECT distinct [AFTALE_ID]

		FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Raw]

		where [AFTALE_ID] <> ''

		and [AFTALE_ID] not like 'GB%'
	 ) a


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Temp]

SELECT distinct left(a.[AR_ID],10) as [ACCOUNT_NUMBER]
				,a.[AFTALE_ID] as [SIK_OBJEKT_ID]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Temp]
 
FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Raw] a

where a.AFTALE_ID <> ''

and a.[NOM_SIK_BEL] > 0

and a.[AFTALE_ID] in (SELECT distinct [SIK_OBJEKT_ID_DT] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Info_Raw])

and a.[FACT_DT] = (Select max(a1.[FACT_DT])
					 
					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Raw] a1

					where a1.[AFTALE_ID] <> ''

					and a1.[NOM_SIK_BEL] > 0

					and a1.[AFTALE_ID] in (SELECT distinct [SIK_OBJEKT_ID_DT] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Info_Raw])
					  
					and a1.[AR_ID] = a.[AR_ID]
					)

and a.[AFTALE_ID] = (Select max(a2.[AFTALE_ID])
					 
					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Raw] a2

					where a2.[AFTALE_ID] <> ''

					and a2.[NOM_SIK_BEL] > 0

					and a2.[AFTALE_ID] in (SELECT distinct [SIK_OBJEKT_ID_DT] FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Info_Raw])
					  
					and a2.[AR_ID] = a.[AR_ID]

					and a2.[FACT_DT] = a.[FACT_DT]
					)


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Final]

SELECT distinct a.[ACCOUNT_NUMBER]
				,a.[SIK_OBJEKT_ID]
				,b.[PROPERTY_ADDRESS]
				,case when c.[VALUE_DATE] is null then d.[VALUE_DATE]
				else c.[VALUE_DATE] end as [VALUE_DATE]
				,case when c.[VALUE_BAL] is null then d.[VALUE_BAL]
				else c.[VALUE_BAL] end as [VALUE_BAL]
				,case when c.[VALUE_CUR] is null then d.[VALUE_CUR]
				else c.[VALUE_CUR] end as [VALUE_CUR]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Final]
 
FROM (
	  SELECT distinct [ACCOUNT_NUMBER]
					  ,[SIK_OBJEKT_ID]
	  
	  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Temp]

	  UNION

	  SELECT distinct a.[ACCOUNT_NUMBER]
					  ,d.[SIK_OBJEKT_ID]
      
	  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp] a

	  left join [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Temp] b
	  on a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

	  left join [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Mort] c
	  on a.[ACCOUNT_NUMBER] = c.[MORT_ACCOUNT]

	  left join [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Temp] d
	  on c.[OTHER_ACCOUNT] = d.[ACCOUNT_NUMBER]

	  where b.[ACCOUNT_NUMBER] is null

	  and d.[ACCOUNT_NUMBER] is not null

	  and d.[SIK_OBJEKT_ID] = (SELECT max(d1.[SIK_OBJEKT_ID]) FROM (SELECT distinct a.[ACCOUNT_NUMBER]
		  ,d.[SIK_OBJEKT_ID]
      
	  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp] a

	  left join [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Temp] b
	  on a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

	  left join [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Mort] c
	  on a.[ACCOUNT_NUMBER] = c.[MORT_ACCOUNT]

	  left join [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Temp] d
	  on c.[OTHER_ACCOUNT] = d.[ACCOUNT_NUMBER]

	  where b.[ACCOUNT_NUMBER] is null

	  and d.[ACCOUNT_NUMBER] is not null) d1

	  where a.[ACCOUNT_NUMBER] = d1.[ACCOUNT_NUMBER])
) a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Info_Cleaned] b
on a.[SIK_OBJEKT_ID] = b.[SIK_OBJEKT_ID_DT]

LEFT JOIN ( 
			SELECT distinct [SIK_OBJEKT_ID_DT]
							,[VALUE_DATE] 
							,[VALUE_BAL]
							,[VALUE_CUR]
			FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Val] a
			WHERE a.[VALUE_TIME] = (
									SELECT MAX(b.[VALUE_TIME]) 
									FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Val] b
									WHERE a.[SIK_OBJEKT_ID_DT] = b.[SIK_OBJEKT_ID_DT] 
									and b.VALUE_BAL >= 5000 
									and b.VALUE_DATE >= '2005-01-01'
									and b.VALUE_DATE <= '2017-08-19'
								   )
			) c
on a.[SIK_OBJEKT_ID] = c.[SIK_OBJEKT_ID_DT]

LEFT JOIN ( 
			SELECT distinct [SIK_OBJEKT_ID_DT]
							,[VALUE_DATE] 
							,[VALUE_BAL]
							,[VALUE_CUR]
			FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Val] a
			WHERE a.[VALUE_TIME] = (
									SELECT MAX(b.[VALUE_TIME]) 
									FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Val] b
									WHERE a.[SIK_OBJEKT_ID_DT] = b.[SIK_OBJEKT_ID_DT]
									and b.VALUE_BAL > 100 
									and b.VALUE_DATE > '1900-01-01'
									and b.VALUE_DATE <= '2017-08-19'
								   )
			) d
on a.[SIK_OBJEKT_ID] = d.[SIK_OBJEKT_ID_DT]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Master_Temp]

SELECT distinct a.[MONTH]
				,a.[DATE]
				,a.[ACCOUNT_NUMBER]
				,a.[PROPERTY_ADDRESS]
				,case when b.[TOTAL_EXPOSURE] is null then NULL
				when b.[TOTAL_EXPOSURE] = 0 then NULL
				else round((a.[EUR_BALANCE] / b.[TOTAL_EXPOSURE]) * a.[INDEXED_VALUATION],2) end as [PROPERTY_VALUE_PROPORTION]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Master_Temp]

FROM (

		SELECT distinct a.[MONTH]
						,a.[DATE]
						,a.[ACCOUNT_NUMBER]
						,b.[SIK_OBJEKT_ID]
						,b.[PROPERTY_ADDRESS]
						,case when a.[EUR_BALANCE] > 0 then 0
						else a.[EUR_BALANCE] * -1 end as [EUR_BALANCE]
						,case when b.[VALUE_CUR] = 'GBP' and b.[PROPERTY_ADDRESS] like '%Ireland%' then round(b.[VALUE_BAL] * 1.09,2)
						when b.[PROPERTY_ADDRESS] like '%Ireland%' then round(b.[VALUE_BAL],2)
						when b.[PROPERTY_ADDRESS] like '%Dublin%' then round((b.[VALUE_BAL] / b.[Inside_Dublin]) * c.[Inside_Dublin],2)
						else round((b.[VALUE_BAL] / b.[Outisde_Dublin]) * c.[Outisde_Dublin],2) end as [INDEXED_VALUATION]

		FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp] a

		LEFT JOIN (
					SELECT distinct a.[ACCOUNT_NUMBER]
									,a.[SIK_OBJEKT_ID]
									,a.[PROPERTY_ADDRESS]
									,a.[VALUE_DATE]
									,a.[VALUE_BAL]
									,a.[VALUE_CUR]
									,b.[DATE]
									,b.[Outisde_Dublin]
									,b.[Inside_Dublin]

					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Final] a

					CROSS JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Index] b

					WHERE ABS(DATEDIFF(DAY,a.[VALUE_DATE],b.[DATE])) = (
																		SELECT MIN(ABS(DATEDIFF(DAY,c.[VALUE_DATE],c.[DATE])))

																		FROM (	SELECT a.[ACCOUNT_NUMBER]
																					   ,a.[VALUE_DATE]
																					   ,b.[DATE]
																				FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Final] a

																				CROSS JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Index] b
																			 ) c																
																		WHERE a.[ACCOUNT_NUMBER] = c.[ACCOUNT_NUMBER]
																		)
					and b.[DATE] = (
									SELECT MAX(d.[DATE])

									FROM (	SELECT a.[ACCOUNT_NUMBER]
													,a.[VALUE_DATE]
													,b.[DATE]
											FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Final] a

											CROSS JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Index] b
											) d															
									WHERE a.[ACCOUNT_NUMBER] = d.[ACCOUNT_NUMBER]
									and ABS(DATEDIFF(DAY,a.[VALUE_DATE],b.[DATE])) = ABS(DATEDIFF(DAY,d.[VALUE_DATE],d.[DATE]))
									)
				  ) b
		on a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

		LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Index] c
		on a.[DATE] = c.[DATE]

	) a

LEFT JOIN (

			SELECT distinct b.[SIK_OBJEKT_ID]
				,sum(a.[EUR_BALANCE]) as [TOTAL_EXPOSURE]
				,a.[DATE]

			FROM (
				  SELECT distinct [DATE]
								  ,[ACCOUNT_NUMBER]
								  ,case when [EUR_BALANCE] > 0 then 0
								  else [EUR_BALANCE] * -1 end as [EUR_BALANCE]

				 FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp] 
				 ) a

			LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Final] b
			on a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

			GROUP by b.[SIK_OBJEKT_ID]
					,a.[DATE]

		) b
on a.[DATE] = b.[DATE] and a.[SIK_OBJEKT_ID] = b.[SIK_OBJEKT_ID]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Temp]

SELECT distinct a.[MONTH]
				,a.[DATE]
				,a.[ACCOUNT_NUMBER]
				,a.[PRIMARY_CUSTOMER_ID]
				,a.[SECONDARY_CUSTOMER_ID]
				,c.[PRIMARY_CUSTOMER_START_DATE]
				,c.[SECONDARY_CUSTOMER_START_DATE]
				,c.[PRIMARY_CUSTOMER_ADDRESS]
				,c.[SECONDARY_CUSTOMER_ADDRESS]
				,c.[PRIMARY_CUSTOMER_OCCUPATION]
				,c.[SECONDARY_CUSTOMER_OCCUPATION]
				,c.[PRIMARY_CUSTOMER_SALARY]
				,c.[SECONDARY_CUSTOMER_SALARY]
				,c.[PRIMARY_CUSTOMER_AGE]
				,c.[SECONDARY_CUSTOMER_AGE]
				,a.[CREATION_DATE]
				,a.[CLOSURE_DATE]
				,b.[DEFAULT_DATE]
				,a.[PRODUKT_NR]
				,j.[ORIGINAL_BALANCE]
				,k.[LOAN_PURPOSE]
				,a.[EUR_BALANCE]
				,a.[EUR_LIMIT]
				,a.[EUR_ARREARS]
				,a.[DAYS_IN_ARREARS]
				,a.[AVERAGE_MONTHS_IN_ARREARS]
				,a.[REPAYMENT_AMOUNT]
				,a.[REPAYMENT_FREQUENCY] 
				,a.[AVERAGE_MONTHLY_REPAYMENT_AMOUNT]
				,a.[INTEREST_RATE]
				,a.[INTEREST_CHARGED]
				,a.[BALANCE_MOVEMENT]
				,a.[CASHFLOW]
				,round(m.[6_MONTH_BALANCE_MOVEMENT],2) as [6_MONTH_BALANCE_MOVEMENT]
				,round(m.[6_MONTH_CASHFLOW],2) as [6_MONTH_CASHFLOW]
				,round(n.[12_MONTH_BALANCE_MOVEMENT],2) as [12_MONTH_BALANCE_MOVEMENT]
				,round(n.[12_MONTH_CASHFLOW],2) as [12_MONTH_CASHFLOW]
				,l.[PROPERTY_ADDRESS]
				,case when a.[EUR_BALANCE] >= 0 then 0
				when l.[PROPERTY_VALUE_PROPORTION] is null then 3
				when l.[PROPERTY_VALUE_PROPORTION] = 0 then 3
				when round(((a.[EUR_BALANCE] * -1 ) / l.[PROPERTY_VALUE_PROPORTION]),4) > 3 then 3
				else round(((a.[EUR_BALANCE] * -1 ) / l.[PROPERTY_VALUE_PROPORTION]),4) end as [LTV]
				,d.[NO_ACCOUNTS] as [NO_MORT_ACCOUNTS]
				,d.[NO_IN_DEFAULT] as [NO_MORT_IN_DEFAULT]
				,d.[EUR_BALANCE] as [MORT_BALANCE]
				,d.[EUR_ARREARS] as [MORT_ARREARS]
				,d.[AVERAGE_MONTHS_IN_ARREARS] as [MORT_AVERAGE_MONTHS_IN_ARREARS]
				,d.[BALANCE_MOVEMENT] as [MORT_BALANCE_MOVEMENT]
				,d.[LTV] as [MORT_LTV]
				,e.[NO_ACCOUNTS] as [NO_PERS_CURR_ACCOUNTS]
				,e.[NO_IN_DEFAULT] as [NO_PERS_CURR_IN_DEFAULT]
				,e.[EUR_BALANCE] as [PERS_CURR_BALANCE]
				,e.[EUR_ARREARS] as [PERS_CURR_ARREARS]
				,e.[AVERAGE_MONTHS_IN_ARREARS] as [PERS_CURR_AVERAGE_MONTHS_IN_ARREARS]
				,e.[BALANCE_MOVEMENT] as [PERS_CURR_BALANCE_MOVEMENT]
				,f.[NO_ACCOUNTS] as [NO_SAVING_ACCOUNTS]
				,f.[EUR_BALANCE] as [SAVING_BALANCE]
				,f.[BALANCE_MOVEMENT] as [SAVING_BALANCE_MOVEMENT]
				,g.[NO_ACCOUNTS] as [NO_PERS_LOAN_ACCOUNTS]
				,g.[NO_IN_DEFAULT] as [NO_PERS_LOAN_IN_DEFAULT]
				,g.[EUR_BALANCE] as [PERS_LOAN_BALANCE]
				,g.[EUR_ARREARS] as [PERS_LOAN_ARREARS]
				,g.[AVERAGE_MONTHS_IN_ARREARS] as [PERS_LOAN_AVERAGE_MONTHS_IN_ARREARS]
				,g.[BALANCE_MOVEMENT] as [PERS_LOAN_BALANCE_MOVEMENT]
				,h.[NO_ACCOUNTS] as [NO_BUS_CURR_ACCOUNTS]
				,h.[NO_IN_DEFAULT] as [NO_BUS_CURR_IN_DEFAULT]
				,h.[EUR_BALANCE] as [BUS_CURR_BALANCE]
				,h.[EUR_ARREARS] as [BUS_CURR_ARREARS]
				,h.[AVERAGE_MONTHS_IN_ARREARS] as [BUS_CURR_AVERAGE_MONTHS_IN_ARREARS]
				,h.[BALANCE_MOVEMENT] as [BUS_CURR_BALANCE_MOVEMENT]
				,i.[NO_ACCOUNTS] as [NO_BUS_LOAN_ACCOUNTS]
				,i.[NO_IN_DEFAULT] as [NO_BUS_LOAN_IN_DEFAULT]
				,i.[EUR_BALANCE] as [BUS_LOAN_BALANCE]
				,i.[EUR_ARREARS] as [BUS_LOAN_ARREARS]
				,i.[AVERAGE_MONTHS_IN_ARREARS] as [BUS_LOAN_AVERAGE_MONTHS_IN_ARREARS]
				,i.[BALANCE_MOVEMENT] as [BUS_LOAN_BALANCE_MOVEMENT]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Temp]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Default_Date] b
ON a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_Info_Final] c
ON a.[ACCOUNT_NUMBER] = c.[ACCOUNT_NUMBER] and a.[DATE] = c.[DATE]

LEFT JOIN (
			SELECT distinct a.[MORT_ACCOUNT]
							,a.[Date]
							,count(*) as [NO_ACCOUNTS]
							,sum(a.[DEFAULT_FLAG]) as [NO_IN_DEFAULT]
							,sum(a.[EUR_BALANCE]) as [EUR_BALANCE]
							,sum(a.[EUR_ARREARS]) as [EUR_ARREARS]
							,case when sum(a.[EUR_ARREARS]) = 0 then 0
							else sum(a.[AVERAGE_MONTHS_IN_ARREARS] * a.[EUR_ARREARS])/sum(a.[EUR_ARREARS]) end as [AVERAGE_MONTHS_IN_ARREARS]
							,sum(a.[BALANCE_MOVEMENT]) as [BALANCE_MOVEMENT]
							,case when sum(a.[EUR_BALANCE]) >= 0 then 0
							else round(sum(a.[EUR_BALANCE] * a.[LTV])/sum(a.[EUR_BALANCE]),4) end as [LTV]

			FROM (
			
					SELECT distinct a.[MORT_ACCOUNT]
									,b.[Date]
									,case when c.[DEFAULT_DATE] <= b.[Date] then 1
									else 0 end as [DEFAULT_FLAG]
									,isnull(b.[EUR_BALANCE],0) as [EUR_BALANCE]
									,isnull(b.[EUR_ARREARS],0) as [EUR_ARREARS]
									,isnull(b.[AVERAGE_MONTHS_IN_ARREARS],0) as [AVERAGE_MONTHS_IN_ARREARS]
									,isnull(b.[BALANCE_MOVEMENT],0) as [BALANCE_MOVEMENT]
									,3 as [LTV]
			
					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Other] a

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Master_Temp] b
					ON a.[OTHER_ACCOUNT] = b.[ACCOUNT_NUMBER]

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Default_Date] c
					ON a.[OTHER_ACCOUNT] = c.[ACCOUNT_NUMBER]

					WHERE b.[PRODUCT_TYPE] = 'Bridging Mortgage'

					UNION

					SELECT distinct a.[MORT_ACCOUNT]
									,b.[Date]
									,case when c.[DEFAULT_DATE] <= b.[Date] then 1
									else 0 end as [DEFAULT_FLAG]
									,isnull(b.[EUR_BALANCE],0) as [EUR_BALANCE]
									,isnull(b.[EUR_ARREARS],0) as [EUR_ARREARS]
									,isnull(b.[AVERAGE_MONTHS_IN_ARREARS],0) as [AVERAGE_MONTHS_IN_ARREARS]
									,isnull(b.[BALANCE_MOVEMENT],0) as [BALANCE_MOVEMENT]
									,case when b.[EUR_BALANCE] >= 0 then 0
									when d.[PROPERTY_VALUE_PROPORTION] is null then 3
									when d.[PROPERTY_VALUE_PROPORTION] = 0 then 3
									when ((b.[EUR_BALANCE] * -1 ) / d.[PROPERTY_VALUE_PROPORTION]) > 3 then 3
									else ((b.[EUR_BALANCE] * -1 ) / d.[PROPERTY_VALUE_PROPORTION]) end as [LTV]
			
					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Mort] a

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp] b
					ON a.[OTHER_ACCOUNT] = b.[ACCOUNT_NUMBER]

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Default_Date] c
					ON a.[OTHER_ACCOUNT] = c.[ACCOUNT_NUMBER]

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Master_Temp] d
					on a.[OTHER_ACCOUNT] = d.[ACCOUNT_NUMBER] and b.[DATE] = d.[DATE]

					WHERE b.[ACCOUNT_NUMBER] is not null

				) a

			GROUP by a.[MORT_ACCOUNT]
					 ,a.[Date]
		  ) d
on a.[ACCOUNT_NUMBER] = d.[MORT_ACCOUNT] and a.[DATE] = d.[DATE]

LEFT JOIN (
			SELECT distinct a.[MORT_ACCOUNT]
							,a.[Date]
							,count(*) as [NO_ACCOUNTS]
							,sum(a.[DEFAULT_FLAG]) as [NO_IN_DEFAULT]
							,sum(a.[EUR_BALANCE]) as [EUR_BALANCE]
							,sum(a.[EUR_ARREARS]) as [EUR_ARREARS]
							,case when sum(a.[EUR_ARREARS]) = 0 then 0
							else sum(a.[AVERAGE_MONTHS_IN_ARREARS] * a.[EUR_ARREARS])/sum(a.[EUR_ARREARS]) end as [AVERAGE_MONTHS_IN_ARREARS]
							,sum(a.[BALANCE_MOVEMENT]) as [BALANCE_MOVEMENT]

			FROM (
			
					SELECT distinct a.[MORT_ACCOUNT]
									,b.[Date]
									,case when c.[DEFAULT_DATE] <= b.[Date] then 1
									else 0 end as [DEFAULT_FLAG]
									,isnull(b.[EUR_BALANCE],0) as [EUR_BALANCE]
									,isnull(b.[EUR_ARREARS],0) as [EUR_ARREARS]
									,isnull(b.[AVERAGE_MONTHS_IN_ARREARS],0) as [AVERAGE_MONTHS_IN_ARREARS]
									,isnull(b.[BALANCE_MOVEMENT],0) as [BALANCE_MOVEMENT]
			
					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Other] a

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Master_Temp] b
					ON a.[OTHER_ACCOUNT] = b.[ACCOUNT_NUMBER]

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Default_Date] c
					ON a.[OTHER_ACCOUNT] = c.[ACCOUNT_NUMBER]

					WHERE b.[PRODUCT_TYPE] = 'Current'
					AND b.[BORROWER_TYPE] = 'Personal'

				) a

			GROUP by a.[MORT_ACCOUNT]
					 ,a.[Date]
		  ) e
on a.[ACCOUNT_NUMBER] = e.[MORT_ACCOUNT] and a.[DATE] = e.[DATE]

LEFT JOIN (
			SELECT distinct a.[MORT_ACCOUNT]
							,a.[Date]
							,count(*) as [NO_ACCOUNTS]
							,sum(a.[DEFAULT_FLAG]) as [NO_IN_DEFAULT]
							,sum(a.[EUR_BALANCE]) as [EUR_BALANCE]
							,sum(a.[EUR_ARREARS]) as [EUR_ARREARS]
							,case when sum(a.[EUR_ARREARS]) = 0 then 0
							else sum(a.[AVERAGE_MONTHS_IN_ARREARS] * a.[EUR_ARREARS])/sum(a.[EUR_ARREARS]) end as [AVERAGE_MONTHS_IN_ARREARS]
							,sum(a.[BALANCE_MOVEMENT]) as [BALANCE_MOVEMENT]

			FROM (
			
					SELECT distinct a.[MORT_ACCOUNT]
									,b.[Date]
									,case when c.[DEFAULT_DATE] <= b.[Date] then 1
									else 0 end as [DEFAULT_FLAG]
									,isnull(b.[EUR_BALANCE],0) as [EUR_BALANCE]
									,isnull(b.[EUR_ARREARS],0) as [EUR_ARREARS]
									,isnull(b.[AVERAGE_MONTHS_IN_ARREARS],0) as [AVERAGE_MONTHS_IN_ARREARS]
									,isnull(b.[BALANCE_MOVEMENT],0) as [BALANCE_MOVEMENT]
			
					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Other] a

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Master_Temp] b
					ON a.[OTHER_ACCOUNT] = b.[ACCOUNT_NUMBER]

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Default_Date] c
					ON a.[OTHER_ACCOUNT] = c.[ACCOUNT_NUMBER]

					WHERE b.[PRODUCT_TYPE] = 'Savings'

				) a

			GROUP by a.[MORT_ACCOUNT]
					 ,a.[Date]
		  ) f
on a.[ACCOUNT_NUMBER] = f.[MORT_ACCOUNT] and a.[DATE] = f.[DATE]

LEFT JOIN (
			SELECT distinct a.[MORT_ACCOUNT]
							,a.[Date]
							,count(*) as [NO_ACCOUNTS]
							,sum(a.[DEFAULT_FLAG]) as [NO_IN_DEFAULT]
							,sum(a.[EUR_BALANCE]) as [EUR_BALANCE]
							,sum(a.[EUR_ARREARS]) as [EUR_ARREARS]
							,case when sum(a.[EUR_ARREARS]) = 0 then 0
							else sum(a.[AVERAGE_MONTHS_IN_ARREARS] * a.[EUR_ARREARS])/sum(a.[EUR_ARREARS]) end as [AVERAGE_MONTHS_IN_ARREARS]
							,sum(a.[BALANCE_MOVEMENT]) as [BALANCE_MOVEMENT]

			FROM (
			
					SELECT distinct a.[MORT_ACCOUNT]
									,b.[Date]
									,case when c.[DEFAULT_DATE] <= b.[Date] then 1
									else 0 end as [DEFAULT_FLAG]
									,isnull(b.[EUR_BALANCE],0) as [EUR_BALANCE]
									,isnull(b.[EUR_ARREARS],0) as [EUR_ARREARS]
									,isnull(b.[AVERAGE_MONTHS_IN_ARREARS],0) as [AVERAGE_MONTHS_IN_ARREARS]
									,isnull(b.[BALANCE_MOVEMENT],0) as [BALANCE_MOVEMENT]
			
					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Other] a

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Master_Temp] b
					ON a.[OTHER_ACCOUNT] = b.[ACCOUNT_NUMBER]

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Default_Date] c
					ON a.[OTHER_ACCOUNT] = c.[ACCOUNT_NUMBER]

					WHERE b.[PRODUCT_TYPE] in ('Loan', 'Other')
					AND b.[BORROWER_TYPE] = 'Personal'

				) a

			GROUP by a.[MORT_ACCOUNT]
					 ,a.[Date]
		  ) g
on a.[ACCOUNT_NUMBER] = g.[MORT_ACCOUNT] and a.[DATE] = g.[DATE]

LEFT JOIN (
			SELECT distinct a.[MORT_ACCOUNT]
							,a.[Date]
							,count(*) as [NO_ACCOUNTS]
							,sum(a.[DEFAULT_FLAG]) as [NO_IN_DEFAULT]
							,sum(a.[EUR_BALANCE]) as [EUR_BALANCE]
							,sum(a.[EUR_ARREARS]) as [EUR_ARREARS]
							,case when sum(a.[EUR_ARREARS]) = 0 then 0
							else sum(a.[AVERAGE_MONTHS_IN_ARREARS] * a.[EUR_ARREARS])/sum(a.[EUR_ARREARS]) end as [AVERAGE_MONTHS_IN_ARREARS]
							,sum(a.[BALANCE_MOVEMENT]) as [BALANCE_MOVEMENT]

			FROM (
			
					SELECT distinct a.[MORT_ACCOUNT]
									,b.[Date]
									,case when c.[DEFAULT_DATE] <= b.[Date] then 1
									else 0 end as [DEFAULT_FLAG]
									,isnull(b.[EUR_BALANCE],0) as [EUR_BALANCE]
									,isnull(b.[EUR_ARREARS],0) as [EUR_ARREARS]
									,isnull(b.[AVERAGE_MONTHS_IN_ARREARS],0) as [AVERAGE_MONTHS_IN_ARREARS]
									,isnull(b.[BALANCE_MOVEMENT],0) as [BALANCE_MOVEMENT]
			
					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Other] a

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Master_Temp] b
					ON a.[OTHER_ACCOUNT] = b.[ACCOUNT_NUMBER]

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Default_Date] c
					ON a.[OTHER_ACCOUNT] = c.[ACCOUNT_NUMBER]

					WHERE b.[PRODUCT_TYPE] = 'Current'
					AND b.[BORROWER_TYPE] = 'Business'

				) a

			GROUP by a.[MORT_ACCOUNT]
					 ,a.[Date]
		  ) h
on a.[ACCOUNT_NUMBER] = h.[MORT_ACCOUNT] and a.[DATE] = h.[DATE]

LEFT JOIN (
			SELECT distinct a.[MORT_ACCOUNT]
							,a.[Date]
							,count(*) as [NO_ACCOUNTS]
							,sum(a.[DEFAULT_FLAG]) as [NO_IN_DEFAULT]
							,sum(a.[EUR_BALANCE]) as [EUR_BALANCE]
							,sum(a.[EUR_ARREARS]) as [EUR_ARREARS]
							,case when sum(a.[EUR_ARREARS]) = 0 then 0
							else sum(a.[AVERAGE_MONTHS_IN_ARREARS] * a.[EUR_ARREARS])/sum(a.[EUR_ARREARS]) end as [AVERAGE_MONTHS_IN_ARREARS]
							,sum(a.[BALANCE_MOVEMENT]) as [BALANCE_MOVEMENT]

			FROM (
			
					SELECT distinct a.[MORT_ACCOUNT]
									,b.[Date]
									,case when c.[DEFAULT_DATE] <= b.[Date] then 1
									else 0 end as [DEFAULT_FLAG]
									,isnull(b.[EUR_BALANCE],0) as [EUR_BALANCE]
									,isnull(b.[EUR_ARREARS],0) as [EUR_ARREARS]
									,isnull(b.[AVERAGE_MONTHS_IN_ARREARS],0) as [AVERAGE_MONTHS_IN_ARREARS]
									,isnull(b.[BALANCE_MOVEMENT],0) as [BALANCE_MOVEMENT]
			
					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Link_Mort_Other] a

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Master_Temp] b
					ON a.[OTHER_ACCOUNT] = b.[ACCOUNT_NUMBER]

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Other_Default_Date] c
					ON a.[OTHER_ACCOUNT] = c.[ACCOUNT_NUMBER]

					WHERE b.[PRODUCT_TYPE] = 'Loan'
					AND b.[BORROWER_TYPE] = 'Business'

				) a

			GROUP by a.[MORT_ACCOUNT]
					 ,a.[Date]
		  ) i
on a.[ACCOUNT_NUMBER] = i.[MORT_ACCOUNT] and a.[DATE] = i.[DATE]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Org_Bal_Temp] j
on a.[ACCOUNT_NUMBER] = j.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Loan_Purpose] k
on a.[ACCOUNT_NUMBER] = k.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Prop_Master_Temp] l
on a.[ACCOUNT_NUMBER] = l.[ACCOUNT_NUMBER] and a.[DATE] = l.[DATE]

LEFT JOIN (
			SELECT distinct [ACCOUNT_NUMBER]
							,[Date]
							,sum([BALANCE_MOVEMENT]) as [6_MONTH_BALANCE_MOVEMENT]
							,sum([CASHFLOW]) as [6_MONTH_CASHFLOW]

			FROM (
					SELECT distinct a.[ACCOUNT_NUMBER]
									,a.[Date]
									,b.[Month]
									,b.[BALANCE_MOVEMENT]
									,b.[CASHFLOW]

					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp] a

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp] b
					on a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER] and a.[Month] >= b.[Month] and a.[MONTH] < Cast(Year(Dateadd(m,6,b.[Date])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,6,b.[Date])) as varchar(2)), 2)
				) a
			GROUP by [ACCOUNT_NUMBER], [Date]
		) m
on a.[ACCOUNT_NUMBER] = m.[ACCOUNT_NUMBER] and a.[Date] = m.[Date]

LEFT JOIN (
			SELECT distinct [ACCOUNT_NUMBER]
							,[Date]
							,sum([BALANCE_MOVEMENT]) as [12_MONTH_BALANCE_MOVEMENT]
							,sum([CASHFLOW]) as [12_MONTH_CASHFLOW]

			FROM (
					SELECT distinct a.[ACCOUNT_NUMBER]
									,a.[Date]
									,b.[Month]
									,b.[BALANCE_MOVEMENT]
									,b.[CASHFLOW]

					FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp] a

					LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Master_Temp] b
					on a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER] and a.[Month] >= b.[Month] and a.[MONTH] < Cast(Year(Dateadd(m,12,b.[Date])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,12,b.[Date])) as varchar(2)), 2)
				) a
			GROUP by [ACCOUNT_NUMBER], [Date]
		) n
on a.[ACCOUNT_NUMBER] = n.[ACCOUNT_NUMBER] and a.[Date] = n.[Date]


DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Final]

SELECT a.[MONTH]
      ,cast(a.[DATE] as datetime) as [DATE]
      ,'A' + right(('00000' + cast(b.[Row_No] as varchar(5))),5) as [ACCOUNT_NUMBER]
	  ,case when d.[Row_No] is null then 1 else 2 end as [NO_OWNERS]
      ,'C' + right(('00000' + cast(c.[Row_No] as varchar(5))),5) as [PRIMARY_CUSTOMER_ID]
      ,'C' + right(('00000' + cast(d.[Row_No] as varchar(5))),5) as [SECONDARY_CUSTOMER_ID]
      ,cast(a.[PRIMARY_CUSTOMER_START_DATE] as datetime) as [PRIMARY_CUSTOMER_START_DATE]
      ,cast(a.[SECONDARY_CUSTOMER_START_DATE] as datetime) as [SECONDARY_CUSTOMER_START_DATE]
      ,a.[PRIMARY_CUSTOMER_ADDRESS]
      ,a.[SECONDARY_CUSTOMER_ADDRESS]
      ,a.[PRIMARY_CUSTOMER_OCCUPATION]
      ,a.[SECONDARY_CUSTOMER_OCCUPATION]
      ,a.[PRIMARY_CUSTOMER_SALARY]
      ,a.[SECONDARY_CUSTOMER_SALARY]
      ,a.[PRIMARY_CUSTOMER_AGE]
      ,a.[SECONDARY_CUSTOMER_AGE]
      ,cast(a.[CREATION_DATE] as datetime) as [CREATION_DATE]
	  ,YEAR(a.[CREATION_DATE]) as [CREATION_YEAR]
      ,cast(a.[CLOSURE_DATE] as datetime) as [CLOSURE_DATE]
      ,cast(a.[DEFAULT_DATE] as datetime) as [DEFAULT_DATE]
      ,a.[PRODUKT_NR]
      ,a.[ORIGINAL_BALANCE]
      ,a.[LOAN_PURPOSE]
      ,isnull(a.[EUR_BALANCE],0) as [EUR_BALANCE]
      ,a.[EUR_LIMIT]
      ,a.[EUR_ARREARS]
      ,a.[DAYS_IN_ARREARS]
      ,isnull(a.[AVERAGE_MONTHS_IN_ARREARS],0) as [AVERAGE_MONTHS_IN_ARREARS]
      ,a.[REPAYMENT_AMOUNT]
      ,a.[REPAYMENT_FREQUENCY]
      ,a.[AVERAGE_MONTHLY_REPAYMENT_AMOUNT]
      ,a.[INTEREST_RATE]
      ,a.[INTEREST_CHARGED]
      ,a.[BALANCE_MOVEMENT]
      ,a.[CASHFLOW]
	  ,a.[6_MONTH_BALANCE_MOVEMENT]
	  ,a.[6_MONTH_CASHFLOW]
	  ,a.[12_MONTH_BALANCE_MOVEMENT]
	  ,a.[12_MONTH_CASHFLOW]
	  ,a.[PROPERTY_ADDRESS]
      ,a.[LTV]
      ,isnull(a.[NO_MORT_ACCOUNTS],0) as [NO_MORT_ACCOUNTS]
      ,isnull(a.[NO_MORT_IN_DEFAULT],0) as [NO_MORT_IN_DEFAULT]
      ,a.[MORT_BALANCE]
      ,a.[MORT_ARREARS]
      ,isnull(a.[MORT_AVERAGE_MONTHS_IN_ARREARS],0) as [MORT_AVERAGE_MONTHS_IN_ARREARS]
      ,a.[MORT_BALANCE_MOVEMENT]
	  ,a.[MORT_LTV]
      ,a.[NO_PERS_CURR_ACCOUNTS]
      ,a.[NO_PERS_CURR_IN_DEFAULT]
      ,a.[PERS_CURR_BALANCE]
      ,a.[PERS_CURR_ARREARS]
      ,a.[PERS_CURR_AVERAGE_MONTHS_IN_ARREARS]
      ,a.[PERS_CURR_BALANCE_MOVEMENT]
      ,a.[NO_SAVING_ACCOUNTS]
      ,a.[SAVING_BALANCE]
      ,a.[SAVING_BALANCE_MOVEMENT]
      ,a.[NO_PERS_LOAN_ACCOUNTS]
      ,a.[NO_PERS_LOAN_IN_DEFAULT]
      ,a.[PERS_LOAN_BALANCE]
      ,a.[PERS_LOAN_ARREARS]
      ,a.[PERS_LOAN_AVERAGE_MONTHS_IN_ARREARS]
      ,a.[PERS_LOAN_BALANCE_MOVEMENT]
      ,a.[NO_BUS_CURR_ACCOUNTS]
      ,a.[NO_BUS_CURR_IN_DEFAULT]
      ,a.[BUS_CURR_BALANCE]
      ,a.[BUS_CURR_ARREARS]
      ,a.[BUS_CURR_AVERAGE_MONTHS_IN_ARREARS]
      ,a.[BUS_CURR_BALANCE_MOVEMENT]
      ,a.[NO_BUS_LOAN_ACCOUNTS]
      ,a.[NO_BUS_LOAN_IN_DEFAULT]
      ,a.[BUS_LOAN_BALANCE]
      ,a.[BUS_LOAN_ARREARS]
      ,a.[BUS_LOAN_AVERAGE_MONTHS_IN_ARREARS]
      ,a.[BUS_LOAN_BALANCE_MOVEMENT]
	  ,case when a.[DEFAULT_DATE] is not null then 'Y'
	  else 'N' end as [DEFAULT_FLAG]
	  ,case when a.[DEFAULT_DATE] is not null and a.[DEFAULT_DATE] > a.[DATE] then 'Y'
	  else 'N' end as [PRE_DEFAULT_FLAG]
	  ,case when a.[DEFAULT_DATE] is not null and a.[DEFAULT_DATE] > a.[DATE] and Cast(Year(Dateadd(m,-1,a.[DEFAULT_DATE])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,-1,a.[DEFAULT_DATE])) as varchar(2)), 2) = a.[MONTH] then 'Y'
	  else 'N' end as [1_MONTH_DEFAULT_FLAG]
	  ,case when a.[DEFAULT_DATE] is not null and a.[DEFAULT_DATE] > a.[DATE] and Cast(Year(Dateadd(m,-1,a.[DEFAULT_DATE])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,-1,a.[DEFAULT_DATE])) as varchar(2)), 2) = a.[MONTH] then 'Y'
	  when a.[DEFAULT_DATE] is not null and a.[DEFAULT_DATE] > a.[DATE] and Cast(Year(Dateadd(m,-2,a.[DEFAULT_DATE])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,-2,a.[DEFAULT_DATE])) as varchar(2)), 2) = a.[MONTH] then 'Y'
	  else 'N' end as [2_MONTH_DEFAULT_FLAG]
	  ,case when a.[DEFAULT_DATE] is not null and a.[DEFAULT_DATE] > a.[DATE] and Cast(Year(Dateadd(m,-1,a.[DEFAULT_DATE])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,-1,a.[DEFAULT_DATE])) as varchar(2)), 2) = a.[MONTH] then 'Y'
	  when a.[DEFAULT_DATE] is not null and a.[DEFAULT_DATE] > a.[DATE] and Cast(Year(Dateadd(m,-2,a.[DEFAULT_DATE])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,-2,a.[DEFAULT_DATE])) as varchar(2)), 2) = a.[MONTH] then 'Y'
	  when a.[DEFAULT_DATE] is not null and a.[DEFAULT_DATE] > a.[DATE] and Cast(Year(Dateadd(m,-3,a.[DEFAULT_DATE])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,-3,a.[DEFAULT_DATE])) as varchar(2)), 2) = a.[MONTH] then 'Y'
	  else 'N' end as [3_MONTH_DEFAULT_FLAG]
	  ,datediff(m,a.[CREATION_DATE],a.[DATE]) + 1 as [MONTH_END_SINCE_CREATION]
	  ,case when a.[CLOSURE_DATE] is not null and a.[CLOSURE_DATE] > a.[DATE] and Cast(Year(Dateadd(m,-1,a.[CLOSURE_DATE])) as varchar(4)) + Right('00' + Cast(Month(Dateadd(m,-1,a.[CLOSURE_DATE])) as varchar(2)), 2) = a.[MONTH] then 1
	  else 0 end as [CLOSURE_MONTH]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Final]

FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Temp] a

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Acc_SAS] b
on a.[ACCOUNT_NUMBER] = b.[ACCOUNT_NUMBER]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS] c
on a.[PRIMARY_CUSTOMER_ID] = c.[CUSTOMER_ID]

LEFT JOIN [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Mort_Cus_SAS] d
on a.[SECONDARY_CUSTOMER_ID] = d.[CUSTOMER_ID]