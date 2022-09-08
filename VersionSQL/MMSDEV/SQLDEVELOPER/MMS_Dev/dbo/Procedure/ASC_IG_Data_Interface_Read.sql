/****** Object:  Procedure [dbo].[ASC_IG_Data_Interface_Read]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ---Author: Abdul Wahab
  
CREATE PROCEDURE [dbo].[ASC_IG_Data_Interface_Read]     
  
  @pMtSOFileMaster_Id DECIMAL(18, 0)  
, @pPageNumber INT  
, @pPageSize INT  
--, @pColumnName NVARCHAR(MAX) = NULL

,@pMtASC_IG_Date NVARCHAR(MAX) = NULL
,@pMtASC_IG_IsValid NVARCHAR(MAX) = NULL
,@pMtASC_IG_Hour NVARCHAR(MAX) = NULL
,@pMtASC_IG_GeneratorID NVARCHAR(MAX) = NULL
,@pMtASC_IG_Variablecost NVARCHAR(MAX) = NULL
,@pMtASC_IG_ExpectedEnergy NVARCHAR(MAX) = NULL
,@pMtASC_IG_Message NVARCHAR(MAX) = NULL


,@pfilterOperator NVARCHAR(MAX) = NULL

AS    
BEGIN    

DROP TABLE IF EXISTS #temp_ASC_IG_Interface
DROP TABLE IF EXISTS #temp_ASC_IG

  Declare @vStatus varchar(3);  
  SELECT @vStatus=LuStatus_Code FROM MtSOFileMaster WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id;

 
	IF(@vStatus='UPL')  
	BEGIN  
	
		SELECT
		     ROW_NUMBER() OVER(order by maii.MtAscIG_IsValid,maii.MtAscIG_RowNumber ) AS MtAscIG_RowNumber_new ,     
			  maii.MtAscIG_Id  
			,MtSOFileMaster_Id  
			,maii.MtAscIG_RowNumber  
			,case when isdate(maii.MtAscIG_Date)=1 then  convert(varchar, maii.MtAscIG_Date, 23)   else maii.MtAscIG_Date end AS MtAscIG_Date      
			,maii.MtAscIG_Hour
			,maii.MtAscIG_VariableCost  
			,maii.EnergyProduceIfNoAncillaryServices  
			,maii.MtAscIG_Message
			,maii.MtAscIG_IsValid
			,maii.MtGenerationUnit_Id
			,maii.MtAscIG_IsDeleted
		 INTO #temp_ASC_IG_Interface
		 FROM MtAscIG_Interface maii    
		 WHERE ISNULL(maii.MtAscIG_IsDeleted , 0) = 0    
			 AND maii.MtSOFileMaster_Id =@pMtSOFileMaster_Id    
			 --AND(@pMtASC_IG_Date IS NULL OR maii.MtAscIG_Date=@pMtASC_IG_Date)
			 AND(@pMtASC_IG_Hour IS NULL OR maii.MtAscIG_Hour=@pMtASC_IG_Hour)
			 AND(@pMtASC_IG_GeneratorID IS NULL OR maii.MtGenerationUnit_Id=@pMtASC_IG_GeneratorID)
			 AND(@pMtASC_IG_Variablecost IS NULL OR maii.MtAscIG_VariableCost=@pMtASC_IG_Variablecost)
			 AND(@pMtASC_IG_ExpectedEnergy IS NULL OR maii.EnergyProduceIfNoAncillaryServices=@pMtASC_IG_ExpectedEnergy)
			 AND(@pMtASC_IG_Message IS NULL OR maii.MtAscIG_Message LIKE ('%'+@pMtASC_IG_Message+'%'))
			 AND(@pMtASC_IG_Date IS NULL OR CONVERT(VARCHAR(10), CAST(maii.MtAscIG_Date AS DATE),101)=CONVERT(VARCHAR, CAST(@pMtASC_IG_Date AS DATE),101))
			 AND(@pMtASC_IG_IsValid IS NULL OR maii.MtAscIG_IsValid = @pMtASC_IG_IsValid)
		   
		 
		 SELECT * FROM #temp_ASC_IG_Interface
		 WHERE  (MtAscIG_RowNumber_new > ((@pPageNumber - 1) * @pPageSize)    
		 AND MtAscIG_RowNumber_new <= (@pPageNumber * @pPageSize))    
		 ORDER BY MtAscIG_RowNumber_new asc

	
	--END

	SELECT COUNT(1) as FilteredRows FROM #temp_ASC_IG_Interface mbci WHERE mbci.MtSOFileMaster_Id=@pMtSOFileMaster_Id and mbci.MtAscIG_IsDeleted=0   

 END 
 
  
 ELSE  
 BEGIN  

		SELECT     
		ROW_NUMBER() OVER(order by  mai.MtAscIG_RowNumber) AS MtAscIG_RowNumber_new,*    
		INTO #temp_ASC_IG
		FROM MtAscIG mai    
		WHERE ISNULL(mai.MtAscIG_IsDeleted, 0) = 0
		AND mai.MtSOFileMaster_Id =@pMtSOFileMaster_Id    
			AND(@pMtASC_IG_Date IS NULL OR mai.MtAscIG_Date=@pMtASC_IG_Date)
			AND(@pMtASC_IG_Hour IS NULL OR mai.MtAscIG_Hour=@pMtASC_IG_Hour)
			AND(@pMtASC_IG_GeneratorID IS NULL OR mai.MtGenerationUnit_Id=@pMtASC_IG_GeneratorID)
			AND(@pMtASC_IG_Variablecost IS NULL OR mai.MtAscIG_VariableCost=@pMtASC_IG_Variablecost)
			AND(@pMtASC_IG_ExpectedEnergy IS NULL OR mai.EnergyProduceIfNoAncillaryServices=@pMtASC_IG_ExpectedEnergy)
		 

		 SELECT * FROM #temp_ASC_IG
		 WHERE (MtAscIG_RowNumber_new > ((@pPageNumber - 1) * @pPageSize)    
			AND MtAscIG_RowNumber_new <= (@pPageNumber * @pPageSize))   
		ORDER BY MtAscIG_RowNumber_new asc  


			
	 -- END
  
  
 SELECT COUNT(1) as FilteredRows FROM #temp_ASC_IG mai WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and mai.MtAscIG_IsDeleted=0;    
   
  
 END

	 

  
END
