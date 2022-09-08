/****** Object:  Procedure [dbo].[BilateralContractData_Interface_Read_Temp]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
--exec AvailibilityData_Interface_Read 291,1,10    
CREATE PROCEDURE [dbo].[BilateralContractData_Interface_Read_Temp]     
  
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
  MtBilateralContract_Id  
,MtSOFileMaster_Id  
,MtBilateralContract_RowNumber  
,case when isdate(MtBilateralContract_Date)=1 then  convert(varchar, MtBilateralContract_Date, 23)   else MtBilateralContract_Date end MtBilateralContract_Date      
,MtBilateralContract_Hour  
,MtBilateralContract_ContractId  
,MtBilateralContract_SellerMPId  
,MtBilateralContract_BuyerMPId  
,MtBilateralContract_ContractType  
,MtBilateralContract_MeterOwnerMPId  
,MtBilateralContract_CDPID  
,MtBilateralContract_Percentage  
,MtBilateralContract_ContractedQuantity  
,MtBilateralContract_CapQuantity  
,MtBilateralContract_AncillaryServices  
,MtBilateralContract_DistributionLosses  
,MtBilateralContract_TransmissionLoss  
,MtBilateralContract_CreatedBy  
,MtBilateralContract_CreatedOn  
,MtBilateralContract_ModifiedBy  
,MtBilateralContract_ModifiedOn  
,MtBilateralContract_Deleted  
,SrContractType_Id  
,ContractSubType_Id  
,BmeStatementData_NtdcDateTime  
,BuyerSrCategory_Code  
,SellerSrCategory_Code  
,RuCDPDetail_CongestedZoneID  
,RuCDPDetail_TaxZoneID  
,MtBilateralContract_Message  
,MtBilateralContract_IsValid  
 FROM MtBilateralContract_Interface mbci    
 WHERE ISNULL(mbci.MtBilateralContract_Deleted, 0) = 0    
 AND mbci.MtSOFileMaster_Id =@pMtSOFileMaster_Id    
    AND (mbci.MtBilateralContract_RowNumber > ((@pPageNumber - 1) * @pPageSize)    
 AND mbci.MtBilateralContract_RowNumber <= (@pPageNumber * @pPageSize))    
 ORDER BY MtBilateralContract_RowNumber asc    
    
    
 SELECT COUNT(1) as TotalRows FROM MtBilateralContract_Interface mbci WHERE mbci.MtSOFileMaster_Id=@pMtSOFileMaster_Id and mbci.MtBilateralContract_Deleted=0    
   
 END  
  
 else  
 BEGIN  
  
  
 SELECT     
  *    
 FROM MtBilateralContract mbc    
 WHERE ISNULL(mbc.MtBilateralContract_Deleted, 0) = 0    
 AND mbc.MtSOFileMaster_Id =@pMtSOFileMaster_Id    
    AND (mbc.MtBilateralContract_RowNumber > ((@pPageNumber - 1) * @pPageSize)    
 AND mbc.MtBilateralContract_RowNumber <= (@pPageNumber * @pPageSize))    
 ORDER BY MtBilateralContract_RowNumber    
  
  
 SELECT COUNT(1) as TotalRows FROM MtBilateralContract mbc WHERE MtSOFileMaster_Id=@pMtSOFileMaster_Id and mbc.MtBilateralContract_Deleted=0    
   
  
 END  
  
END     
  
