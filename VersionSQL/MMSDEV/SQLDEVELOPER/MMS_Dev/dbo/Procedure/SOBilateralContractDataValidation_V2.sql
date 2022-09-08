/****** Object:  Procedure [dbo].[SOBilateralContractDataValidation_V2]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--exec [dbo].[SOAvailabilityDataValidation] 295,1    
CREATE PROCEDURE  [dbo].[SOBilateralContractDataValidation_V2]        
@MtSOFileMaster_Id DECIMAL(18,0),        
@userID DECIMAL(18,0)        
AS        
BEGIN     
    
 UPDATE MBI    
 SET mbi.MtBilateralContract_Message =  ISNULL(MtBilateralContract_Message + ',','')     
 + CASE WHEN MBI.MtBilateralContract_Date IS NULL THEN 'Date is missing. ' ELSE '' END    
    
 + CASE WHEN ISNUMERIC(MBI.MtBilateralContract_Hour)=0 THEN 'Hour is missing. ' ELSE '' END    
    
 + CASE WHEN isnull(MBI.MtBilateralContract_Hour,0)<0 OR isnull(MBI.MtBilateralContract_Hour,0)>23 THEN 'Hour must be between 0-23' ELSE '' END    
    
 + CASE WHEN (MBI.MtBilateralContract_ContractType  IS null) THEN 'Contract Type is missing. ' ELSE '' END    
    
 + CASE WHEN MBI.MtBilateralContract_MeterOwnerMPId IS NULL THEN 'Meter owner Id is missing. ' ELSE '' END    
    
 + CASE WHEN MBI.SrContractType_Id = 1 AND mbi.MtBilateralContract_MeterOwnerMPId <> mbi.MtBilateralContract_SellerMPId THEN '    
 Value of meter owner will always be of Seller. ' ELSE '' END    
    
 + CASE WHEN MBI.SrContractType_Id = 2 AND MBI.MtBilateralContract_MeterOwnerMPId <> mbi.MtBilateralContract_BuyerMPId THEN 'Value of Meter owner will always be of Buyer. ' ELSE '' END    
    
 + CASE WHEN MBI.SrContractType_Id = 3 AND ISNULL(mbi.MtBilateralContract_ContractedQuantity,0)=0 THEN 'Contracted Quantity value is a must. ' ELSE     
 '' END    
    
 + CASE WHEN MBI.SrContractType_Id = 4 AND    
 ((ISNULL(MBI.MtBilateralContract_Percentage,0)=0 AND ISNULL(mbi.MtBilateralContract_ContractedQuantity,0)=0) OR    
    
 ((ISNULL(MBI.MtBilateralContract_Percentage,0)<>0 AND ISNULL(mbi.MtBilateralContract_ContractedQuantity,0)<>0)))    
 THEN 'Either Percentage value or Contacted Quantity is must. Both columns cannot have values at the same time. '    
 ELSE '' END    
 + CASE WHEN MBI.SrContractType_Id = 4 AND  MBI.MtBilateralContract_DistributionLosses IS NULL THEN 'Distribution Loss is required. ' ELSE '' END    
 + CASE WHEN MBI.SrContractType_Id = 4 AND MBI.MtBilateralContract_DistributionLosses <> 'Buyer' OR MBI.MtBilateralContract_DistributionLosses <> 'Seller' THEN 'Distribution Loss must either be Buyer or Seller. ' ELSE '' END    
 + CASE WHEN MBI.MtBilateralContract_TransmissionLoss IS null THEN 'Transmission Loss is required. ' ELSE '' END    
 + CASE WHEN MBI.MtBilateralContract_TransmissionLoss <> 'Buyer' OR MBI.MtBilateralContract_TransmissionLoss <> 'Seller' THEN 'Transmission Loss must either be Buyer or Seller. ' ELSE '' END    
 + CASE WHEN MBI.SrContractType_Id= 1 OR MBI.SrContractType_Id = 2 AND MBI.MtBilateralContract_Percentage IS NULL THEN 'Percentage is missing. ' ELSE '' END    
    
 + CASE WHEN  ISNULL(MBI.MtBilateralContract_Percentage,0) < 0  OR ISNULL(MBI.MtBilateralContract_Percentage,0) > 100 THEN 'Invalid Percentage. ' ELSE '' END     
 FROM    
 MtBilateralContract_Interface MBI    
 WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id;    
    
    
    
    
 UPDATE MtBilateralContract_Interface     
 SET MtBilateralContract_Message = ISNULL(MtBilateralContract_Message + ',','') + 'Invalid Seller MP ID. '    
 WHERE     
 MtSOFileMaster_Id=@MtSOFileMaster_Id     
   AND ISNULL(MtBilateralContract_Deleted,0)=0      
   AND(
   MtBilateralContract_SellerMPId IS NULL OR
   MtBilateralContract_SellerMPId NOT IN(select P.MtPartyRegisteration_Id from dbo.MtPartyRegisteration P WHERE ISNULL(P.isDeleted,0)=0));    
    
 UPDATE MtBilateralContract_Interface    
 SET MtBilateralContract_Message = ISNULL(MtBilateralContract_Message + ',','') + 'Invalid Buyer MP ID. '    
 WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id     
   AND ISNULL(MtBilateralContract_Deleted,0)=0      
   AND (
   MtBilateralContract_BuyerMPId IS NULL OR
   MtBilateralContract_BuyerMPId NOT IN(select P.MtPartyRegisteration_Id from dbo.MtPartyRegisteration P WHERE ISNULL(P.isDeleted,0)=0));    
    
 UPDATE MtBilateralContract_Interface    
 SET MtBilateralContract_Message  = ISNULL(MtBilateralContract_Message + ',','') + 'Invalid CDP ID. '    
 WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id     
   AND ISNULL(MtBilateralContract_Deleted,0)=0    
   AND( MtBilateralContract_CDPID is NULL OR MtBilateralContract_CDPID NOT IN (    
   SELECT rc.RuCDPDetail_CdpId FROM RuCDPDetail rc     
   ));    
    
 UPDATE MtBilateralContract_Interface    
 SET MtBilateralContract_Message  = ISNULL(MtBilateralContract_Message + ',','') + 'Invalid Seller Category Code. '    
 WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id     
   AND ISNULL(MtBilateralContract_Deleted,0)=0    
   AND(  SellerSrCategory_Code is NULL OR SellerSrCategory_Code NOT IN (    
   SELECT sc.SrCategory_Code FROM SrCategory sc    
   ))    
    
 UPDATE MtBilateralContract_Interface    
 SET MtBilateralContract_Message  = ISNULL(MtBilateralContract_Message + ',','') + 'Invalid Buyer Category Code. '    
 WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id     
   AND ISNULL(MtBilateralContract_Deleted,0)=0    
   AND ( BuyerSrCategory_Code is NULL OR BuyerSrCategory_Code NOT IN (    
   SELECT sc.SrCategory_Code FROM SrCategory sc    
   ))    

   UPDATE MtBilateralContract_Interface
   SET MtBilateralContract_Message = ISNULL(MtBilateralContract_Message + ',','') + 'Invalid Contract Type. '
   WHERE MtSOFileMaster_Id= @MtSOFileMaster_Id
   AND ISNULL(MtBilateralContract_Deleted,0)=0
   AND (MtBilateralContract_ContractType IS NULL OR MtBilateralContract_ContractType NOT IN (
   SELECT sc.SrCategory_Name FROM SrCategory sc
   ))
    
 UPDATE MtBilateralContract_Interface    
 SET MtBilateralContract_IsValid = 0    
 WHERE ISNULL(MtBilateralContract_Message,'') <> ''    
 AND ISNULL(MtBilateralContract_Deleted,0) = 0    
  
 IF EXISTS(SELECT 1 FROM MtBilateralContract_Interface WHERE MtBilateralContract_IsValid=0 and  MtSOFileMaster_Id=@MtSOFileMaster_Id)  
 BEGIN   
 ;WITH CTE AS(  
 SELECT MtBilateralContract_RowNumber,MtBilateralContract_IsValid,MtBilateralContract_Id,   
 ROW_NUMBER() OVER(order by MtBilateralContract_IsValid,MtBilateralContract_RowNumber ) AS MtBilateralContract_RowNumber_new    
 FROM MtBilateralContract_Interface WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id--  
 )  
  
 UPDATE M    
 SET MtBilateralContract_RowNumber = MtBilateralContract_RowNumber_new    
 FROM MtBilateralContract_Interface M INNER JOIN CTE c on c.MtBilateralContract_Id=m.MtBilateralContract_Id  
 WHERE m.MtSOFileMaster_Id=@MtSOFileMaster_Id--MtSOFileMaster_Id=277  
  
  
 END  
  
    
    
     
DECLARE @vInvalidCount BIGINT=0;    
    
SELECT @vInvalidCount=COUNT(1)  FROM MtBilateralContract_Interface mbci     
WHERE    
 mbci.MtSOFileMaster_Id=@MtSOFileMaster_Id    
 AND ISNULL(mbci.MtBilateralContract_Deleted,0)=0    
 AND mbci.MtBilateralContract_IsValid=0    
    
    
UPDATE MtSOFileMaster SET InvalidRecords= @vInvalidCount    
WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id    
    
SELECT @vInvalidCount;    
    
END
