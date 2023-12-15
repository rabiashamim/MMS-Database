/****** Object:  Procedure [dbo].[Insert_DistributionLoss]    Committed by VersionSQL https://www.versionsql.com ******/

  
  
CREATE PROCEDURE dbo.Insert_DistributionLoss  
 @entityID decimal(18,0),  
 @lineVoltage int,  
 @distLossesFactor decimal(18,4),  
    @distLossesEffectiveFrom datetime,  
 @distLossesEffectiveTo datetime,  
 @mtRegistrationId decimal(18,0)  
   
AS  
BEGIN  
    SET NOCOUNT ON;  
 declare @vdistLossesID Decimal(18,0);  
   
 declare @mpRegName varchar(100);  
  
 SELECT @vdistLossesID=(ISNUll(MAX(Lu_DistLosses_Id),0))+1 FROM Lu_DistLosses   
  
 SELECT @mpRegName=MtPartyRegisteration_Name from MtPartyRegisteration where MtPartyRegisteration_Id=@entityID  
  
  INSERT INTO [dbo].[Lu_DistLosses]  
           (  
     Lu_DistLosses_Id  
           ,Lu_DistLosses_MP_Id  
           ,Lu_DistLosses_MP_Name  
           ,Lu_DistLosses_LineVoltage  
           ,Lu_DistLosses_Factor  
           ,Lu_DistLosses_EffectiveFrom  
           ,Lu_DistLosses_EffectiveTo  
     ,Lu_DistLosses_CreatedDate  
     ,Lu_DistLosses_UpdatedDate  
           ,MtPartyRegisteration_Id)  
     
    values (   
    @vdistLossesID   
    ,@entityID  
    ,@mpRegName   
    ,@lineVoltage  
    ,@distLossesFactor  
    ,@distLossesEffectiveFrom  
    ,@distLossesEffectiveTo  
    ,GETUTCDATE()  
    ,NULL  
    ,@mtRegistrationId  
    )  
  
  
END  
