/****** Object:  Procedure [dbo].[ContractReg_InsertContractProfileEnergy]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
-- =============================================            
-- Author:  Ali Imran          
-- CREATE date: Nov 15, 2022           
-- ALTER date:           
-- Reviewer:          
-- Description:           
-- =============================================           
        
CREATE PROCEDURE dbo.ContractReg_InsertContractProfileEnergy        
    @pContractProfileEnergy_Id DECIMAL(18, 0),        
    @pContractRegisteration_Id DECIMAL(18, 0),        
    @pDateFrom DATE,        
    @pDateTo DATE,        
    @pPercentage decimal(18, 2)=null,        
    @pContractQuantity decimal(18, 2)=null,        
    @pCapQuantity decimal(18, 2)=null,        
    @pHourFrom INT,        
    @pHourTo INT,        
    @pUserId DECIMAL(18, 0)        
AS        
BEGIN        
        
    SET NOCOUNT ON;        
    BEGIN TRY        
        
        -------------------------------------------------------------------          
        -- Validations start          
        -------------------------------------------------------------------          
        BEGIN        
        
            DROP TABLE IF EXISTS #validations        
            DROP TABLE IF EXISTS #validations1        
        
            SELECT *        
            INTO #validations        
            FROM MtContractRegistration        
            WHERE MtContractRegistration_Id = @pContractRegisteration_Id        
                  AND (        
                          MtContractRegistration_EffectiveFrom > @pDateFrom        
                          OR MtContractRegistration_EffectiveFrom > @pDateTo        
                          OR MtContractRegistration_EffectiveTo < @pDateFrom        
                          OR MtContractRegistration_EffectiveTo < @pDateTo        
                      )        
        
            IF EXISTS (SELECT 1 FROM #validations)        
            BEGIN        
                RAISERROR('From and To date must be between the Effective from and to date.', 16, -1)        
    return;    
            END        
        
            SELECT *        
            INTO #validations1        
            FROM MtContractProfileEnergy        
            WHERE MtContractRegistration_Id = @pContractRegisteration_Id        
                  AND MtContractProfileEnergy_Id <> @pContractProfileEnergy_Id        
                  AND (        
                          (        
                              MtContractProfileEnergy_DateFrom <= @pDateFrom        
                              OR MtContractProfileEnergy_DateFrom <= @pDateTo        
                          )        
                          AND (        
                                  MtContractProfileEnergy_DateTo >= @pDateFrom        
                                  OR MtContractProfileEnergy_DateTo >= @pDateTo        
                              )        
                      )        
                  AND MtContractProfileEnergy_IsDeleted = 0        
                  AND (        
                          (        
                              MtContractProfileEnergy_HourFrom <= @pHourFrom        
                              OR MtContractProfileEnergy_HourFrom <= @pHourTo        
                          )        
                          AND (        
                                  MtContractProfileEnergy_HourTo >= @pHourFrom        
                                  OR MtContractProfileEnergy_HourTo >= @pHourTo        
                              )        
                      )        
        
            IF EXISTS (SELECT 1 FROM #validations1)        
            BEGIN        
                RAISERROR('Overlapping Hours.', 16, -1)        
    return;    
   END        
   IF NOT EXISTS(SELECT 1 FROM MtContractRegistration     WHERE MtContractRegistration_Id = @pContractRegisteration_Id   AND  SrContractType_Id IN (3,4))    
   BEGIN    
       IF @pPercentage IS  NULL    
    BEGIN    
      RAISERROR('Percentage should not be null.', 16, -1)     
      return;    
    END 
	ELSE
	BEGIN
		IF @pPercentage <0 OR @pPercentage>100
		BEGIN
		    RAISERROR('Percentage must be between 0-100.', 16, -1)   
		END
	END
   END    
    
	
     IF  EXISTS(SELECT 1 FROM MtContractRegistration     WHERE MtContractRegistration_Id = @pContractRegisteration_Id   AND  SrContractType_Id IN (3))  
   BEGIN  
       IF @pContractQuantity IS  NULL  
    BEGIN  
      RAISERROR('Contracted Quantity should not be null.', 16, -1)      
      Return;  
   END  
   END  


   IF  EXISTS(SELECT 1 FROM MtContractRegistration     WHERE MtContractRegistration_Id = @pContractRegisteration_Id   AND  SrContractType_Id=4)    
   BEGIN    
       IF @pPercentage IS NOT NULL AND @pContractQuantity is not NULL    
    BEGIN    
      RAISERROR('Either Percentage value or Contracted Quantity is must. Both columns cannot have values.', 16, -1)        
    return;    
    END    
       ELSE IF @pPercentage IS  NULL AND @pContractQuantity is  NULL    
    BEGIN    
      RAISERROR('Either Percentage value or Contracted Quantity should be provided.', 16, -1)        
      return;    
   END    
   END    
   -------------------------------------------------------------------      
    
/*    
declare @MeterOwnerCategory_id decimal(18,0),@installed_capacity decimal(18,4)      
      
select @MeterOwnerCategory_id= CASE when MtContractRegistration_MeterOwner='Buyer' then MtContractRegistration_BuyerCategoryId      
         when MtContractRegistration_MeterOwner='Seller' then MtContractRegistration_SellerCategoryId      
                               END      
from MtContractRegistration where MtContractRegistration_Id=@pContractRegisteration_Id         
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
  */      
        
  END        
        
        
        
        -------------------------------------------------------------------          
        -- Validations End          
        -------------------------------------------------------------------          
        
        
        
        IF @pContractProfileEnergy_Id = 0        
        BEGIN        
            INSERT INTO [dbo].[MtContractProfileEnergy]        
            (        
                [MtContractRegistration_Id],        
                [MtContractProfileEnergy_DateFrom],        
                [MtContractProfileEnergy_DateTo],        
                [MtContractProfileEnergy_Percentage],        
                [MtContractProfileEnergy_ContractQuantity_KWH],        
                [MtContractProfileEnergy_CapQuantity_KWH],        
                [MtContractProfileEnergy_HourFrom],        
                [MtContractProfileEnergy_HourTo],        
                [MtContractProfileEnergy_CreatedBy],        
                [MtContractProfileEnergy_CreatedOn],        
                [MtContractProfileEnergy_IsDeleted]        
            )        
            VALUES        
            (@pContractRegisteration_Id,        
             @pDateFrom,        
             @pDateTo,        
             @pPercentage,        
             @pContractQuantity,        
             @pCapQuantity,        
             @pHourFrom,        
             @pHourTo,        
             @pUserId,        
             GETUTCDATE(),        
             0        
            )        
             
    set @pContractProfileEnergy_Id=@@identity
	
			declare @output VARCHAR(max);
			SET @output='Contract Profile (Energy) Created. Contract ID: ' + convert(varchar(max),@pContractRegisteration_Id) + ', Profile Record ID:' + convert(varchar(max),@pContractProfileEnergy_Id)
				EXEC [dbo].[SystemLogs] 
				@user=@pUserId,
				 @moduleName='Contract Registration',  
				 @CrudOperationName='Create',  
				 @logMessage=@output 

        END        
        ELSE        
        BEGIN        
        
            UPDATE [dbo].[MtContractProfileEnergy]        
            SET [MtContractProfileEnergy_DateFrom] = @pDateFrom,        
                [MtContractProfileEnergy_DateTo] = @pDateTo,        
                [MtContractProfileEnergy_Percentage] = @pPercentage,        
                [MtContractProfileEnergy_ContractQuantity_KWH] = @pContractQuantity,        
                [MtContractProfileEnergy_CapQuantity_KWH] = @pCapQuantity,        
                [MtContractProfileEnergy_HourFrom] = @pHourFrom,        
                [MtContractProfileEnergy_HourTo] = @pHourTo,        
          [MtContractProfileEnergy_ModifiedBy] = @pUserId,        
                [MtContractProfileEnergy_ModifiedOn] = GETUTCDATE()        
            WHERE MtContractProfileEnergy_Id = @pContractProfileEnergy_Id   
			
			declare @output1 VARCHAR(max);
			SET @output1='Contract Profile (Energy) Updated. Contract ID: ' + convert(varchar(max),@pContractRegisteration_Id) + ', Profile Record ID: ' + convert(varchar(max),@pContractProfileEnergy_Id)

				EXEC [dbo].[SystemLogs] 
				@user=@pUserId,
				 @moduleName='Contract Registration',  
				 @CrudOperationName='Update',  
				 @logMessage=@output1 
        
        END        
        
        
        
    END TRY        
    BEGIN CATCH        
        SELECT ERROR_NUMBER() AS ErrorNumber,        
               ERROR_STATE() AS ErrorState,        
               ERROR_SEVERITY() AS ErrorSeverity,        
               ERROR_PROCEDURE() AS ErrorProcedure,        
               ERROR_LINE() AS ErrorLine,        
               ERROR_MESSAGE() AS ErrorMessage;        
    END CATCH;        
        
END      
