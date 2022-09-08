/****** Object:  Procedure [dbo].[Insert_BilateralContractData_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE PROCEDURE [dbo].[Insert_BilateralContractData_Interface]
	@fileMasterId decimal(18,0),
	@UserId Int,
    @tblBilateralContractData [dbo].[MtBilateralContract_UDT_Interface] READONLY
	
AS
BEGIN
   
BEGIN TRY
	 declare @vMtBilateralContract_Id Decimal(18,0);          
          
	SELECT @vMtBilateralContract_Id=ISNUll(MAX(MtBilateralContract_Id),0) +1 FROM MtBilateralContract;

	INSERT INTO MtBilateralContract_Interface(
		MtBilateralContract_RowNumber
	--, MtBilateralContract_Id      
	 , MtSOFileMaster_Id      
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
	,RuCDPDetail_CongestedZoneID	
	,MtBilateralContract_IsValid
	)

	SELECT

		ROW_NUMBER() OVER(order by MtBilateralContract_Date) AS MtBilateralContract_RowNumber
		--,  ROW_NUMBER() OVER(order by MtBilateralContract_Date) AS MtBilateralContract_Id
		,@fileMasterId
		,MtBilateralContract_Date
		,[MtBilateralContract_Hour]
		,[MtBilateralContract_ContractId]
		,[MtBilateralContract_SellerMPId]
		,[MtBilateralContract_BuyerMPId]
		,[MtBilateralContract_ContractType]
		,[MtBilateralContract_MeterOwnerMPId]
		,[MtBilateralContract_CDPID]
		,[MtBilateralContract_Percentage]
		,[MtBilateralContract_ContractedQuantity]
		,[MtBilateralContract_CapQuantity]
		,[MtBilateralContract_AncillaryServices]
		,[MtBilateralContract_DistributionLosses]
		,[MtBilateralContract_TransmissionLoss]
		,@userID
		,GETUTCDATE()
		,0
		,  CASE WHEN [MtBilateralContract_ContractType]='Generation Following' THEN 1     
          WHEN [MtBilateralContract_ContractType]='Load Following' THEN 2     
          WHEN [MtBilateralContract_ContractType]='Fixed' THEN 3     
          WHEN [MtBilateralContract_ContractType]='Customized' THEN 4 
		  else 0
  END    
  ,  
  CASE WHEN  [MtBilateralContract_ContractType]='Load Following' and (ISNULL([MtBilateralContract_DistributionLosses],'')<>'' ) and  (ISNULL([MtBilateralContract_TransmissionLoss],'')='') then 23  
    WHEN  [MtBilateralContract_ContractType]='Load Following' and (ISNULL([MtBilateralContract_DistributionLosses],'')= '') and  (ISNULL([MtBilateralContract_TransmissionLoss],'')<>'') then 22  
    WHEN  [MtBilateralContract_ContractType]='Load Following' and (ISNULL([MtBilateralContract_DistributionLosses],'')= '') and  (ISNULL([MtBilateralContract_TransmissionLoss],'') ='') then 21  
      WHEN  [MtBilateralContract_ContractType]='Customized' and ISNULL([MtBilateralContract_DistributionLosses],'') <> '' and  ISNULL([MtBilateralContract_TransmissionLoss],'') <>  ''  then 41  
      WHEN  [MtBilateralContract_ContractType]='Customized' and ((ISNULL([MtBilateralContract_DistributionLosses],'') ='' ) or  (ISNULL([MtBilateralContract_TransmissionLoss],'') ='' ))then 42  
	  WHEN [MtBilateralContract_ContractType]='Fixed' or [MtBilateralContract_ContractType]='Generation Following' then 0
  END  
  ,[BuyerSrCategory_Code]
  ,[SellerSrCategory_Code]
  ,1
  ,1
		FROM @tblBilateralContractData



	exec [dbo].[SOBilateralContractDataValidation] @fileMasterId,@UserId
END TRY
BEGIN CATCH
	 SELECT
    ERROR_NUMBER() AS ErrorNumber,
    --ERROR_STATE() AS ErrorState,
  -- ERROR_SEVERITY() AS ErrorSeverity,
  --  ERROR_PROCEDURE() AS ErrorProcedure,
   -- ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH

END
