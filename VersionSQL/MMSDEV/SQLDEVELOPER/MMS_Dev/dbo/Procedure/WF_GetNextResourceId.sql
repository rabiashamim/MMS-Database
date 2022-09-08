/****** Object:  Procedure [dbo].[WF_GetNextResourceId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date, ,>  
-- Description: <Description, ,>  
-- =============================================  
----   
  
CREATE PROCEDURE [dbo].[WF_GetNextResourceId]   
(  
@ruWorkFlowHeader_Id decimal(18,0) = NULL  
,@mtWFHistory_Process_id DECIMAL(18,0)  
,@FromUser_id DECIMAL(18,0) 
)  
  
AS  
BEGIN  
 DECLARE @MtWFHistory_SequenceID int 
  
set @MtWFHistory_SequenceID=
  (select max(MtWFHistory_SequenceID)MtWFHistory_SequenceID
  from MtWFHistory 
   WHERE MtWFHistory_FromResource = @FromUser_id   
  AND MtWFHistory_Process_id = @mtWFHistory_Process_id   
  AND RuWorkFlowHeader_id = @ruWorkFlowHeader_Id 
  )
  select mw.MtWFHistory_ToResource   
 FROM MtWFHistory mw   
 WHERE mw.MtWFHistory_FromResource = @FromUser_id   
  AND mw.MtWFHistory_Process_id = @mtWFHistory_Process_id   
  AND mw.RuWorkFlowHeader_id = @ruWorkFlowHeader_Id
  and mw.MtWFHistory_SequenceID=@MtWFHistory_SequenceID
  
END
