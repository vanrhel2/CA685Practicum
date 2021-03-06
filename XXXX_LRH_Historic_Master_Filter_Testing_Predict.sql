/****** Script for SelectTopNRows command from SSMS  ******/
DROP TABLE [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

SELECT  [MONTH]
      ,[DATE]
      ,[ACCOUNT_NUMBER]
      ,[NO_OWNERS]
      ,[PRIMARY_CUSTOMER_ID]
      ,[SECONDARY_CUSTOMER_ID]
      ,[PRIMARY_CUSTOMER_START_DATE]
      ,[SECONDARY_CUSTOMER_START_DATE]
      ,[PRIMARY_CUSTOMER_ADDRESS]
      ,[SECONDARY_CUSTOMER_ADDRESS]
      ,[PRIMARY_CUSTOMER_OCCUPATION]
      ,[SECONDARY_CUSTOMER_OCCUPATION]
      ,[PRIMARY_CUSTOMER_SALARY]
      ,[SECONDARY_CUSTOMER_SALARY]
      ,[PRIMARY_CUSTOMER_AGE]
      ,[SECONDARY_CUSTOMER_AGE]
      ,[CREATION_DATE]
      ,[CREATION_YEAR]
      ,[CLOSURE_DATE]
      ,[DEFAULT_DATE]
      ,[PRODUKT_NR]
      ,[ORIGINAL_BALANCE]
      ,[LOAN_PURPOSE]
      ,[EUR_BALANCE]
      ,[EUR_LIMIT]
      ,[EUR_ARREARS]
      ,[DAYS_IN_ARREARS]
      ,[AVERAGE_MONTHS_IN_ARREARS]
      ,[REPAYMENT_AMOUNT]
      ,[REPAYMENT_FREQUENCY]
      ,[AVERAGE_MONTHLY_REPAYMENT_AMOUNT]
      ,[INTEREST_RATE]
      ,[INTEREST_CHARGED]
      ,[BALANCE_MOVEMENT]
      ,[CASHFLOW]
      ,[6_MONTH_BALANCE_MOVEMENT]
      ,[6_MONTH_CASHFLOW]
      ,[12_MONTH_BALANCE_MOVEMENT]
      ,[12_MONTH_CASHFLOW]
      ,[PROPERTY_ADDRESS]
      ,[LTV]
      ,[NO_MORT_ACCOUNTS]
      ,[NO_MORT_IN_DEFAULT]
      ,[MORT_BALANCE]
      ,[MORT_ARREARS]
      ,[MORT_AVERAGE_MONTHS_IN_ARREARS]
      ,[MORT_BALANCE_MOVEMENT]
      ,[MORT_LTV]
      ,[NO_PERS_CURR_ACCOUNTS]
      ,[NO_PERS_CURR_IN_DEFAULT]
      ,[PERS_CURR_BALANCE]
      ,[PERS_CURR_ARREARS]
      ,[PERS_CURR_AVERAGE_MONTHS_IN_ARRE]
      ,[PERS_CURR_BALANCE_MOVEMENT]
      ,[NO_SAVING_ACCOUNTS]
      ,[SAVING_BALANCE]
      ,[SAVING_BALANCE_MOVEMENT]
      ,[NO_PERS_LOAN_ACCOUNTS]
      ,[NO_PERS_LOAN_IN_DEFAULT]
      ,[PERS_LOAN_BALANCE]
      ,[PERS_LOAN_ARREARS]
      ,[PERS_LOAN_AVERAGE_MONTHS_IN_ARRE]
      ,[PERS_LOAN_BALANCE_MOVEMENT]
      ,[NO_BUS_CURR_ACCOUNTS]
      ,[NO_BUS_CURR_IN_DEFAULT]
      ,[BUS_CURR_BALANCE]
      ,[BUS_CURR_ARREARS]
      ,[BUS_CURR_AVERAGE_MONTHS_IN_ARREA]
      ,[BUS_CURR_BALANCE_MOVEMENT]
      ,[NO_BUS_LOAN_ACCOUNTS]
      ,[NO_BUS_LOAN_IN_DEFAULT]
      ,[BUS_LOAN_BALANCE]
      ,[BUS_LOAN_ARREARS]
      ,[BUS_LOAN_AVERAGE_MONTHS_IN_ARREA]
      ,[BUS_LOAN_BALANCE_MOVEMENT]
      ,[DEFAULT_FLAG]
      ,[PRE_DEFAULT_FLAG]
      ,[1_MONTH_DEFAULT_FLAG]
      ,[2_MONTH_DEFAULT_FLAG]
      ,[3_MONTH_DEFAULT_FLAG]
      ,[MONTH_END_SINCE_CREATION]
      ,[CLOSURE_MONTH]
      ,[_FROM_]
      ,[_INTO_]
	  ,[IP_N]
      ,round(cast(cast([IP_N] as float) as decimal(36,20)),5) as [IP_N_Decimal]
	  ,[IP_Y]
      ,round(cast(cast([IP_Y] as float) as decimal(36,20)),5) as [IP_Y_Decimal]
	  ,[_LEVEL_]
      ,[lower_1_MONTH_DEFAULT_FLAG]
      ,[upper_1_MONTH_DEFAULT_FLAG]
      ,[reschi_1_MONTH_DEFAULT_FLAG]
      ,[resdev_1_MONTH_DEFAULT_FLAG]
      ,[difdev_1_MONTH_DEFAULT_FLAG]
      ,[difchisq_1_MONTH_DEFAULT_FLAG]

INTO [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict]


Select 'Default' as [Predicted]
		,a.[Default]
		,b.[No Default]

FROM (
SELECT count(*) as [Default]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] >= 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'Y'
  ) a

  CROSS JOIN (
  SELECT count(*) as [No Default]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] >= 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'N'
  ) b

  UNION

  Select 'No Default' as [Predicted] 
		,a.[Default]
		,b.[No Default]

FROM (
SELECT count(*) as [Default]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] < 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'Y'
  ) a

  CROSS JOIN (
  SELECT count(*) as [No Default]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] < 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'N'
  ) b


  Select 'Default' as [Predicted]
		,a.[Default 1 Month]
		,b.[Default 2 Month]
		,c.[Default 3 Month]
		,d.[Default Ever]
		,e.[No Default]

FROM (
SELECT count(*) as [Default 1 Month]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] >= 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'Y'
  ) a

  CROSS JOIN (
  SELECT count(*) as [Default 2 Month]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] >= 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'N'
  and [2_MONTH_DEFAULT_FLAG] = 'Y'
  ) b

  CROSS JOIN (
  SELECT count(*) as [Default 3 Month]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] >= 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'N'
  and [2_MONTH_DEFAULT_FLAG] = 'N'
  and [3_MONTH_DEFAULT_FLAG] = 'Y'
  ) c

  CROSS JOIN (
  SELECT count(*) as [Default Ever]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] >= 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'N'
  and [2_MONTH_DEFAULT_FLAG] = 'N'
  and [3_MONTH_DEFAULT_FLAG] = 'N'
  and [DEFAULT_FLAG] = 'Y'
  ) d

  CROSS JOIN (
  SELECT count(*) as [No Default]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] >= 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'N'
  and [2_MONTH_DEFAULT_FLAG] = 'N'
  and [3_MONTH_DEFAULT_FLAG] = 'N'
  and [DEFAULT_FLAG] = 'N'
  ) e

  
  UNION

  Select 'No Default' as [Predicted] 
		,a.[Default 1 Month]
		,0 as [Default 2 Month]
		,0 as [Default 3 Month]
		,0 as [Default Ever]
		,b.[No Default]

FROM (
SELECT count(*) as [Default 1 Month]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] < 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'Y'
  ) a

  CROSS JOIN (
  SELECT count(*) as [No Default]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Filter_Testing_Predict_Decimal]

  where [IP_Y_Decimal] < 0.05
  and [1_MONTH_DEFAULT_FLAG] = 'N'
  ) b

