/****** Object:  Procedure [dbo].[Insert_ASCReducedGeneration_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

--/****** Object:  UserDefinedTableType [dbo].[MtAscIG_UDT_Interface]    Script Date: 7/15/2022 2:34:38 PM ******/
--CREATE TYPE [dbo].[MtAscRG_UDT_Interface] AS TABLE(
--	MtAscRG_Date [nvarchar](max) NULL,
--	MtAscRG_Hour [nvarchar](max) NULL,
--	MtGenerationUnit_Id [nvarchar](max) NULL,
--	MtAscRG_VariableCost [nvarchar](max) NULL,
--	MtAscRG_ExpectedEnergy [nvarchar](max) NULL,
--	GenerationUnitTypeARE [varchar](max) NULL,
--	[MtAscRG_IsValid] [bit] NULL,
--	[MtAscRG_Message] [nvarchar](max) NULL
--)
--GO


      
      
      
  --MtAscIG    
CREATE PROCEDURE [dbo].[Insert_ASCReducedGeneration_Interface]      
 @fileMasterId decimal(18,0),      
 @UserId Int,   
 @SettlementMonth varchar(16),  
 @tblAscRG [dbo].[MtAscRG_UDT_Interface] READONLY      
       
AS      
BEGIN      
          
    
  INSERT INTO [dbo].MtAscRG_Interface    
 (      
  MtSOFileMaster_Id    
 ,MtGenerationUnit_Id    
 ,MtAscRG_Date    
 ,MtAscRG_Hour   
 ,MtAscRG_CreatedBy    
 ,MtAscRG_CreatedOn    
 ,MtAscRG_IsDeleted    
 ,MtAscRG_ExpectedEnergy
 ,MtAscRG_VariableCost 
 ,GenerationUnitTypeARE    
 ,MtAscRG_IsValid    
 ,MtAscRG_RowNumber    
 )    
         
    SELECT     
  @fileMasterId    
 ,MtGenerationUnit_Id    
 ,MtAscRG_Date    
 ,MtAscRG_Hour   
 ,@UserId    
 ,GETUTCDATE()     
 ,0    
 ,MtAscRG_ExpectedEnergy
 ,MtAscRG_VariableCost 
 ,GenerationUnitTypeARE    
 ,1     
 ,ROW_NUMBER() OVER(order by MtAscRG_Date) AS num_row      
 FROM @tblAscRG      
      
      
 exec [dbo].[ASCReducedGenerationValidation] @fileMasterId,@UserId  ,@SettlementMonth    
      
      
END 
