/****** Object:  Procedure [dbo].[SuspensionStatusChange]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE  dbo.SuspensionStatusChange        
@PartyRegisteration_Id DECIMAL(18,0),        
@statusChanges VARCHAR(30)        
AS        
BEGIN        
        
 Update MtPartyRegisteration         
 Set LuStatus_Code_Approval =CASE WHEN @statusChanges ='SAPP' THEN LuStatus_Code_Approval ELSE  @statusChanges   end     
 WHERE        
 MtPartyRegisteration_Id = @PartyRegisteration_Id        
     /*   
  if(@statusChanges='SAPP')      
  BEGIN      
      
 update       
  MtPartyRegisteration       
 set       
  LuStatus_Code_Applicant='ASUS'       
 WHERE        
  MtPartyRegisteration_Id = @PartyRegisteration_Id        
  END      
   
    if(@statusChanges='TERM')      
  BEGIN      
      
 update       
  MtPartyRegisteration       
 set       
  LuStatus_Code_Applicant='ATER'       
 WHERE        
  MtPartyRegisteration_Id = @PartyRegisteration_Id        
    
  exec UnassignPartyConnectedMeters @PartyRegisteration_Id    
    
  END      
       */  
      
 if(@statusChanges='AAPR')      
  BEGIN      
    update       
	MtPartyRegisteration       
	set       
	LuStatus_Code_Applicant='AACT'       
	WHERE        
	MtPartyRegisteration_Id = @PartyRegisteration_Id        
  END      
      
END      
      
