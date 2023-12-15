/****** Object:  Procedure [dbo].[ETLStep0And1Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================        
-- Author:  SADAF MALIK                        
-- CREATE date: 17 JAN, 2022                           
-- ALTER date:                           
-- Reviewer:                          
-- Description: ETL Pre-execution Validations.                          
-- =============================================                           
-- =============================================                           

CREATE   PROCEDURE dbo.ETLStep0And1Perform (
@pStatementProcessId DECIMAL(18, 0),
@pUserId INT)

AS
BEGIN


	CREATE TABLE #InvalidData (
		LOG_MESSAGE VARCHAR(MAX)
	   ,ERROR_LEVEL VARCHAR(MAX)
	);

	DECLARE @luaccountingMonth AS INT ;

select 	@luaccountingMonth = LuAccountingMonth_Id_Current
from MtStatementProcess where MtStatementProcess_ID=@pStatementProcessId

DECLARE @FromDate AS DATETIME;
DECLARE @ToDate AS DATETIME;

DROP TABLE IF EXISTS #StatementIDs

/*==========================================================================================
		Get From date and To Date of Financial Year
		==========================================================================================*/
SELECT
	@FromDate = LuAccountingMonth_FromDate
   ,@ToDate = LuAccountingMonth_ToDate
FROM LuAccountingMonth
WHERE LuAccountingMonth_Id = @luaccountingMonth

/*==========================================================================================
		Check Reference values w.r.t Effective date
		==========================================================================================*/


DECLARE @vRefValMessage VARCHAR(MAX) = '';

	SELECT
		@vRefValMessage =
		CASE
			WHEN (MAX(
				CASE
					WHEN ( 
					@FromDate>= rrv.RuReferenceValue_EffectiveFrom and 
					@ToDate BETWEEN ISNULL(rrv.RuReferenceValue_EffectiveFrom,GETDATE()) AND ISNULL(rrv.RuReferenceValue_EffectiveTo, GetDate()) AND
						ISNULL(srt.SrReferenceType_Name, '') = 'Cap on Transmission Losses NTDC') THEN 1
					ELSE 0
				END)) = 0 THEN 'Missing value for Cap on Transmission Losses NTDC. '
			ELSE ''
		END
		+
				CASE
			WHEN (MAX(
				CASE
					WHEN ( 
					@FromDate>= rrv.RuReferenceValue_EffectiveFrom and 
					@ToDate BETWEEN ISNULL(rrv.RuReferenceValue_EffectiveFrom,GETDATE()) AND ISNULL(rrv.RuReferenceValue_EffectiveTo, GetDate()) AND
						ISNULL(srt.SrReferenceType_Name, '') = 'Cap on Transmission Losses Mitari') THEN 1
					ELSE 0
				END)) = 0 THEN 'Missing value for Cap on Transmission Losses Mitari. '
			ELSE ''
		END

	FROM RuReferenceValue rrv
	JOIN SrReferenceType srt
		ON rrv.SrReferenceType_Id = srt.SrReferenceType_Id
	WHERE ISNULL(rrv.RuReferenceValue_IsDeleted, 0) = 0
	AND ISNULL(srt.SrReferenceType_IsDeleted, 0) = 0

	IF @vRefValMessage <> ''
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES (@vRefValMessage, 'Warning');
	END
	/***************************************************
	Call ETL Fetch Data Stored procedure to perform validations afterward
	*************************************************/
EXEC [dbo].[ETLFetchData] @pStatementProcessId


	/***************************************************
	Generate hourly profile between from date and to date
	*************************************************/
	  DROP TABLE if EXISTS #TempHours;  
  
  
DECLARE @INC_Hour as int=1;  

with ROWCTE as    
   (    
      SELECT @FromDate as dateTimeHour     
  UNION ALL    
      SELECT DATEADD(HOUR, @INC_Hour, dateTimeHour)   
  FROM  ROWCTE    
  WHERE dateTimeHour < @ToDate  
    )    
   
SELECT *   
INTO #TempHours  
FROM ROWCTE  
OPTION(MAXRECURSION 0); --There is no way to perform a recursion more than 32767   

	/***************************************************
	Hourly Transmission Losses
	*************************************************/

Declare @vMissingHoursForTransmissionLosses as nvarchar(max)=null;

	select @vMissingHoursForTransmissionLosses=STRING_AGG(CAST(
CONVERT(varchar,t.datetimehourly,20)

as NVARCHAR(MAX)),',') from (
select
distinct 
DATETIMEFROMPARTS (EtlTspHourly_Year, EtlTspHourly_Month, EtlTspHourly_Day, EtlTspHourly_Hour-1,0,0,0) as datetimehourly 
from EtlTspHourly
 where ISNULL( EtlTspHourly_TransmissionLoss ,0)=0
 AND MtStatementProcess_ID=@pStatementProcessId
) as t

	if(@vMissingHoursForTransmissionLosses is not null)
	BEGIN
			INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('Transmission Losses TSP values missing for '+cast(@vMissingHoursForTransmissionLosses as NVARCHAR(MAX)), 'Warning');

	END;
	

	/***************************************************
	Hourly Transmission Losses
	*************************************************/

Declare @vMissingHoursForTransmittedEnergy as nvarchar(max)=null;

	select @vMissingHoursForTransmittedEnergy=STRING_AGG(CAST(
CONVERT(varchar,t.datetimehourly,20)

as NVARCHAR(MAX)),',') from (
select
distinct 
DATETIMEFROMPARTS (EtlTspHourly_Year, EtlTspHourly_Month, EtlTspHourly_Day, EtlTspHourly_Hour-1,0,0,0) as datetimehourly 
from EtlTspHourly

 where 
 (ISNULL( EtlTspHourly_AdjustedEnergyImport ,0)=0 or  ISNULL( EtlTspHourly_AdjustedEnergyExport ,0)=0
 )  AND MtStatementProcess_ID=@pStatementProcessId
) as t

	if(@vMissingHoursForTransmittedEnergy is not null)
	BEGIN
			INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('Transmitted Energy of TSP values missing for '+cast(@vMissingHoursForTransmittedEnergy as NVARCHAR(MAX)), 'Warning');

	END;


	/***************************************************
	Hourly Transmission Losses
	*************************************************/

Declare @vMissingHoursForDemand as nvarchar(max)=null;

	select @vMissingHoursForDemand=STRING_AGG(CAST(
CONVERT(varchar,t.datetimehourly,20)

as NVARCHAR(MAX)),',') from (
select
distinct 
DATETIMEFROMPARTS (EtlHourly_Year, EtlHourly_Month, EtlHourly_Day, EtlHourly_Hour-1,0,0,0) as datetimehourly 
from EtlHourly

 where 
 (ISNULL( EtlHourly_Demand ,0)=0
 )  AND MtStatementProcess_ID=@pStatementProcessId
) as t

	if(@vMissingHoursForDemand is not null)
	BEGIN
			INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('Demand values missing for '+cast(@vMissingHoursForDemand as NVARCHAR(MAX)), 'Warning');

	END;

	/***************************************************
	Hourly Marginal Price Losses
	*************************************************/

Declare @vMissingHoursForMarginalPrice as nvarchar(max)=null;

	select @vMissingHoursForMarginalPrice=STRING_AGG(CAST(
CONVERT(varchar,t.datetimehourly,20)

as NVARCHAR(MAX)),',') from (
select
distinct 
DATETIMEFROMPARTS (EtlHourly_Year, EtlHourly_Month, EtlHourly_Day, EtlHourly_Hour-1,0,0,0) as datetimehourly 
from EtlHourly

 where 
 (ISNULL( EtlHourly_MarginalPrice ,0)=0
 )  AND MtStatementProcess_ID=@pStatementProcessId
) as t

	if(@vMissingHoursForMarginalPrice is not null)
	BEGIN
			INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('Marginal Price values missing for '+cast(@vMissingHoursForMarginalPrice as NVARCHAR(MAX)), 'Warning');

	END;

		IF EXISTS (SELECT
			TOP 1
				1
			FROM #InvalidData id)
	BEGIN
		INSERT INTO MtSattlementProcessLogs (MtStatementProcess_ID
		, MtSattlementProcessLog_Message
		, MtSattlementProcessLog_ErrorLevel
		, MtSattlementProcessLog_CreatedBy
		, MtSattlementProcessLog_CreatedOn)
			SELECT
				@pStatementProcessId
			   ,id.LOG_MESSAGE
			   ,id.ERROR_LEVEL
			   ,@pUserId
			   ,GETDATE()
			FROM #InvalidData id

		RAISERROR ('ETL basic validations failure. Please refer to the previous logs for further details.', 16, -1);
	
	RETURN;
	END


END
