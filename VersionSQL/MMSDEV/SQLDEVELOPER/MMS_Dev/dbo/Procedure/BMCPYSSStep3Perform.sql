/****** Object:  Procedure [dbo].[BMCPYSSStep3Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran | AMMAMA GILL
-- CREATE date: 04 JAN 2023
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE   PROCEDURE dbo.BMCPYSSStep3Perform @pStatementProcessId DECIMAL(18, 0)

AS
BEGIN
/*==========================================================================================
Fetch BMC final statement ID
==========================================================================================*/

DECLARE @vBMCFinalStatementId DECIMAL(18,0);
 SELECT
        @vBMCFinalStatementId= [dbo].[GetBMCStatementProcessID] (@pStatementProcessId);
		
		--msp.MtStatementProcess_ID
  --      FROM MtStatementProcess msp
  --      WHERE msp.SrProcessDef_ID = 15
  --      AND msp.MtStatementProcess_IsDeleted = 0
  --  --  AND msp.MtStatementProcess_ApprovalStatus = 'Approved'
  --      AND LuAccountingMonth_Id_Current = (SELECT
  --              msp.LuAccountingMonth_Id_Current
  --          FROM MtStatementProcess msp
  --          WHERE msp.MtStatementProcess_ID = @pStatementProcessId
  --          AND msp.MtStatementProcess_IsDeleted = 0)
	/*==========================================================================================
	Step 3  Revised  receivable/payable
	==========================================================================================*/
	DECLARE @vCapacityPrice DECIMAL(38, 13)
	SELECT
		@vCapacityPrice = BMCVariablesData_CapacityPrice
	FROM BMCVariablesData
	WHERE MtStatementProcess_ID = @vBMCFinalStatementId


	UPDATE RMP
	SET RMP.BMCPYSSMPData_AmountReceivableRevised = RMP.BMCPYSSMPData_CapacitySoldRevised * @vCapacityPrice
	   ,RMP.BMCPYSSMPData_AmountPayableRevised = RMP.BMCPYSSMPData_CapacityPurchasedRevised * @vCapacityPrice

	FROM BMCPYSSMPData RMP
	WHERE RMP.MtStatementProcess_ID = @pStatementProcessId


/*==========================================================================================
==========================================================================================*/
END
