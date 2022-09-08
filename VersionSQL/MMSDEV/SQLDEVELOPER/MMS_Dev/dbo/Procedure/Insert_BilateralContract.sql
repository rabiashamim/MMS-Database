/****** Object:  Procedure [dbo].[Insert_BilateralContract]    Committed by VersionSQL https://www.versionsql.com ******/

          
        
      
CREATE PROCEDURE [dbo].[Insert_BilateralContract]          
  @fileMasterId decimal(18,0)      
 ,@UserId Int          
 ,@tblBilateralContract [dbo].[BilateralContract] READONLY          
           
AS          
BEGIN          
    SET NOCOUNT ON;          
 declare @vMtBilateralContract_Id Decimal(18,0);          
          
 SELECT @vMtBilateralContract_Id=ISNUll(MAX(MtBilateralContract_Id),0) FROM MtBilateralContract            
           
          
            
    INSERT INTO MtBilateralContract          
 (          
 MtBilateralContract_Id      
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
   @vMtBilateralContract_Id +ROW_NUMBER() OVER(order by [Hours]) AS num_row           
  ,@fileMasterId          
  ,Date        
  ,Hours       
  ,ContractId      
  ,SellerMPId      
  ,BuyerMPId       
  ,ContractType      
  ,MeterOwnerMPId      
  ,CDPID       
  ,Percentage       
  ,ContractedQuantity       
  ,CapQuantity       
  ,AncillaryServices      
  ,DistributionLosses      
  ,TransmissionLoss       
  ,@UserId          
  ,GETUTCDATE()          
  ,0          
  ,  CASE WHEN ContractType='Generation Following' THEN 1     
          WHEN ContractType='Load Following' THEN 2     
          WHEN ContractType='Fixed Quantity' THEN 3     
          WHEN ContractType='Customized' THEN 4     
  END    
  ,  
  CASE WHEN  ContractType='Load Following' and (ISNULL(DistributionLosses,'')<>'' ) and  (ISNULL(TransmissionLoss,'')='') then 23  
    WHEN  ContractType='Load Following' and (ISNULL(DistributionLosses,'')= '') and  (ISNULL(TransmissionLoss,'')<>'') then 22  
    WHEN  ContractType='Load Following' and (ISNULL(DistributionLosses,'')= '') and  (ISNULL(TransmissionLoss,'') ='') then 21  
      WHEN  ContractType='Customized' and ISNULL(DistributionLosses,'') <> '' and  ISNULL(TransmissionLoss,'') <>  ''  then 41  
      WHEN  ContractType='Customized' and ((ISNULL(DistributionLosses,'') ='' ) or  (ISNULL(TransmissionLoss,'') ='' ))then 42  
	  WHEN ContractType='Fixed Quantity' or ContractType='Generation Following' then 0
  END  
  ,BuyerSrCategory_Code
  ,SellerSrCategory_Code
 FROM @tblBilateralContract          
        
        
        
 UPDATE         
 MtSOFileMaster         
 set        
 LuStatus_Code= 'DRAF'         
WHERE         
 MtSOFileMaster_Id = @fileMasterId        
        
END 
