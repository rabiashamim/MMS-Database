/****** Object:  Procedure [dbo].[ASCReducedGenertation_Interface_Read]    Committed by VersionSQL https://www.versionsql.com ******/

--exec ASCIncreaseGenertation_Interface_Read 291,1,10    
CREATE PROCEDURE [dbo].[ASCReducedGenertation_Interface_Read]     
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
  *    
 FROM [MtAscRG_Interface]    
 WHERE ISNULL(MtAscRG_IsDeleted, 0) = 0    
 AND MtSOFileMaster_Id =@pMtSOFileMaster_Id    
    AND ([MtAscRG_RowNumber] > ((@pPageNumber - 1) * @pPageSize)    
 AND [MtAscRG_RowNumber] <= (@pPageNumber * @pPageSize))    
 ORDER BY 1    
    
    
 SELECT COUNT(1) as TotalRows FROM [MtAscRG_Interface] WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and MtAscRG_IsDeleted=0    
   
 END  
  
 else  
 BEGIN  
  
  
 SELECT     
  *    
 FROM [MtAscRG]    
 WHERE ISNULL(MtAscRG_IsDeleted, 0) = 0    
 AND MtSOFileMaster_Id =@pMtSOFileMaster_Id    
    AND (MtAscRG_RowNumber > ((@pPageNumber - 1) * @pPageSize)    
 AND MtAscRG_RowNumber <= (@pPageNumber * @pPageSize))    
 ORDER BY 1    
  
  
 SELECT COUNT(1) as TotalRows FROM [MtAscRG] WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and MtAscRG_IsDeleted=0    
   
  
 END  
  
END     
    
