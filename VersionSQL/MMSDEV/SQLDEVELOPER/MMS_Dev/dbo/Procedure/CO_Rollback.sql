/****** Object:  Procedure [dbo].[CO_Rollback]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================              
-- Author: Ali Imran| Sadaf Malik
-- CREATE date: 01/06/2023              
-- ALTER date:  
-- Description:                             
--==========================================================================================              
-- [CO_Rollback] 363
CREATE PROCEDURE dbo.CO_Rollback (@StatementProcessId DECIMAL(18, 0), @pUserId DECIMAL(18, 0) = NULL)
AS
BEGIN
	DELETE FROM MtStatementProcessSteps
	WHERE MtStatementProcess_ID = @StatementProcessId
	DELETE FROM COCGenWise
	WHERE StatementProcessId = @StatementProcessId
	DELETE FROM COCMPWise
	WHERE StatementProcessId = @StatementProcessId



END
