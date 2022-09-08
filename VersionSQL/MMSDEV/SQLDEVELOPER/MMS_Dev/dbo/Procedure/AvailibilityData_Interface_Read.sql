/****** Object:  Procedure [dbo].[AvailibilityData_Interface_Read]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
--exec AvailibilityData_Interface_Read 291,1,10        
CREATE PROCEDURE [dbo].[AvailibilityData_Interface_Read]         
      
  @pMtSOFileMaster_Id DECIMAL(18, 0)      
, @pPageNumber INT      
, @pPageSize INT   
, @pMtAvailibilityData_Hour NVARCHAR(MAX) = NULL
, @pMtAvailibilityData_Date NVARCHAR(MAX)=NULL
, @pMtGenerationUnit_Id NVARCHAR(MAX)=NULL
, @pMtAvailibilityData_AvailableCapacityASC NVARCHAR(MAX)=NULL
, @pMtAvailibilityData_ActualCapacity NVARCHAR(MAX)=NULL
,@pMtAvailibilityData_IsValid NVARCHAR(MAX) = NULL
,@pMtAvailibilityData_Message NVARCHAR(MAX) = NULL

,@pfilterOperator NVARCHAR(MAX) = NULL
AS        
BEGIN      

DROP TABLE IF EXISTS #temp_GenerationAvailability_Interface
DROP TABLE IF EXISTS #temp_GenerationAvailability
  Declare @vStatus varchar(3);      
  SELECT @vStatus=LuStatus_Code FROM MtSOFileMaster WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id      
        
  if(@vStatus='UPL')      
  BEGIN   
  
  --WITH cte_AvailabilityInterface
  --AS(
		SELECT         
 			ROW_NUMBER() OVER(order by MtAvailibilityData_IsValid,MtAvailibilityData_RowNumber ) AS MtAvailibilityData_RowNumber_new   
			,MtAvailibilityData_Id    
			,MtAvailibilityData_RowNumber    
			,MtSOFileMaster_Id    
			,MtGenerationUnit_Id    
			,case when isdate(MtAvailibilityData_Date)=1 then  convert(varchar, MtAvailibilityData_Date, 23)   else MtAvailibilityData_Date end MtAvailibilityData_Date      
			,MtAvailibilityData_Hour    
			,MtAvailibilityData_AvailableCapacityASC    
			,MtAvailibilityData_ActualCapacity    
			,MtAvailibilityData_IsValid    
			,MtAvailibilityData_Message    
			,MtAvailibilityData_CreatedBy    
			,MtAvailibilityData_CreatedOn    
			,MtAvailibilityData_ModifiedBy    
			,MtAvailibilityData_ModifiedOn    
			,MtAvailibilityData_IsDeleted    
    
		INTO #temp_GenerationAvailability_Interface

		FROM [MtAvailibilityData_Interface]        
		WHERE ISNULL(MtAvailibilityData_IsDeleted, 0) = 0        
		AND MtSOFileMaster_Id =@pMtSOFileMaster_Id 
		AND (@pMtAvailibilityData_Hour IS NULL OR MtAvailibilityData_Hour = @pMtAvailibilityData_Hour)
		AND (@pMtAvailibilityData_Date IS NULL OR CONVERT(VARCHAR(10), MtAvailibilityData_Date,101)=@pMtAvailibilityData_Date)
		AND (@pMtGenerationUnit_Id IS NULL OR MtGenerationUnit_Id = @pMtGenerationUnit_Id)
		AND (@pMtAvailibilityData_ActualCapacity IS NULL OR MtAvailibilityData_ActualCapacity = @pMtAvailibilityData_ActualCapacity)
		AND (@pMtAvailibilityData_AvailableCapacityASC IS NULL OR MtAvailibilityData_AvailableCapacityASC = @pMtAvailibilityData_AvailableCapacityASC)
		AND (@pMtAvailibilityData_IsValid IS NULL OR MtAvailibilityData_IsValid = @pMtAvailibilityData_IsValid)
		AND (@pMtAvailibilityData_Message IS NULL OR MtAvailibilityData_Message LIKE ('%'+@pMtAvailibilityData_Message+'%'))
		 


		SELECT * FROM #temp_GenerationAvailability_Interface tgai
		WHERE ([MtAvailibilityData_RowNumber_new] > ((@pPageNumber - 1) * @pPageSize)        
		AND [MtAvailibilityData_RowNumber_new] <= (@pPageNumber * @pPageSize)) 
		 ORDER BY MtAvailibilityData_RowNumber_new  

 
      
        
        
 SELECT COUNT(1) as FilteredRows FROM #temp_GenerationAvailability_Interface tgai WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and MtAvailibilityData_IsDeleted=0        
       
 END      
      
 else      
 BEGIN      
      
   --   WITH cte_Availability
	  --AS(
		 SELECT         
		   			ROW_NUMBER() OVER(order by MtAvailibilityData_Id ) AS MtAvailibilityData_RowNumber_new   
,*        INTO #temp_GenerationAvailability
		 FROM [MtAvailibilityData]        
		 WHERE ISNULL(MtAvailibilityData_IsDeleted, 0) = 0        
			 AND MtSOFileMaster_Id =@pMtSOFileMaster_Id   
			 AND (@pMtAvailibilityData_Hour IS NULL OR MtAvailibilityData_Hour = @pMtAvailibilityData_Hour)
			 AND (@pMtAvailibilityData_Date IS NULL OR CONVERT(VARCHAR(10), MtAvailibilityData_Date,101)=@pMtAvailibilityData_Date)
			 AND (@pMtGenerationUnit_Id IS NULL OR MtGenerationUnit_Id = @pMtGenerationUnit_Id)
			 AND (@pMtAvailibilityData_ActualCapacity IS NULL OR MtAvailibilityData_ActualCapacity = @pMtAvailibilityData_ActualCapacity)
			 AND (@pMtAvailibilityData_AvailableCapacityASC IS NULL OR MtAvailibilityData_AvailableCapacityASC = @pMtAvailibilityData_AvailableCapacityASC)
		--)

		
		SELECT * FROM #temp_GenerationAvailability
		WHERE ([MtAvailibilityData_RowNumber_new] > ((@pPageNumber - 1) * @pPageSize)        
		 AND [MtAvailibilityData_RowNumber_new] <= (@pPageNumber * @pPageSize))        
		 ORDER BY MtAvailibilityData_RowNumber_new        
      
      
 SELECT COUNT(1) as FilteredRows FROM #temp_GenerationAvailability WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and MtAvailibilityData_IsDeleted=0        
       
      
 END  
 
DROP TABLE IF EXISTS #temp_GenerationAvailability_Interface
DROP TABLE IF EXISTS #temp_GenerationAvailability
      
END   
  
