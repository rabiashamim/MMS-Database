/****** Object:  Procedure [dbo].[FCD_GetProcessLogs]    Committed by VersionSQL https://www.versionsql.com ******/

  
-- =============================================        
-- Author:  ALINA JAVED        
-- Create date: <Create Date,,>        
-- Description: <Description,,>        
-- ============================================= 
--dbo.FCD_GetProcessLogs   7  
CREATE     PROCEDURE dbo.FCD_GetProcessLogs        
@pMtFCDMaster decimal(18,0)   =0  ,  
  @pSrFCDProcessDef_Id int  
AS        
BEGIN        
SELECT
  FCDLog_ID,
  MtFCDMaster_Id,
  FCDProcessLog_Message,
  FCDProcessLog_CreatedOn,
  FCDProcessLog_CreatedBy,
  MtFCDProcessLog_ErrorLevel
FROM (
  SELECT
    [MtFCDProcessLog_ID] AS FCDLog_ID,
    [MtFCDMaster_Id] AS MtFCDMaster_Id,
    [MtFCDProcessLog_Message] AS FCDProcessLog_Message,
    [MtFCDProcessLog_CreatedOn] AS FCDProcessLog_CreatedOn,
    [MtFCDProcessLog_CreatedBy] AS FCDProcessLog_CreatedBy,
    [MtFCDProcessLog_ErrorLevel],
    ROW_NUMBER() OVER (PARTITION BY [MtFCDProcessLog_Message] ORDER BY [MtFCDProcessLog_CreatedOn] ASC) AS RowNumber
  FROM [dbo].[MtFCDProcessLog]
  WHERE
    MtFCDMaster_Id = @pMtFCDMaster
    AND SrFCDProcessDef_Id = @pSrFCDProcessDef_Id
) AS SubQuery
WHERE RowNumber = 1
ORDER BY FCDProcessLog_CreatedOn; 
     END  
  
  
