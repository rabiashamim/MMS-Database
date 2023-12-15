/****** Object:  Procedure [dbo].[GetReferenceValues]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE  PROCEDURE dbo.GetReferenceValues                   
   @pRuReferenceValue_Id int=0        
AS                               
BEGIN                
SET NOCOUNT ON;                
BEGIN TRY                
select               
 RuReferenceValue_Id               
 ,val.SrReferenceType_Id               
 ,typ.SrReferenceType_Name            
 ,typ.SrReferenceType_Unit          
 ,RuReferenceValue_Value          
 ,CAST(CAST(RuReferenceValue_Value as  DECIMAL(24,2))as NVARCHAR(255))  + ' ' +  CAST(typ.SrReferenceType_Unit as NVARCHAR(255)) as ReferenceValueUnit          
 ,RuReferenceValue_EffectiveFrom              
 ,RuReferenceValue_EffectiveTo               
 ,RuReferenceValue_CreatedOn               
 ,RuReferenceValue_ModifiedOn               
 from RuReferenceValue   val            
 inner join SrReferenceType typ on typ.SrReferenceType_Id=val.SrReferenceType_Id            
            
 where( @pRuReferenceValue_Id = 0 or RuReferenceValue_Id=@pRuReferenceValue_Id )              
 AND val.RuReferenceValue_IsDeleted <>1        
 ORDER by  RuReferenceValue_CreatedOn DESC  
END TRY                
BEGIN CATCH                
SELECT                
 ERROR_NUMBER() AS ErrorNumber                
   ,ERROR_STATE() AS ErrorState                
   ,ERROR_SEVERITY() AS ErrorSeverity                
   ,ERROR_PROCEDURE() AS ErrorProcedure                
   ,ERROR_LINE() AS ErrorLine                
   ,ERROR_MESSAGE() AS ErrorMessage;                
END CATCH;                
                
                
END    
/*************************************************************/ 
