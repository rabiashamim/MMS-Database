/****** Object:  Procedure [dbo].[Insert_BilateralContractV2]    Committed by VersionSQL https://www.versionsql.com ******/

          
        
      
CREATE PROCEDURE [dbo].[Insert_BilateralContractV2]          
  @fileMasterId decimal(18,0)      
 ,@UserId Int                   
           
AS          
BEGIN          
    SET NOCOUNT ON;          
 declare @vMtBilateralContract_Id Decimal(18,0);          
          
 SELECT @vMtBilateralContract_Id=ISNUll(MAX(MtBilateralContract_Id),0)+1 FROM MtBilateralContract            
           
          
            
    INSERT INTO MtBilateralContract          
 (          
 MtBilateralContract_RowNumber  
 ,MtBilateralContract_Id
 ,  MtSOFileMaster_Id      
 , MtBilateralContract_Date      
 , MtBilateralContract_Hour      
 , MtBilateralContract_ContractId      
 , MtBilateralContract_SellerMPId      
 , MtBilateralContract_BuyerMPId      
 , MtBilateralContract_ContractType      
 , MtBilateralContract_MeterOwnerMPId      
 , MtBilateralContract_CDPID      
 , MtBilateralContract_Percentage      
 , MtBilateralContract_ContractedQuantity      
 , MtBilateralContract_CapQuantity      
 , MtBilateralContract_AncillaryServices      
 , MtBilateralContract_DistributionLosses      
 , MtBilateralContract_TransmissionLoss      
 , MtBilateralContract_CreatedBy      
 , MtBilateralContract_CreatedOn      
 ,  MtBilateralContract_Deleted     
 , SrContractType_Id    
 ,ContractSubType_Id  
 ,BuyerSrCategory_Code
 ,SellerSrCategory_Code
 )          
    SELECT 
	MtBilateralContract_RowNumber
	,@vMtBilateralContract_Id +ROW_NUMBER() OVER(order by MtBilateralContract_Date) AS MtBilateralContract_Id
	,@fileMasterId
	,mbci.MtBilateralContract_Date
	,mbci.MtBilateralContract_Hour
	,mbci.MtBilateralContract_ContractId
	,mbci.MtBilateralContract_SellerMPId
	,MtBilateralContract_BuyerMPId
	,MtBilateralContract_ContractType
	,MtBilateralContract_MeterOwnerMPId
	,MtBilateralContract_CDPID
	,MtBilateralContract_Percentage
	,MtBilateralContract_ContractedQuantity
	,MtBilateralContract_CapQuantity
	,MtBilateralContract_AncillaryServices
	,mbci.MtBilateralContract_DistributionLosses
	,mbci.MtBilateralContract_TransmissionLoss
	,@UserId
	,GETUTCDATE()
	,0
	, CASE WHEN MtBilateralContract_ContractType='Generation Following' THEN 1     
          WHEN MtBilateralContract_ContractType='Load Following' THEN 2     
          WHEN MtBilateralContract_ContractType='Fixed Quantity' THEN 3     
          WHEN MtBilateralContract_ContractType='Customized' THEN 4     
  END    
  ,  
  CASE WHEN  MtBilateralContract_ContractType='Load Following' and (ISNULL(MtBilateralContract_DistributionLosses,'')<>'' ) and  (ISNULL(MtBilateralContract_TransmissionLoss,'')='') then 23  
    WHEN  MtBilateralContract_ContractType='Load Following' and (ISNULL(MtBilateralContract_DistributionLosses,'')= '') and  (ISNULL(MtBilateralContract_TransmissionLoss,'')<>'') then 22  
    WHEN  MtBilateralContract_ContractType='Load Following' and (ISNULL(MtBilateralContract_DistributionLosses,'')= '') and  (ISNULL(MtBilateralContract_TransmissionLoss,'') ='') then 21  
      WHEN  MtBilateralContract_ContractType='Customized' and ISNULL(MtBilateralContract_DistributionLosses,'') <> '' and  ISNULL(MtBilateralContract_TransmissionLoss,'') <>  ''  then 41  
      WHEN  MtBilateralContract_ContractType='Customized' and ((ISNULL(MtBilateralContract_DistributionLosses,'') ='' ) or  (ISNULL(MtBilateralContract_TransmissionLoss,'') ='' ))then 42  
	  WHEN MtBilateralContract_ContractType='Fixed Quantity' or MtBilateralContract_ContractType='Generation Following' then 0
  END  
  ,BuyerSrCategory_Code
  ,SellerSrCategory_Code
	FROM 
	MtBilateralContract_Interface mbci 
	WHERE mbci.MtSOFileMaster_Id = @fileMasterId;
               
        
 UPDATE         
 MtSOFileMaster         
 set        
 LuStatus_Code= 'DRAF'         
WHERE         
 MtSOFileMaster_Id = @fileMasterId   
 

 DELETE FROM MtBilateralContract_Interface WHERE MtSOFileMaster_Id = @fileMasterId;
        
END 
