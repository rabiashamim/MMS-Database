/****** Object:  Procedure [dbo].[Insert_BilateralContract]    Committed by VersionSQL https://www.versionsql.com ******/

          
        
      
CREATE PROCEDURE dbo.Insert_BilateralContract          
  @fileMasterId decimal(18,0)      
 ,@UserId Int          
 ,@tblBilateralContract [dbo].[BilateralContract] READONLY          
           
AS          
BEGIN          
    SET NOCOUNT ON;          
   
        declare @version int=0;
		 select @version=MtSOFileMaster_Version from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId

		  declare @period int=0;
		  select @period =LuAccountingMonth_Id from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId

		  declare @pSOFileTemplate int=0;
		  select @pSOFileTemplate=LuSOFileTemplate_Id from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId

		  declare @tempname NVARCHAR(MAX)=NULL;
		  SELECT @tempname=LuSOFileTemplate_Name FROM LuSOFileTemplate WHERE  LuSOFileTemplate_Id=@pSOFileTemplate


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
  ,  CASE WHEN ContractType in ('Generation Following','Generation Following Supply Contract') THEN 1     
          WHEN ContractType in ('Load Following','Load Following Supply Contract') THEN 2     
          WHEN ContractType in ('Fixed Quantity','Financial Supply Contract with Fixed Quantities') THEN 3     
          WHEN ContractType in ('Customized','Customized Contract') THEN 4  
		  WHEN ContractType='Capacity and Associated Energy Supply Contract' THEN 5 
  END    
  ,  
  CASE WHEN  ContractType in ('Load Following','Load Following Supply Contract') and (ISNULL(DistributionLosses,'')<>'' ) and  (ISNULL(TransmissionLoss,'')='') then 23  
    WHEN  ContractType in ('Load Following','Load Following Supply Contract') and (ISNULL(DistributionLosses,'')= '') and  (ISNULL(TransmissionLoss,'')<>'') then 22  
    WHEN  ContractType in ('Load Following','Load Following Supply Contract') and (ISNULL(DistributionLosses,'')= '') and  (ISNULL(TransmissionLoss,'') ='') then 21  
      WHEN  ContractType in ('Customized','Customized Contract') and ISNULL(DistributionLosses,'') <> '' and  ISNULL(TransmissionLoss,'') <>  ''  then 41  
      WHEN  ContractType in ('Customized','Customized Contract') and ((ISNULL(DistributionLosses,'') ='' ) or  (ISNULL(TransmissionLoss,'') ='' ))then 42  
	  WHEN ContractType in ('Fixed Quantity','Financial Supply Contract with Fixed Quantities') or ContractType in ('Generation Following','Generation Following Supply Contract') then 0
  END  
  ,BuyerSrCategory_Code
  ,SellerSrCategory_Code
 FROM @tblBilateralContract        
 
 	declare @output VARCHAR(max);
			SET @output= +@tempname+'submitted for approval. Settlement Period:' +convert(varchar(max),@period) +',Version:' + convert(varchar(max),@version) 

				EXEC [dbo].[SystemLogs] 
				@user=@UserId,
				 @moduleName='Data Management',  
				 @CrudOperationName='Create',  
				 @logMessage=@output 
        
        
        
 UPDATE         
 MtSOFileMaster         
 set        
 LuStatus_Code= 'DRAF'         
WHERE         
 MtSOFileMaster_Id = @fileMasterId        
        
END 
