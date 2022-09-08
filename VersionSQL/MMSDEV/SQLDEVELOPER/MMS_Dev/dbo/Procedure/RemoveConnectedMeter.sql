/****** Object:  Procedure [dbo].[RemoveConnectedMeter]    Committed by VersionSQL https://www.versionsql.com ******/

  
CREATE PROCEDURE [dbo].[RemoveConnectedMeter]  
@vConnectedMeterId decimal(18,0)  
AS  
  
BEGIN  
  
  
  
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
 Update   
  MtCDPDetail  
 Set   
  IsAssigned =0   
 Where   
  MtCDPDetail_Id = (Select MtCDPDetail_Id from   [dbo].[MtConnectedMeter] WHERE MtConnectedMeter_Id =@vConnectedMeterId)  
  
 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
  
   UPDATE 
		 [dbo].[MtConnectedMeter] 
   set 
		 MtConnectedMeter_isDeleted=1 
   WHERE  
	    MtConnectedMeter_Id=@vConnectedMeterId  

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
END  
  
  
