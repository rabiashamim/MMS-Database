/****** Object:  Procedure [dbo].[UpdateCDPInfo]    Committed by VersionSQL https://www.versionsql.com ******/

    
--[dbo].[UpdateCDPInfo]  @vCdpId=1060, @veffectiveDateFromIPP='20-Apr-22 12:00:00 AM', @veffectiveDateToIPP='23-Apr-22 12:00:00 AM',@vconnectedFromCatId=130,     
CREATE PROCEDURE [dbo].[UpdateCDPInfo]      
      
     
 @vCdpId VARCHAR(100),     
 @vchangeflag int,      
 @vconnectedFromCatId int=null,              
 @vconnectedToCatId int=null,              
 @vconnectedFromPartyId int = null,     
 @vconnectedToPartyId int = null,     
 @vconnectedFromCategoryCode varchar(4) = null,     
 @vconnectedToCategoryCode varchar(4) = null,     
 @veffectiveDateFromIPP DateTime=null,              
 @veffectiveDateToIPP DateTime = null,      
 @vcongestedZoneID int = null,      
 @vtaxZoneId int = null,    
 @vUserId int,    
 @vMtConnectedMeter_Id int = null, 
 @visBackfeedInclude bit = 0
    
    
as      
begin      
      
      
      
       
 IF (@vchangeflag = 1)      
 -- History Insertion --      
 BEGIN      
  INSERT INTO RuCDPDetail_History ( RuCDPDetail_CdpId, RuCDPDetail_CdpName, RuCDPDetail_ConnectedFromID, RuCDPDetail_ConnectedToID, RuCDPDetail_EffectiveFromIPP, RuCDPDetail_EffectiveToIPP, RuCDPDetail_TaxZoneID, RuCDPDetail_CongestedZoneID, IsBackfeedInclude)      
  SELECT RuCDPDetail_CdpId, RuCDPDetail_CdpName, RuCDPDetail_ConnectedFromID, RuCDPDetail_ConnectedToID, RuCDPDetail_EffectiveFromIPP, RuCDPDetail_EffectiveToIPP, RuCDPDetail_TaxZoneID, RuCDPDetail_CongestedZoneID, IsBackfeedInclude FROM RuCDPDetail WHERE RuCDPDetail_CdpId 
  
= @vCdpId;      
 END      
      
  select @vconnectedFromPartyId = (select MtPartyRegisteration_Id from MtPartyCategory  WHERE MtPartyCategory_Id= @vconnectedFromCatId and isnull(isDeleted,0)=0)--DELETE CHECK MISS    
  select @vconnectedToPartyId = (select MtPartyRegisteration_Id from MtPartyCategory  WHERE MtPartyCategory_Id= @vconnectedToCatId and isnull(isDeleted,0)=0)--DELETE CHECK MISS    
    
   select @vconnectedFromCategoryCode = (select SrCategory_Code from MtPartyCategory  WHERE MtPartyCategory_Id= @vconnectedFromCatId and isnull(isDeleted,0)=0)    
    
   select @vconnectedToCategoryCode = (select SrCategory_Code from MtPartyCategory  WHERE MtPartyCategory_Id= @vconnectedToCatId and isnull(isDeleted,0)=0)    
    
  DECLARE @vRuCDPDetail_Id DECIMAL(18,0)  
  SELECT @vRuCDPDetail_Id=RuCDPDetail_Id  FROM [dbo].[RuCDPDetail]    WHERE   RuCDPDetail_CdpId = @vCdpId;    
  
 -- New Updated Values --      
 update [dbo].[RuCDPDetail]      
 set    
-- RuCDPDetail_ConnectedFromID = @vconnectedFromCatId,       
 -- RuCDPDetail_ConnectedToID = @vconnectedToCatId,      
  RuCDPDetail_ConnectedFromID = @vconnectedFromPartyId,       
  RuCDPDetail_ConnectedToID = @vconnectedToPartyId,      
--  RuCDPDetail_FromCustomerCategory = @vconnectedFromCatId,    
 -- RuCDPDetail_ToCustomerCategory = @vconnectedToCatId,    
  RuCDPDetail_ConnectedFromCategoryID=@vconnectedFromCatId,    
  RuCDPDetail_ConnectedToCategoryID=@vconnectedToCatId,    
  RuCDPDetail_FromCustomerCategory=@vconnectedFromCategoryCode,    
  RuCDPDetail_ToCustomerCategory=@vconnectedToCategoryCode,    
  RuCDPDetail_EffectiveFromIPP = @veffectiveDateFromIPP,       
  RuCDPDetail_EffectiveToIPP = @veffectiveDateToIPP,      
  RuCDPDetail_TaxZoneID = @vtaxZoneId,      
  RuCDPDetail_CongestedZoneID = @vcongestedZoneID,
  isBackfeedInclude = @visBackfeedInclude
 where       
  RuCDPDetail_CdpId = @vCdpId;    
  --DELETE CHECK MISS    
  /**    
      
  **/    
    
    
 DECLARE @pMtConnectedMeter_Id0 decimal(18,0);    
 DECLARE @pMtConnectedMeter_Id1 decimal(18,0);    
 IF @vconnectedFromPartyId <> @vconnectedToPartyId    
 BEGIN    
  
  
 /*********************************************************************************************************************  
CDP Assign From Party   
 *********************************************************************************************************************/   
  -- New entry into MtConnectedMeter for cdp points in registration connectedfrompartyid    
    
  if not exists(select 1 from MtConnectedMeter where MtCDPDetail_Id=@vRuCDPDetail_Id and MtPartyCategory_Id=@vconnectedFromCatId and isnull(MtConnectedMeter_isDeleted,0)=0)--DELETE CHECK MISS    
  BEGIN    
          
   --update MtConnectedMeter set MtConnectedMeter_isDeleted = 1 where  MtCDPDetail_Id=@vCdpId --DELETE CHECK MISS    
    
       
   SELECT @pMtConnectedMeter_Id1 = ISNULL(max(MtConnectedMeter_Id),0)+1 FROM [dbo].[MtConnectedMeter]    
    
   INSERT INTO [dbo].[MtConnectedMeter]    
   (MtConnectedMeter_Id    
   ,MtPartyCategory_Id    
   ,MtCDPDetail_Id    
   ,IsAssigned    
   ,MtConnectedMeter_CreatedBy    
   ,MtConnectedMeter_CreatedOn)    
   VALUES    
   (@pMtConnectedMeter_Id1    
   ,@vconnectedFromCatId    
   ,@vRuCDPDetail_Id    
   ,1    
   ,@vUserId    
   ,GETUTCDATE());    
    
  END    
 /*********************************************************************************************************************  
CDP Assign To Party   
 *********************************************************************************************************************/  
  if not exists(select 1 from MtConnectedMeter where MtCDPDetail_Id=@vRuCDPDetail_Id and MtPartyCategory_Id=@vconnectedToCatId and isnull(MtConnectedMeter_isDeleted,0)=0 )--DELETE CHECK MISS    
  BEGIN    
          
   --update MtConnectedMeter set MtConnectedMeter_isDeleted = 1 where  MtCDPDetail_Id=@vCdpId --DELETE CHECK MISS    
   SELECT @pMtConnectedMeter_Id0 = ISNULL(max(MtConnectedMeter_Id),0)+1 FROM [dbo].[MtConnectedMeter] --DELETE CHECK MISS    
    
   INSERT INTO [dbo].[MtConnectedMeter]    
   (MtConnectedMeter_Id    
   ,MtPartyCategory_Id    
   ,MtCDPDetail_Id    
   ,IsAssigned    
   ,MtConnectedMeter_CreatedBy    
   ,MtConnectedMeter_CreatedOn)    
   VALUES    
   (@pMtConnectedMeter_Id0    
   ,@vconnectedToCatId    
   ,@vRuCDPDetail_Id    
   ,1    
   ,@vUserId    
   ,GETUTCDATE());    
    
  END    
    
 END    
    
END    
