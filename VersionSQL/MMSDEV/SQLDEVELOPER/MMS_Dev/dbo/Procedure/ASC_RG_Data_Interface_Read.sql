/****** Object:  Procedure [dbo].[ASC_RG_Data_Interface_Read]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ---Author: Abdul Wahab
  
CREATE PROCEDURE [dbo].[ASC_RG_Data_Interface_Read]     
  
  @pMtSOFileMaster_Id DECIMAL(18, 0)  
, @pPageNumber INT  
, @pPageSize INT  
--, @pColumnName NVARCHAR(MAX) = NULL

,@pMtASC_RG_Date NVARCHAR(MAX) = NULL
,@pMtASC_RG_IsValid NVARCHAR(MAX) = NULL
,@pMtASC_RG_Hour NVARCHAR(MAX) = NULL
,@pMtASC_RG_GeneratorID NVARCHAR(MAX) = NULL
,@pMtASC_RG_Variablecost NVARCHAR(MAX) = NULL
,@pMtASC_RG_ExpectedEnergy NVARCHAR(MAX) = NULL
,@pGenerationUnitTypeARE NVARCHAR(MAX) = NULL
,@pMtASC_RG_Message NVARCHAR(MAX) = NULL


,@pfilterOperator NVARCHAR(MAX) = NULL

AS    
BEGIN    

DROP TABLE IF EXISTS #temp_ASC_RG_Interface
DROP TABLE IF EXISTS #temp_ASC_RG

  Declare @vStatus varchar(3);  
  SELECT @vStatus=LuStatus_Code FROM MtSOFileMaster WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id;

 
	IF(@vStatus='UPL')  
	BEGIN  
	
		SELECT
		     ROW_NUMBER() OVER(order by maii.MtAscRG_IsValid,maii.MtAscRG_RowNumber ) AS MtAscRG_RowNumber_new ,     
			  maii.MtAscRG_Id  
			,MtSOFileMaster_Id  
			,maii.MtAscRG_RowNumber  
			,case when isdate(maii.MtAscRG_Date)=1 then  convert(varchar, maii.MtAscRG_Date, 23)   else maii.MtAscRG_Date end AS MtAscRG_Date      
			,maii.MtAscRG_Hour
			,maii.MtAscRG_VariableCost  
			,maii.MtAscRG_ExpectedEnergy 
			,maii.GenerationUnitTypeARE
			,maii.MtAscRG_Message
			,maii.MtAscRG_IsValid
			,maii.MtGenerationUnit_Id
			,maii.MtAscRG_IsDeleted
		 INTO #temp_ASC_RG_Interface
		 FROM MtAscrG_Interface maii    
		 WHERE ISNULL(maii.MtAscRG_IsDeleted , 0) = 0    
			 AND maii.MtSOFileMaster_Id =@pMtSOFileMaster_Id    
			 --AND(@pMtASC_IG_Date IS NULL OR maii.MtAscIG_Date=@pMtASC_IG_Date)
			 AND(@pMtASC_RG_Hour IS NULL OR maii.MtAscRG_Hour=@pMtASC_RG_Hour)
			 AND(@pMtASC_RG_GeneratorID IS NULL OR maii.MtGenerationUnit_Id=@pMtASC_RG_GeneratorID)
			 AND(@pMtASC_RG_Variablecost IS NULL OR maii.MtAscRG_VariableCost=@pMtASC_RG_Variablecost)
			 AND(@pMtASC_RG_ExpectedEnergy IS NULL OR maii.MtAscRG_ExpectedEnergy=@pMtASC_RG_ExpectedEnergy)
			 AND(@pGenerationUnitTypeARE IS NULL OR maii.GenerationUnitTypeARE=@pGenerationUnitTypeARE)
			 AND(@pMtASC_RG_Message IS NULL OR maii.MtAscRG_Message LIKE ('%'+@pMtASC_RG_Message+'%'))
			 AND(@pMtASC_RG_Date IS NULL OR CONVERT(VARCHAR(10), CAST(maii.MtAscRG_Date AS DATE),101)=CONVERT(VARCHAR, CAST(@pMtASC_RG_Date AS DATE),101))
			 AND(@pMtASC_RG_IsValid IS NULL OR maii.MtAscRG_IsValid = @pMtASC_RG_IsValid)
		   
		 
		 SELECT * FROM #temp_ASC_RG_Interface
		 WHERE  (MtAscRG_RowNumber_new > ((@pPageNumber - 1) * @pPageSize)    
		 AND MtAscRG_RowNumber_new <= (@pPageNumber * @pPageSize))    
		 ORDER BY MtAscRG_RowNumber_new asc

	
	--END

	SELECT COUNT(1) as FilteredRows FROM #temp_ASC_RG_Interface mbci WHERE mbci.MtSOFileMaster_Id=@pMtSOFileMaster_Id and mbci.MtAscRG_IsDeleted=0   

 END 
 
  
 ELSE  
 BEGIN  

		SELECT     
		ROW_NUMBER() OVER(order by  mai.MtAscRG_Id) AS MtAscRG_RowNumber_new,*    
		INTO #temp_ASC_RG
		FROM MtAscRG mai    
		WHERE ISNULL(mai.MtAscRG_IsDeleted, 0) = 0
		AND mai.MtSOFileMaster_Id =@pMtSOFileMaster_Id    
			AND(@pMtASC_RG_Date IS NULL OR mai.MtAscRG_Date=@pMtASC_RG_Date)
			AND(@pMtASC_RG_Hour IS NULL OR mai.MtAscRG_Hour=@pMtASC_RG_Hour)
			AND(@pMtASC_RG_GeneratorID IS NULL OR mai.MtGenerationUnit_Id=@pMtASC_RG_GeneratorID)
			AND(@pMtASC_RG_Variablecost IS NULL OR mai.MtAscRG_VariableCost=@pMtASC_RG_Variablecost)
			AND(@pMtASC_RG_ExpectedEnergy IS NULL OR mai.MtAscRG_ExpectedEnergy=@pMtASC_RG_ExpectedEnergy)
			AND(@pGenerationUnitTypeARE IS NULL OR mai.GenerationUnitTypeARE=@pGenerationUnitTypeARE)
		 

		 SELECT * FROM #temp_ASC_RG
		 WHERE (MtAscRG_RowNumber_new > ((@pPageNumber - 1) * @pPageSize)    
			AND MtAscRG_RowNumber_new <= (@pPageNumber * @pPageSize))   
		ORDER BY MtAscRG_RowNumber_new asc  


			
	 -- END
  
  
 SELECT COUNT(1) as FilteredRows FROM #temp_ASC_RG mai WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and mai.MtAscRG_IsDeleted=0;    
   
  
 END

	 

  
END
