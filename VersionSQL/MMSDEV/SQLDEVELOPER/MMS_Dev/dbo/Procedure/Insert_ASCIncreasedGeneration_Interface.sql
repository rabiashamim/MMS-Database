/****** Object:  Procedure [dbo].[Insert_ASCIncreasedGeneration_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            
            
            
--/****** Object:  UserDefinedTableType [dbo].[MtAvailabilityData_UDT_Interface]    Script Date: 07/13/2022 10:48:48 am ******/          
--CREATE TYPE [dbo].[MtAscIG_UDT_Interface] AS TABLE(          
-- [MtAscIG_Date] [nvarchar](max) NULL,          
-- [MtAscIG_Hour] [nvarchar](max) NULL,          
-- [MtGenerationUnit_Id] [nvarchar](max) NULL,          
-- [MtAscIG_VariableCost] [nvarchar](max) NULL,          
-- [EnergyProduceIfNoAncillaryServices] [nvarchar](max) NULL,          
-- [Reason] varchar(max) null,          
-- [MtAscIG_IsValid] [bit] NULL,          
-- [MtAscIG_Message] [nvarchar](max) NULL          
--)          
            
            
  --MtAscIG          
CREATE PROCEDURE [dbo].[Insert_ASCIncreasedGeneration_Interface]            
 @fileMasterId decimal(18,0),            
 @UserId Int,         
 @SettlementMonth varchar(16),        
 @tblAscIG [dbo].[MtAscIG_UDT_Interface] READONLY            
             
AS            
BEGIN            
    
  INSERT INTO [dbo].MtAscIG_Interface          
 (            
  MtSOFileMaster_Id          
 ,MtGenerationUnit_Id          
 ,MtAscIG_Date          
 ,MtAscIG_Hour          
 ,MtAscIG_VariableCost          
 ,MtAscIG_CreatedBy          
 ,MtAscIG_CreatedOn          
 ,MtAscIG_IsDeleted          
 ,EnergyProduceIfNoAncillaryServices          
 ,Reason          
 ,MtAscIG_IsValid          
 ,MtAscIG_RowNumber          
 )          
               
    SELECT           
  @fileMasterId          
 ,MtGenerationUnit_Id           
 ,MtAscIG_Date            
 ,MtAscIG_Hour           
 ,MtAscIG_VariableCost               
 ,@UserId            
 ,GETUTCDATE()            
 ,0          
 ,EnergyProduceIfNoAncillaryServices          
 ,Reason          
 ,1          
 ,ROW_NUMBER() OVER(order by MtAscIG_Date) AS num_row            
 FROM @tblAscIG            
            
    
 exec [dbo].[ASCIncreasedGenerationValidation] @fileMasterId,@UserId  ,@SettlementMonth          
            
            
END 
