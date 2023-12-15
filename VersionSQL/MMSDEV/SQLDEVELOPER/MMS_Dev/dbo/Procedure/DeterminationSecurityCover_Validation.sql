/****** Object:  Procedure [dbo].[DeterminationSecurityCover_Validation]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  ALINA JAVED
-- CREATE date: 20 June 2023
-- Description: 
-- ============================================= 
--  dbo.DeterminationSecurityCover_Validation  1201,1
 CREATE   PROCEDURE dbo.DeterminationSecurityCover_Validation  
@MtSOFileMaster_Id DECIMAL(18,0),                          
@userID DECIMAL(18,0)             
AS                          
BEGIN
   
/***********************************************/

DROP TABLE IF EXISTS #temp;

 

Declare @i int;
Declare @y int;
SELECT
    @i = DATEPART(MONTH, DATEADD(MONTH, 1, LM.LuAccountingMonth_FromDate))
   ,@y = DATEPART(Year, DATEADD(MONTH, 1, LM.LuAccountingMonth_FromDate))
FROM MtSOFileMaster SO
JOIN LuAccountingMonth LM
    ON SO.LuAccountingMonth_Id = LM.LuAccountingMonth_Id
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id

 

SELECT
    @y AS YearNo,@i AS MonthNo INTO #temp

 
 SET @i=2;
            WHILE @i < 7
            BEGIN
INSERT INTO #temp
    SELECT
        DATEPART(year, DATEADD(MONTH, @i, LM.LuAccountingMonth_FromDate))
        ,DATEPART(MONTH, DATEADD(MONTH, @i, LM.LuAccountingMonth_FromDate))
    FROM MtSOFileMaster SO
    JOIN LuAccountingMonth LM
        ON SO.LuAccountingMonth_Id = LM.LuAccountingMonth_Id
    WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id

 

SET @i = @i + 1;
            END;

 

    Declare @SequenceChk int=0
    SELECT @SequenceChk=COUNT(1) FROM #temp t
    JOIN MTDeterminationofSecurityCover_Interface SC
    ON SC.MTDeterminationofSecurityCover_Interface_Month=CAST(t.MonthNO AS VARCHAR(15))
    AND SC.MTDeterminationofSecurityCover_Interface_Year=CAST(t.YearNo AS VARCHAR(15))
    WHERE SC.MtSOFileMaster_Id=@MtSOFileMaster_Id


	
/***********************************************/
 select DISTINCT(MTDeterminationofSecurityCover_Interface_ContractType) as contracttype from MTDeterminationofSecurityCover_Interface where MtSOFileMaster_Id=@MtSOFileMaster_Id

DECLARE @month VARCHAR(15);
SELECT @month = AM.LuAccountingMonth_Month
FROM MtSOFileMaster
INNER JOIN LuAccountingMonth AM ON AM.LuAccountingMonth_Id = MtSOFileMaster.LuAccountingMonth_Id
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id;

DECLARE @year VARCHAR(15);
SELECT @year = AM.LuAccountingMonth_Year
FROM MtSOFileMaster
INNER JOIN LuAccountingMonth AM ON AM.LuAccountingMonth_Id = MtSOFileMaster.LuAccountingMonth_Id
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id;

DECLARE @dspname varchar(250);
select @dspname=MTDeterminationofSecurityCover_Interface_DSP from MTDeterminationofSecurityCover_Interface where MtSOFileMaster_Id=@MtSOFileMaster_Id

DECLARE @dspCount INT
SELECT @dspCount = COUNT(DISTINCT MTDeterminationofSecurityCover_Interface_DSP) FROM MTDeterminationofSecurityCover_Interface where MtSOFileMaster_Id=@MtSOFileMaster_Id

DECLARE @LVCount INT
SELECT @LVCount = COUNT(DISTINCT MTDeterminationofSecurityCover_Interface_LineVoltage) FROM MTDeterminationofSecurityCover_Interface where MtSOFileMaster_Id=@MtSOFileMaster_Id

UPDATE MDF
SET MDF.MTDeterminationofSecurityCover_Interface_Message =
CASE      --- Year ----
	WHEN ISNULL(MDF.MTDeterminationofSecurityCover_Interface_Year, '') = '' THEN 'Year cannot be empty, '
	--- less than 4 count----    
	WHEN LEN(MDF.MTDeterminationofSecurityCover_Interface_Year) != 4 THEN 'Invalid Year, '
	WHEN ISNUMERIC(MDF.MTDeterminationofSecurityCover_Interface_Year) = 0 THEN 'Year contains only numbers, '
	--WHEN @year <> MDF.MTDeterminationofSecurityCover_Interface_Year THEN 'Invalid Year. '
	ELSE ''
END

-----Month ------
+CASE
         
        WHEN MDF.MTDeterminationofSecurityCover_Interface_Month LIKE '%.%.%' OR MDF.MTDeterminationofSecurityCover_Interface_Month LIKE '%[^0-9]%'   THEN 'Decimal values are not allowed, '
        WHEN MDF.MTDeterminationofSecurityCover_Interface_Month NOT LIKE '%.%' AND ISNUMERIC(MDF.MTDeterminationofSecurityCover_Interface_Month) = 0 THEN 'Month contains only numbers, '
		 --WHEN MTDeterminationofSecurityCover_Interface_Month NOT IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12')
		 WHEN MTDeterminationofSecurityCover_Interface_Month <1 OR MTDeterminationofSecurityCover_Interface_Month > 12
            THEN 'Invalid Month, '
        WHEN ISNULL(MDF.MTDeterminationofSecurityCover_Interface_Month, '') = '' THEN 'Month cannot be empty, '
       
     WHEN @SequenceChk<>6 then 'Month or Year values must form a consecutive sequence, '
        /*WHEN (
            (SELECT COUNT(DISTINCT MDF2.MTDeterminationofSecurityCover_Interface_Month)
            FROM MTDeterminationofSecurityCover_Interface MDF2
            WHERE MDF2.MtSOFileMaster_Id = @MtSOFileMaster_Id)
            <> 6
            )
        THEN 'No of months is less than 6 or have repetition, '
        WHEN (
            (SELECT MIN(MDF2.MTDeterminationofSecurityCover_Interface_Month)
            FROM MTDeterminationofSecurityCover_Interface MDF2
            WHERE MDF2.MtSOFileMaster_Id = @MtSOFileMaster_Id)
            + 5)
            <>
            (SELECT MAX(MDF2.MTDeterminationofSecurityCover_Interface_Month)
            FROM MTDeterminationofSecurityCover_Interface MDF2
            WHERE MDF2.MtSOFileMaster_Id = @MtSOFileMaster_Id)
        THEN 'Month values must form a sequence of six consecutive months, '
		--WHEN @month < MTDeterminationofSecurityCover_Interface_Month
		--THEN 'Month should be greater than settlement period. '
		*/
        ELSE ''
    END
 ------line voltage------

 +CASE
  
	--WHEN EXISTS (SELECT
	--			pr.Lu_DistLosses_LineVoltage
	--		FROM Lu_DistLosses pr
	--		WHERE Lu_DistLosses_MP_Name=@dspname and CAST(Lu_DistLosses_LineVoltage AS VARCHAR(256)) <> CAST(MTDeterminationofSecurityCover_Interface_LineVoltage AS VARCHAR(256)))
	--		 THEN 'Line Voltage does not exist, '
	WHEN ISNULL(MDF.MTDeterminationofSecurityCover_Interface_LineVoltage, '') = '' THEN 'Line Voltage cannot be empty, '
	WHEN ISNUMERIC(MDF.MTDeterminationofSecurityCover_Interface_LineVoltage) = 0 THEN 'Line Voltage contain only numbers, '
	WHEN CONVERT(DECIMAL, MDF.MTDeterminationofSecurityCover_Interface_LineVoltage) < 0 THEN 'Line Voltage contains only positive values, '
	WHEN @LVCount > 1  THEN 'Multiple LineVoltage not allowed, '            
	ELSE ''
END


 ------Monthly Gen Dispatch ------
+CASE
	WHEN ISNULL(MDF.MTDeterminationofSecurityCover_Interface_GeneratorDispatchProfileforMonth_MWh, '') = '' THEN 'Monthly Gen Dispatch cannot be empty, '
	WHEN ISNUMERIC(MDF.MTDeterminationofSecurityCover_Interface_GeneratorDispatchProfileforMonth_MWh) = 0 THEN 'Monthly Gen Dispatch contain only numbers, '
	WHEN CONVERT(DECIMAL, MDF.MTDeterminationofSecurityCover_Interface_GeneratorDispatchProfileforMonth_MWh) < 0 THEN 'Monthly Gen Dispatch contains only positive values, '
	ELSE ''
END

 ------DSP ------
+CASE
	WHEN ISNULL(MDF.MTDeterminationofSecurityCover_Interface_DSP, '') = '' THEN 'DSP cannot be empty, '	
	WHEN @dspCount > 1 THEN 'Multiple DSP not allowed, '
	WHEN not exists(SELECT
	1
FROM MtPartyRegisteration
WHERE MtPartyRegisteration_Name IN (SELECT DISTINCT
		(MTDeterminationofSecurityCover_Interface_DSP)
	FROM [dbo].[MTDeterminationofSecurityCover_Interface]
	WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id
)) THEN ' DSP name not exists.'
	ELSE ''
END

 ------LoadProfileBuyer ------
+CASE
	WHEN ISNULL(MDF.MTDeterminationofSecurityCover_Interface_LoadProfileBuyer, '') = '' THEN 'Load Profile Buyer cannot be empty, '
	WHEN ISNUMERIC(MDF.MTDeterminationofSecurityCover_Interface_LoadProfileBuyer) = 0 THEN 'Load Profile Buyer contain only numbers, '
	WHEN CONVERT(DECIMAL, MDF.MTDeterminationofSecurityCover_Interface_LoadProfileBuyer) < 0 THEN 'Load Profile Buyer contains only positive values, '
	ELSE ''
END

 ------Fixed QTY Contract ------
+CASE
	WHEN MDF.MTDeterminationofSecurityCover_Interface_ContractType IN ('Load Following', 'Generation Following') and MDF.MTDeterminationofSecurityCover_Interface_FixedQtyContract <> '' THEN 'Fixed Quantity Contract must be empty, '

	WHEN MDF.MTDeterminationofSecurityCover_Interface_ContractType = 'Fixed Quantity' and ISNULL(MDF.MTDeterminationofSecurityCover_Interface_FixedQtyContract,'') ='' THEN 'Fixed Quantity Contract cannot be empty, '
	
	WHEN MDF.MTDeterminationofSecurityCover_Interface_ContractType = 'Fixed Quantity' and ISNUMERIC(MDF.MTDeterminationofSecurityCover_Interface_FixedQtyContract) = 0 THEN 'Fixed Quantity Contract contain only numbers, '

	WHEN MDF.MTDeterminationofSecurityCover_Interface_FixedQtyContract <= 0 and MDF.MTDeterminationofSecurityCover_Interface_ContractType = 'Fixed Quantity' THEN 'Fixed Quantity Contract must be greater than zero, '	   
	
	ELSE ''
END

-------------contract type---------------
+CASE
        WHEN (
            SELECT 
                SUM(CASE WHEN MTDeterminationofSecurityCover_Interface_ContractType = 'Load Following' THEN 1 ELSE 0 END) 
            FROM MTDeterminationofSecurityCover_Interface
            WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id
        ) = 6 THEN ''
        WHEN (
            SELECT 
                SUM(CASE WHEN MTDeterminationofSecurityCover_Interface_ContractType = 'Generation Following' THEN 1 ELSE 0 END) 
            FROM MTDeterminationofSecurityCover_Interface
            WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id
        ) = 6 THEN ''
        when (
            SELECT 
                SUM(CASE WHEN MTDeterminationofSecurityCover_Interface_ContractType = 'Fixed Quantity' THEN 1 ELSE 0 END) 
            FROM MTDeterminationofSecurityCover_Interface
            WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id
        ) = 6 
        THEN ' '
        ELSE 'Multiple contract types not allowed, '
    END

------Monthly Avg MarginalPrice ------
+CASE
	WHEN ISNULL(MDF.MTDeterminationofSecurityCover_Interface_MonthlyAvgMarginalPrice, '') = '' THEN 'Monthly Avg MarginalPrice cannot be empty, '
	WHEN ISNUMERIC(MDF.MTDeterminationofSecurityCover_Interface_MonthlyAvgMarginalPrice) = 0 THEN 'Monthly Avg MarginalPrice contain only numbers, '
	WHEN MDF.MTDeterminationofSecurityCover_Interface_MonthlyAvgMarginalPrice = 0 THEN 'Monthly Avg MarginalPrice cannot be zero, '
	WHEN CONVERT(DECIMAL, MDF.MTDeterminationofSecurityCover_Interface_MonthlyAvgMarginalPrice) < 0 THEN 'Monthly Avg MarginalPrice contains only positive values, '
	ELSE ''
END

-------buyer ID------
+
CASE
	WHEN EXISTS (SELECT
				pr.MtPartyRegisteration_Id
			FROM MtPartyRegisteration pr
			WHERE CAST(MDF.MTDeterminationofSecurityCover_Interface_Buyer_Id AS VARCHAR(256)) = CAST(pr.MtPartyRegisteration_Id AS VARCHAR(256))
			AND ISNULL(pr.isDeleted, 0) = 0) THEN ''
	ELSE 'Buyer Id does not exist, '
END
--------Seller ID-----------
+
CASE
	WHEN EXISTS (SELECT
				pr.MtPartyRegisteration_Id
			FROM MtPartyRegisteration pr
			WHERE CAST(MDF.MTDeterminationofSecurityCover_Interface_Seller_Id AS VARCHAR(256)) = CAST(pr.MtPartyRegisteration_Id AS VARCHAR(256))
			AND ISNULL(pr.isDeleted, 0) = 0) THEN ''
	ELSE 'Seller Id does not exist, '
END

FROM [dbo].[MTDeterminationofSecurityCover_Interface] MDF
WHERE MDF.MtSOFileMaster_Id = @MtSOFileMaster_Id



UPDATE MDF
SET MDF.MTDeterminationofSecurityCover_Interface_Message = LEFT(MTDeterminationofSecurityCover_Interface_Message, LEN(MTDeterminationofSecurityCover_Interface_Message) - 1)
FROM MTDeterminationofSecurityCover_Interface MDF
WHERE MDF.MtSOFileMaster_Id = @MtSOFileMaster_Id
AND ISNULL(MDF.MTDeterminationofSecurityCover_Interface_Message, '') <> ''
AND ISNULL(MDF.MTDeterminationofSecurityCover_Interface_IsDeleted, 0) = 0

UPDATE MDF
SET MDF.MTDeterminationofSecurityCover_Interface_IsValid = 0
FROM MTDeterminationofSecurityCover_Interface MDF
WHERE MDF.MtSOFileMaster_Id = @MtSOFileMaster_Id
AND ISNULL(MDF.MTDeterminationofSecurityCover_Interface_Message, '') <> ''
AND ISNULL(MDF.MTDeterminationofSecurityCover_Interface_IsDeleted, 0) = 0

IF EXISTS (SELECT
			1
		FROM [dbo].[MTDeterminationofSecurityCover_Interface]
		WHERE MTDeterminationofSecurityCover_Interface_IsValid = 0
		AND MtSOFileMaster_Id = @MtSOFileMaster_Id)
BEGIN
;
WITH CTE
AS
(SELECT
		MTDeterminationofSecurityCover_Interface_RowNumber
	   ,MTDeterminationofSecurityCover_Interface_IsValid
	   ,MTDeterminationofSecurityCover_Id
	   ,ROW_NUMBER() OVER (ORDER BY MTDeterminationofSecurityCover_Interface_IsValid, MTDeterminationofSecurityCover_Interface_RowNumber) AS MTDeterminationofSecurityCover_RowNumber_new
	FROM MTDeterminationofSecurityCover_Interface
	WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id--                  
)

UPDATE M
SET MTDeterminationofSecurityCover_Interface_RowNumber = MTDeterminationofSecurityCover_RowNumber_new
FROM [dbo].[MTDeterminationofSecurityCover_Interface] M
INNER JOIN CTE c
	ON c.MTDeterminationofSecurityCover_Id = m.MTDeterminationofSecurityCover_Id
WHERE m.MtSOFileMaster_Id = @MtSOFileMaster_Id--MtSOFileMaster_Id=277                  


END

DECLARE @vInvalidCount BIGINT = 0;

SELECT
	@vInvalidCount = COUNT(1)
FROM [dbo].[MTDeterminationofSecurityCover_Interface] MDF
WHERE MDF.MtSOFileMaster_Id = @MtSOFileMaster_Id
AND ISNULL(MDF.MTDeterminationofSecurityCover_Interface_IsDeleted, 0) = 0
AND MTDeterminationofSecurityCover_Interface_IsValid = 0

DECLARE @vTotalRecords BIGINT = 0;

SELECT
	@vTotalRecords = COUNT(1)
FROM [dbo].[MTDeterminationofSecurityCover_Interface] maii
WHERE maii.MtSOFileMaster_Id = @MtSOFileMaster_Id
AND ISNULL(maii.MTDeterminationofSecurityCover_Interface_IsDeleted, 0) = 0;


UPDATE MtSOFileMaster
SET InvalidRecords = @vInvalidCount
   ,TotalRecords = @vTotalRecords
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id
SELECT
	@vInvalidCount
   ,@vTotalRecords;
END
