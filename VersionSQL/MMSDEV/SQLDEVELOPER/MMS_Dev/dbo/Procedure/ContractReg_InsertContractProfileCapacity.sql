/****** Object:  Procedure [dbo].[ContractReg_InsertContractProfileCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
-- =============================================      
-- Author:  Ali Imran    
-- CREATE date: Nov 15, 2022     
-- ALTER date:     
-- Reviewer:    
-- Description:     
-- =============================================     
CREATE   PROCEDURE dbo.ContractReg_InsertContractProfileCapacity    
--DECLARE     
            @pContractRegistration_Id  DECIMAL(18,0)    
           ,@pContractProfileCapacity_Id DECIMAL(18,0)    
           ,@pDateFrom      DATE    
           ,@pDateTo      DATE    
           ,@pPercentage     DECIMAL(18,2)  =null  
           ,@pContractQuantity    DECIMAL(18,2)=null    
           ,@pCapQuantity     DECIMAL(18,2)=null    
           ,@pIsGuranted     BIT    
           ,@pUserId      DECIMAL(18,0)    
AS               
BEGIN         
    
-------------------------------------------------------------------    
-- Validations start    
-------------------------------------------------------------------    
    
BEGIN    
    
 DROP TABLE IF EXISTS #validations    
 DROP TABLE IF EXISTS #validation2   
 DROP TABLE IF EXISTS #validation3  
    
 SELECT *      
 INTO     
  #validations    
 FROM     
  MtContractRegistration     
 WHERE     
  MtContractRegistration_Id=@pContractRegistration_Id    
 AND (    
   MtContractRegistration_EffectiveFrom >  @pDateFrom    
  OR     
   MtContractRegistration_EffectiveFrom > @pDateTo    
  OR     
   MtContractRegistration_EffectiveTo < @pDateFrom    
  OR     
   MtContractRegistration_EffectiveTo <  @pDateTo    
  )    
    
 IF EXISTS(SELECT 1 FROM #validations)    
 BEGIN    
  RAISERROR('From and To date must be between the Effective from and to date.', 16, -1)    
  RETURN;    
 END    
-----------------------------------------    
 SELECT *     
 INTO     
  #validation2    
 FROM     
  MtContractProfileCapacity    
 WHERE     
  MtContractRegistration_Id=@pContractRegistration_Id    
 AND (    
   (    
     MtContractProfileCapacity_DateFrom <= @pDateFrom    
    OR     
     MtContractProfileCapacity_DateFrom <= @pDateTo    
   )    
  AND (     
     MtContractProfileCapacity_DateTo >= @pDateFrom    
    OR     
     MtContractProfileCapacity_DateTo >= @pDateTo    
   )    
  )    
 AND     
  MtContractProfileCapacity_IsDeleted=0    
 AND     
  MtContractProfileCapacity_Id <> @pContractProfileCapacity_Id    
    
 IF EXISTS(SELECT 1 FROM #validation2)    
 BEGIN    
  RAISERROR('Overlapping Dates', 16, -1)    
  RETURN;    
 END    
     IF NOT EXISTS(SELECT 1 FROM MtContractRegistration     WHERE MtContractRegistration_Id = @pContractRegistration_Id   AND  SrContractType_Id IN (3,4))  
   BEGIN  
       IF @pPercentage IS  NULL  
    BEGIN  
      RAISERROR('Percentage should not be null.', 16, -1)      
      Return;  
   END
   ELSE
   BEGIN
		IF @pPercentage <0 OR @pPercentage>100
		BEGIN
		    RAISERROR('Percentage must be between 0-100.', 16, -1)   
			RETURN;
		END
	END
   END  
  

     IF  EXISTS(SELECT 1 FROM MtContractRegistration     WHERE MtContractRegistration_Id = @pContractRegistration_Id   AND  SrContractType_Id IN (3))  
   BEGIN  
       IF @pContractQuantity IS  NULL  
    BEGIN  
      RAISERROR('Contracted Quantity should not be null.', 16, -1)      
      Return;  
   END  
   END  

    
   IF  EXISTS(SELECT 1 FROM MtContractRegistration     WHERE MtContractRegistration_Id = @pContractRegistration_Id   AND  SrContractType_Id=4)  
   BEGIN  
       IF @pPercentage IS NOT NULL AND @pContractQuantity is not null  
      BEGIN  
      RAISERROR('Either Percentage value or Contracted Quantity is must. Both columns cannot have values.', 16, -1)  
      RETURN;  
      END  
       ELSE IF @pPercentage IS  NULL AND @pContractQuantity is  NULL  
    BEGIN  
      RAISERROR('Either Percentage value or Contracted Quantity should be provided.', 16, -1)      
      return;  
   END  
   END  
  
END    
-------------------------------------------------------------------  
declare @MeterOwnerCategory_id decimal(18,0),@installed_capacity decimal(18,4)  
  
select @MeterOwnerCategory_id= CASE when MtContractRegistration_MeterOwner='Buyer' then MtContractRegistration_BuyerCategoryId  
               when MtContractRegistration_MeterOwner='Seller' then MtContractRegistration_SellerCategoryId  
                               END  
from MtContractRegistration where MtContractRegistration_Id=@pContractRegistration_Id     
and isnull(MtContractRegistration_IsDeleted,0)=0  
  
select @installed_capacity=sum(isnull(gu.MtGenerationUnit_InstalledCapacity_KW,0)) -- into #GenerationUnits_capacity   
from MtGenerator g inner join MtGenerationUnit GU on G.MtGenerator_Id=GU.MtGenerator_Id  
where MtPartyCategory_Id=@MeterOwnerCategory_id  
and isnull(g.MtGenerator_IsDisabled,0)=0  
and isnull(g.MtGenerator_IsDeleted,0)=0  
and isnull(GU.MtGenerationUnit_IsDisabled,0)=0  
and isnull(GU.MtGenerationUnit_IsDeleted,0)=0  
  
    
 IF isnull(@pContractQuantity,0)>@installed_capacity or isnull(@pCapQuantity,0)>@installed_capacity  
 BEGIN    
  RAISERROR('Cap or Contracted Quantity should not be greater than Installed Capacity', 16, -1)    
  RETURN;    
 END    
-------------------------------------------------------------------    
-- Validations end    
-------------------------------------------------------------------    
    
    
IF(@pContractProfileCapacity_Id=0)    
BEGIN    
INSERT INTO [dbo].[MtContractProfileCapacity]    
           ([MtContractRegistration_Id]    
           ,[MtContractProfileCapacity_DateFrom]    
           ,[MtContractProfileCapacity_DateTo]    
           ,[MtContractProfileCapacity_Percentage]    
           ,[MtContractProfileCapacity_ContractQuantity_MW]    
           ,[MtContractProfileCapacity_CapQuantity_MW]    
           ,[MtContractProfileCapacity_IsGuaranteed]    
           ,[MtContractProfileCapacity_CreatedBy]    
           ,[MtContractProfileCapacity_CreatedOn]    
     ,[MtContractProfileCapacity_IsDeleted])    
     VALUES    
           (@pContractRegistration_Id    
           ,@pDateFrom    
           ,@pDateTo    
           ,@pPercentage    
           ,@pContractQuantity    
           ,@pCapQuantity    
           ,@pIsGuranted    
           ,@pUserId    
           ,GETUTCDATE()    
     ,0    
           )
		   set @pContractProfileCapacity_Id=@@identity
		   
		   declare @output VARCHAR(max);
			SET @output='Contract Profile (Capacity) Created. Contract ID:' + convert(varchar(max),@pContractRegistration_Id) + ', Profile Record ID:' + convert(varchar(max),@pContractProfileCapacity_Id)

				EXEC [dbo].[SystemLogs] 
				@user=@pUserId,
				 @moduleName='Contract Registration',  
				 @CrudOperationName='Create',  
				 @logMessage=@output 
END    
ELSE    
BEGIN    
      
UPDATE [dbo].[MtContractProfileCapacity]    
   SET     
       [MtContractProfileCapacity_DateFrom] = @pDateFrom    
      ,[MtContractProfileCapacity_DateTo] = @pDateTo    
      ,[MtContractProfileCapacity_Percentage] = @pPercentage    
      ,[MtContractProfileCapacity_ContractQuantity_MW] = @pContractQuantity    
      ,[MtContractProfileCapacity_CapQuantity_MW] = @pCapQuantity    
      ,[MtContractProfileCapacity_IsGuaranteed] = @pIsGuranted    
      ,[MtContractProfileCapacity_ModifiedBy] = @pUserId    
      ,[MtContractProfileCapacity_ModifiedOn] = GETUTCDATE()    
          
 WHERE    
  MtContractProfileCapacity_Id=@pContractProfileCapacity_Id    
  declare @output1 VARCHAR(max);
			SET @output1='Contract Profile (Capacity) Updated. Contract ID:' + convert(varchar(max),@pContractRegistration_Id) + ', Profile Record ID:' + convert(varchar(max),@pContractProfileCapacity_Id)

				EXEC [dbo].[SystemLogs] 
				@user=@pUserId,
				 @moduleName='Contract Registration',  
				 @CrudOperationName='Update',  
				 @logMessage=@output1 

END    
    
END    
    
  
