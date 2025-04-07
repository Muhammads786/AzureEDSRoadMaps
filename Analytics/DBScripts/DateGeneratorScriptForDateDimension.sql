/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @Year INT = 2015
WHILE @Year<=2030
BEGIN
INSERT INTO COVID.DIM_DATE
                         (DateKey, FullDateAlternateKey, DayNumberOfWeek, EnglishDayNameOfWeek, SpanishDayNameOfWeek, FrenchDayNameOfWeek, DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear, EnglishMonthName, 
                         SpanishMonthName, FrenchMonthName, MonthNumberOfYear, CalendarQuarter, CalendarYear, CalendarSemester, FiscalQuarter, FiscalYear, FiscalSemester)
SELECT [DateKey]+10000
      ,DATEADD(YEAR,1,[FullDateAlternateKey]) [FullDateAlternateKey]
      ,DATEPART(dw,DATEADD(Y,1,[FullDateAlternateKey])) [DayNumberOfWeek]
      ,DATENAME(dw,DATEADD(Y,1,[FullDateAlternateKey])) [EnglishDayNameOfWeek]
      ,s.MAPPING_VALUE [SpanishDayNameOfWeek]
      ,f.MAPPING_VALUE [FrenchDayNameOfWeek]
      ,DATEPART(dd,DATEADD(Y,1,[FullDateAlternateKey]))[DayNumberOfMonth]
      ,DATEPART(dy,DATEADD(Y,1,[FullDateAlternateKey])) [DayNumberOfYear]
      ,DATEPART(wk,DATEADD(Y,1,[FullDateAlternateKey])) [WeekNumberOfYear]
      ,DATENAME(mm,DATEADD(Y,1,[FullDateAlternateKey])) [EnglishMonthName]
      ,[SpanishMonthName]
      ,[FrenchMonthName]
      ,[MonthNumberOfYear]
      ,[CalendarQuarter]
      ,[CalendarYear]+1 [CalendarYear]
      ,[CalendarSemester]
      ,[FiscalQuarter]
      ,[FiscalYear]+1 [FiscalYear]
      ,[FiscalSemester]
  FROM [DataGenerator].[COVID].[DIM_DATE] x
  INNER JOIN (
  SELECT [MAPPING_CODE],[MAPPING_VALUE]      
  FROM [DataGenerator].[dbo].[TBL_MAPPING_CODE]
  WHERE [MAPPING_TYPE]='Week_Name_Spanish'
  )s ON DATEPART(dw,DATEADD(Y,1,[FullDateAlternateKey]))=s.MAPPING_CODE
  INNER JOIN (
  SELECT [MAPPING_CODE],[MAPPING_VALUE]      
  FROM [DataGenerator].[dbo].[TBL_MAPPING_CODE]
  WHERE [MAPPING_TYPE]='Week_Name_French'
  )f ON DATEPART(dw,DATEADD(Y,1,[FullDateAlternateKey]))=f.MAPPING_CODE
  WHERE YEAR(FullDateAlternateKey)=@Year 

  SELECT @Year = @Year+1

END 