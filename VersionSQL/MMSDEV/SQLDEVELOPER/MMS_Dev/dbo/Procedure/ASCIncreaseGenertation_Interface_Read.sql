/****** Object:  Procedure [dbo].[ASCIncreaseGenertation_Interface_Read]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
--exec ASCIncreaseGenertation_Interface_Read 291,1,10        
CREATE PROCEDURE [dbo].[ASCIncreaseGenertation_Interface_Read]         
      
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
 MtAscIG_Id    
,MtSOFileMaster_Id    
,MtGenerationUnit_Id   
,case when isdate(MtAscIG_Date)=1 then  convert(varchar, MtAscIG_Date, 23)  else MtAscIG_Date end MtAscIG_Date    
,MtAscIG_Hour    
,MtAscIG_VariableCost    
,MtAscIG_CreatedBy    
,MtAscIG_CreatedOn    
,MtAscIG_ModifiedBy    
,MtAscIG_ModifiedOn    
,MtAscIG_IsDeleted    
,EnergyProduceIfNoAncillaryServices    
,Reason    
,MTAscIG_NtdcDateTime    
,MtAscIG_RowNumber    
,MtAscIG_IsValid    
,MtAscIG_Message    
 FROM [MtAscIG_Interface]        
 WHERE ISNULL(MtAscIG_IsDeleted, 0) = 0        
 AND MtSOFileMaster_Id =@pMtSOFileMaster_Id        
    AND ([MtAscIG_RowNumber] > ((@pPageNumber - 1) * @pPageSize)        
 AND [MtAscIG_RowNumber] <= (@pPageNumber * @pPageSize))        
 ORDER BY MtAscIG_RowNumber        
        
        
 SELECT COUNT(1) as TotalRows FROM [MtAscIG_Interface] WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and MtAscIG_IsDeleted=0        
       
 END      
      
 else      
 BEGIN      
      
      
 SELECT         
  *        
 FROM [MtAscIG]        
 WHERE ISNULL(MtAscIG_IsDeleted, 0) = 0        
 AND MtSOFileMaster_Id =@pMtSOFileMaster_Id        
    AND (MtAscIG_RowNumber > ((@pPageNumber - 1) * @pPageSize)        
 AND MtAscIG_RowNumber <= (@pPageNumber * @pPageSize))        
 ORDER BY MtAscIG_RowNumber        
      
      
 SELECT COUNT(1) as TotalRows FROM [MtAscIG] WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and MtAscIG_IsDeleted=0        
       
      
 END      
      
END   
  
