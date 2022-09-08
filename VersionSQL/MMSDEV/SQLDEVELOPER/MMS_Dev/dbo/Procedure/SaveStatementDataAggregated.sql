/****** Object:  Procedure [dbo].[SaveStatementDataAggregated]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf | Ali
--Reviewer : <>
--CreatedDate :10 May 2022
--======================================================================
-- EXECUTE SaveStatementDataAggregated @StatementProcessId=156, @Year=2021, @Month=11
--Select * from [dbo].[StatementDataAggregated]	WHERE MtStatementProcess_ID =156 
CREATE PROCEDURE [dbo].[SaveStatementDataAggregated] @Year INT,
@Month INT,
@StatementProcessId DECIMAL(18, 0)

AS
BEGIN


	DECLARE @vBMEMTStatementProcessId DECIMAL(18, 0);
	DECLARE @vLuAccountingMonth_Id INT;
	DECLARE @vSrStatementDef_ID INT;
	/***********************************************************************
	
	***********************************************************************/

	IF EXISTS (SELECT
				1
			FROM [dbo].[StatementDataAggregated]
			WHERE MtStatementProcess_ID = @StatementProcessId)--@StatementProcessId
	BEGIN
		DELETE FROM [dbo].[StatementDataAggregated]
		WHERE MtStatementProcess_ID = @StatementProcessId
	END
	/***********************************************************************
	
	***********************************************************************/
		SELECT
		@vSrStatementDef_ID = SrStatementDef_ID
	FROM SrProcessDef spd
	WHERE spd.SrProcessDef_ID = (SELECT
			SrProcessDef_ID
		FROM MtStatementProcess
		WHERE MtStatementProcess_ID = @StatementProcessId)

	/***********************************************************************
	
	***********************************************************************/
	INSERT INTO [dbo].[StatementDataAggregated] ([StatementDataAggregated_Month]
	, [StatementDataAggregated_Year]
	, [SrStatementDef_ID]
	, [SrProcessDef_ID]
	, [LuAccountingMonth_Id]
	, [MtStatementProcess_ID]
	, StatementDataAggregated_PartyRegisteration_Id
	, StatementDataAggregated_PartyName
	, [StatementDataAggregated_CreatedBy]
	, [StatementDataAggregated_CreatedOn]
	, [StatementDataAggregated_IsDeleted])

		SELECT
			LAM.LuAccountingMonth_Month
		   ,LAM.LuAccountingMonth_Year
		   ,@vSrStatementDef_ID
		   ,msp.SrProcessDef_ID
		   ,msp.LuAccountingMonth_Id_Current
		   ,@StatementProcessId
		   ,BP.PartyRegisteration_Id
		   ,BP.PartyRegisteration_Name
		   ,100
		   ,GETUTCDATE()
		   ,0
		FROM [dbo].[Bme_Parties] BP
			,MtStatementProcess msp
			 JOIN LuAccountingMonth LAM
				 ON LAM.LuAccountingMonth_Id = msp.LuAccountingMonth_Id_Current
		WHERE msp.MtStatementProcess_ID = @StatementProcessId
		AND BP.PartyType_Code = 'MP'



	/***********************************************************************
	
	***********************************************************************/

	SELECT
		@vLuAccountingMonth_Id = msp.LuAccountingMonth_Id_Current
	FROM MtStatementProcess msp
	WHERE msp.MtStatementProcess_ID = @StatementProcessId


	SET @vBMEMTStatementProcessId= [dbo].[GetBMEtatementProcessIdFromASC](@StatementProcessId)

	--SELECT DISTINCT
	--	@vBMEMTStatementProcessId = msp.MtStatementProcess_ID

	--FROM [StatementDataAggregated] SDA
	--JOIN MtStatementProcess msp
	--	ON SDA.LuAccountingMonth_Id = msp.LuAccountingMonth_Id_Current
	--WHERE msp.SrProcessDef_ID IN (SELECT 
	--		spd.SrProcessDef_ID
	--	FROM SrProcessDef spd
	--	WHERE spd.SrStatementDef_ID =@vSrStatementDef_ID
	--	AND spd.SrProcessDef_ID IN (1, 4, 7))
	--AND ISNULL(msp.MtStatementProcess_IsDeleted, 0) = 0
	--AND SDA.LuAccountingMonth_Id = @vLuAccountingMonth_Id

	/***********************************************************************
	
	***********************************************************************/

	UPDATE [dbo].[StatementDataAggregated]
	SET StatementDataAggregated_BmeStatementData_AmountPayableReceivable = BmeStatementData_AmountPayableReceivable
	FROM [dbo].[StatementDataAggregated] SDA
	INNER JOIN (SELECT
			BmeStatementData_PartyRegisteration_Id
		   ,BmeStatementData_AmountPayableReceivable
		FROM BmeStatementDataMpMonthly_SettlementProcess
		WHERE BmeStatementData_SettlementProcessId = @vBMEMTStatementProcessId --3
	) bme
		ON bme.BmeStatementData_PartyRegisteration_Id = SDA.StatementDataAggregated_PartyRegisteration_Id
	WHERE SDA.MtStatementProcess_ID = @StatementProcessId

	--/***********************************************************************

	--***********************************************************************/
	DECLARE @vASCMTStatementProcessId DECIMAL(18, 0)
	--SELECT DISTINCT
	--	@vASCMTStatementProcessId = msp.MtStatementProcess_ID
	--FROM [StatementDataAggregated] SDA
	--JOIN MtStatementProcess msp
	--	ON SDA.LuAccountingMonth_Id = msp.LuAccountingMonth_Id_Current
	--WHERE msp.SrProcessDef_ID IN (SELECT
	--		spd.SrProcessDef_ID
	--	FROM SrProcessDef spd
	--	WHERE spd.SrStatementDef_ID = @vSrStatementDef_ID
	--	AND spd.SrProcessDef_ID IN (2, 5, 8))
	--AND ISNULL(msp.MtStatementProcess_IsDeleted, 0) = 0
	set @vASCMTStatementProcessId=[dbo].[GetASCtatementProcessId](@StatementProcessId)

	--/***********************************************************************

	--***********************************************************************/

	UPDATE [dbo].[StatementDataAggregated]
	SET StatementDataAggregated_AscStatementData_PAYABLE = AscStatementData_PAYABLE
	   ,StatementDataAggregated_AscStatementData_RECEIVABLE = AscStatementData_RECEIVABLE
	FROM [dbo].[StatementDataAggregated] SDA
	INNER JOIN (SELECT
			AscStatementData_PartyRegisteration_Id
		   ,AscStatementData_PAYABLE
		   ,AscStatementData_RECEIVABLE
		FROM AscStatementDataMpMonthly
	WHERE  AscStatementData_StatementProcessId = @vASCMTStatementProcessId
	) bme
		ON bme.AscStatementData_PartyRegisteration_Id = SDA.StatementDataAggregated_PartyRegisteration_Id
	WHERE SDA.MtStatementProcess_ID = @StatementProcessId 

	--/*************************************************************************
	--	Update New Amount
	--**************************************************************************/
		UPDATE [dbo].[StatementDataAggregated] 
	SET StatementDataAggregated_NetAmount= ISNULL(StatementDataAggregated_AscStatementData_PAYABLE,0)+ISNULL(StatementDataAggregated_AscStatementData_RECEIVABLE,0)+IsNull(StatementDataAggregated_BmeStatementData_AmountPayableReceivable,0)
	WHERE MtStatementProcess_ID = @StatementProcessId 

	SELECT
		@@rowcount;
END
