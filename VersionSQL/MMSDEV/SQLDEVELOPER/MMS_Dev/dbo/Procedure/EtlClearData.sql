/****** Object:  Procedure [dbo].[EtlClearData]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================    
-- Author: AMMAMA GIll    
-- CREATE date: 16 Jan 2023    
-- ALTER date:        
-- Description:                   
--==========================================================================================    
CREATE    PROCEDURE dbo.EtlClearData @pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

DELETE FROM MtStatementProcessSteps
WHERE MtStatementProcess_ID = @pStatementProcessId;
DELETE FROM EtlHourly
WHERE MtStatementProcess_ID = @pStatementProcessId;
DELETE FROM EtlMpData
WHERE MtStatementProcess_ID = @pStatementProcessId;
DELETE FROM EtlTspData
WHERE MtStatementProcess_ID = @pStatementProcessId;
DELETE FROM EtlTspHourly
WHERE MtStatementProcess_ID = @pStatementProcessId
DELETE FROM EtlMpMonthlyData
WHERE MtStatementProcess_ID = @pStatementProcessId;
DELETE FROM [dbo].[EtlEyssAdjustmentData]
WHERE MtStatementProcess_ID = @pStatementProcessId;
END
