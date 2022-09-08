/****** Object:  Procedure [dbo].[AvailibilityData_Interface_Read_Old]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--exec AvailibilityData_Interface_Read 291,1,10      
CREATE PROCEDURE [dbo].[AvailibilityData_Interface_Read_Old]       
    
  @pMtSOFileMaster_Id DECIMAL(18, 0)    
, @pPageNumber INT    
, @pPageSize INT    
AS      
BEGIN      
  Declare @vStatus varchar(3);    
  SELECT @vStatus=LuStatus_Code FROM MtSOFileMaster WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id    
      
  if(@vStatus='UPL')    
  BEGIN    
 SELECT       
 MtAvailibilityData_Id  
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
  
 FROM [MtAvailibilityData_Interface]      
 WHERE ISNULL(MtAvailibilityData_IsDeleted, 0) = 0      
 AND MtSOFileMaster_Id =@pMtSOFileMaster_Id      
    AND ([MtAvailibilityData_RowNumber] > ((@pPageNumber - 1) * @pPageSize)      
 AND [MtAvailibilityData_RowNumber] <= (@pPageNumber * @pPageSize))      
 ORDER BY 1      
      
      
 SELECT COUNT(1) as TotalRows FROM [MtAvailibilityData_Interface] WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and MtAvailibilityData_IsDeleted=0      
     
 END    
    
 else    
 BEGIN    
    
    
 SELECT       
  *      
 FROM [MtAvailibilityData]      
 WHERE ISNULL(MtAvailibilityData_IsDeleted, 0) = 0      
 AND MtSOFileMaster_Id =@pMtSOFileMaster_Id      
    AND ([MtAvailibilityData_RowNumber] > ((@pPageNumber - 1) * @pPageSize)      
 AND [MtAvailibilityData_RowNumber] <= (@pPageNumber * @pPageSize))      
 ORDER BY 1      
    
    
 SELECT COUNT(1) as TotalRows FROM [MtAvailibilityData] WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and MtAvailibilityData_IsDeleted=0      
     
    
 END    
    
END 
