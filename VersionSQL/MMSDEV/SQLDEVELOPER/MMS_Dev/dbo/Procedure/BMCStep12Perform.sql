/****** Object:  Procedure [dbo].[BMCStep12Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran| AMMAMA Gill
-- CREATE date: 28 Dec 2022
-- ALTER date:   09-01-2023 
-- Description: We need to divide Capacity sold/purchased by 1000 here because all calculations in MMS are performed in kWs and we need to multiply Capacity value in MW with the Capacity price to get the correct output. (Ammama)              
--==========================================================================================
CREATE   PROCEDURE dbo.BMCStep12Perform @pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

/*==========================================================================================
Step 12. Calculate Payable and Receivable 
==========================================================================================*/

UPDATE b 
SET 
b.BMCMPData_AmountReceivable=(CAST(b.BMCMPData_CapacitySold AS DECIMAL(25,13)) *cast(bd.BMCVariablesData_CapacityPrice AS DECIMAL(20,10)))
,b.BMCMPData_AmountPayable=CAST(b.BMCMPData_CapacityPurchased AS DECIMAL(25,13))  * CAST(bd.BMCVariablesData_CapacityPrice AS DECIMAL(20,10))

FROM BMCMPData b
JOIN BMCVariablesData bd
    ON b.MtStatementProcess_ID = bd.MtStatementProcess_ID
WHERE b.MtStatementProcess_ID=@pStatementProcessId



END
