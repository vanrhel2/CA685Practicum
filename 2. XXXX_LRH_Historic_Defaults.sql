/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct a.[DATE]
				,b.[TOTAL_ACCOUNTS]
				,c.[DEFAULT_ACCOUNTS]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Final] a

  LEFT JOIN (

SELECT distinct [DATE]
      ,count(*) as [TOTAL_ACCOUNTS]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Final]

  group by [DATE]
  ) b
  on a.[DATE] = b.[DATE]

 LEFT JOIN (

  SELECT distinct [DATE]
      ,count(*) as [DEFAULT_ACCOUNTS]
  FROM [ETZ335IH_PROJECT_JERSEY].[dbo].[XXXX_LRH_Historic_Master_Final]
  
  where [1_MONTH_DEFAULT_FLAG] = 'Y'
  
  group by [DATE]
  ) c
  on a.[DATE] = c.[DATE]
  
  where a.[DATE] <> '2013-12-31'
  
  order by [DATE]
