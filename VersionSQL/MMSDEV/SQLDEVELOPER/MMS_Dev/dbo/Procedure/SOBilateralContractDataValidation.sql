/****** Object:  Procedure [dbo].[SOBilateralContractDataValidation]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--exec [dbo].[SOAvailabilityDataValidation] 500,1    
CREATE Procedure  [dbo].[SOBilateralContractDataValidation]        
@MtSOFileMaster_Id DECIMAL(18,0),        
@userID DECIMAL(18,0)        
AS        
BEGIN

	declare
	@month varchar(max), 
	@year varchar(max)

	 select @month = LuAccountingMonth_Month,@year = LuAccountingMonth_Year 
	 from LuAccountingMonth 
	 where LuAccountingMonth_Id = (select LuAccountingMonth_Id from MtSOFileMaster where MtSOFileMaster_Id = @MtSOFileMaster_Id)

	
	 UPDATE MBI    
		SET mbi.MtBilateralContract_Message =  ISNULL(MtBilateralContract_Message + ',','') 
		
		+ case when SrContractType_Id = 1 and mbi.MtBilateralContract_MeterOwnerMPId <> mbi.MtBilateralContract_SellerMPId then 'Value of Meter Owner will always be of Seller. ' else '' end

		+ case when (SrContractType_Id IN(1,2)) and MtBilateralContract_Percentage is null then 'Percentage value is must. ' else '' end

		+ case when (SrContractType_Id IN(1,2)) and (MtBilateralContract_ContractedQuantity is not NULL AND  LEN(RTRIM(ISNULL(MtBilateralContract_ContractedQuantity, ''))) > 0) then 'Contracted quantity should be empty. ' else '' end

		+ case when (SrContractType_Id IN (1,2,3)) and (MtBilateralContract_CapQuantity is not NULL AND LEN(RTRIM(ISNULL(MtBilateralContract_CapQuantity, ''))) > 0) then 'Cap Quantity should be empty. ' else '' end

		+ case when (SrContractType_Id IN (1,2,3)) and (MtBilateralContract_DistributionLosses IS NOT NULL AND LEN(RTRIM(ISNULL(MtBilateralContract_DistributionLosses, ''))) > 0) then 'Distribution Losses should be empty. ' else '' end

		+ case when (SrContractType_Id IN (1,2,3)) and (MtBilateralContract_TransmissionLoss is not NULL AND  LEN(RTRIM(ISNULL(MtBilateralContract_TransmissionLoss, ''))) > 0) then 'Transmission loss should be empty. ' else '' end

		+ case when SrContractType_Id = 2 and MtBilateralContract_MeterOwnerMPId <> MtBilateralContract_BuyerMPId then 'Value of Meter Owner will always be of Buyer. ' else '' end

		+ case when SrContractType_Id = 3 and MtBilateralContract_MeterOwnerMPId is not NULL AND   LEN(RTRIM(ISNULL(MtBilateralContract_MeterOwnerMPId, ''))) > 0 then 'Meter owner ID should be empty for Fixed Contract. ' else '' end

		+ case when SrContractType_Id = 3 and (MtBilateralContract_CDPID is not null AND   LEN(RTRIM(ISNULL(MtBilateralContract_CDPID, ''))) > 0)then 'CDP ID should be empty for Fixed Contract. ' else '' end

		+ case when SrContractType_Id = 3 and (MtBilateralContract_Percentage is not NULL AND LEN(RTRIM(ISNULL(MtBilateralContract_Percentage, ''))) > 0) then 'Percentage should be empty for Fixed Contract. ' else '' end

		+ case when SrContractType_Id = 3 and MtBilateralContract_ContractedQuantity is null  then 'Contracted Quantity value is must. ' else '' end

		+ case when SrContractType_Id = 4 and ((MtBilateralContract_Percentage is null and MtBilateralContract_ContractedQuantity is null)
		or (MtBilateralContract_Percentage is not null and MtBilateralContract_ContractedQuantity is not null)) 
		then 'Either Percentage value or Contracted Quantity is must, Both columns cannot have values at a same time. ' else '' end

		+ case when SrContractType_Id = 4 and MtBilateralContract_DistributionLosses is null then 'Distribution loss is mandatory. ' else '' end

		+ case when SrContractType_Id = 4 and MtBilateralContract_DistributionLosses is not null  and MtBilateralContract_DistributionLosses not in ('Buyer','Seller') then 'Distribution loss must be buyer or seller. ' else '' end
		
		--+ case when SrContractType_Id = 4 and MtBilateralContract_TransmissionLoss is null then 'Transmission loss is mandatory. ' else '' end

		--+ case when SrContractType_Id = 4 and MtBilateralContract_TransmissionLoss is not null  and MtBilateralContract_TransmissionLoss not in ('Buyer','Seller') then 'Transmission loss must be buyer or seller. ' else '' end

		+ case when MtBilateralContract_SellerMPId is null then 'Seller ID is missing. ' else '' end

		+ case when MtBilateralContract_SellerMPId is not null 
		and MtBilateralContract_SellerMPId not in (select P.MtPartyRegisteration_Id from dbo.MtPartyRegisteration P WHERE ISNULL(P.isDeleted,0)=0)
		then 'Seller ID is invalid. ' else '' end
		
		+ case when MtBilateralContract_BuyerMPId is null then 'Buyer ID is missing. ' else '' end

		+ case when MtBilateralContract_BuyerMPId is not null 
		and MtBilateralContract_BuyerMPId not in (select P.MtPartyRegisteration_Id from dbo.MtPartyRegisteration P WHERE ISNULL(P.isDeleted,0)=0)
		then 'Buyer ID is invalid. ' else '' end

		+ case WHEN (MBI.SrContractType_Id <> 3 AND MtBilateralContract_CDPID is NULL) then 'CDP ID is missing. ' else '' end

		+ case when (MBI.SrContractType_Id <> 3 AND MtBilateralContract_CDPID is not NULL and MtBilateralContract_CDPID not in (SELECT rc.RuCDPDetail_CdpId FROM RuCDPDetail rc))
		then 'Invalid CDP ID. ' else '' end

		+ case when MtBilateralContract_AncillaryServices is not null and MtBilateralContract_AncillaryServices <> '' and MtBilateralContract_AncillaryServices not in ('Buyer', 'Seller') then
		'Ancillary can only be buyer or seller' else '' end

		--+ CASE WHEN MBI.MtBilateralContract_Date IS NULL THEN 'Date is missing. ' ELSE '' END 
		
		+ CASE WHEN ISDATE(MtBilateralContract_Date)=0 THEN  'Date is not valid. ' else 
			CASE WHEN DATEPART(Month,MtBilateralContract_Date)=@month THEN '' ELSE 'Date should be of selected settlement month only. ' END
			+ CASE WHEN DATEPART(Year,MtBilateralContract_Date)=@year THEN '' ELSE 'Date should be of selected settlement year only. ' END
		  END 

		+ CASE WHEN ISNUMERIC(MBI.MtBilateralContract_Hour)=0 THEN 'Hour is missing. ' ELSE '' END   

		+ CASE WHEN isnull(MBI.MtBilateralContract_Hour,0)<0 OR isnull(MBI.MtBilateralContract_Hour,0)>23 THEN 'Hour must be between 0-23. ' ELSE '' END 

		+ CASE WHEN (MBI.MtBilateralContract_ContractType  IS null) THEN 'Contract Type is missing. ' ELSE '' END    
    
		 + CASE WHEN SrContractType_Id <> 3 AND MBI.MtBilateralContract_MeterOwnerMPId IS NULL THEN 'Meter owner Id is missing. ' ELSE '' END   

		+ CASE WHEN MtBilateralContract_Percentage is not null and(MBI.MtBilateralContract_Percentage < 0  OR MBI.MtBilateralContract_Percentage > 100)THEN 'Invalid Percentage. ' ELSE '' END   
		
		+ CASE WHEN (MBI.SrContractType_Id IN (1,2)) AND MBI.MtBilateralContract_Percentage IS NULL THEN 'Percentage is missing. ' ELSE '' END    

		+ case when SellerSrCategory_Code is null then 'Seller category code is missing. ' else '' end

		+ case when SellerSrCategory_Code is not null and SellerSrCategory_Code not in ( SELECT sc.SrCategory_Code FROM SrCategory sc) 
		then 'Invalid Seller Category Code. ' else '' end

		+ case when BuyerSrCategory_Code is null then 'Buyer category code is missing. ' else '' end

		+ case when BuyerSrCategory_Code is not null and BuyerSrCategory_Code not in (SELECT sc.SrCategory_Code FROM SrCategory sc) 
		then 'Invalid Buyer Category Code. ' else '' end

	--	+ case when MtBilateralContract_ContractType is null then 'Contract type is missing. ' else '' end

		+ case when SrContractType_Id is not null and MtBilateralContract_ContractType is not null and SrContractType_Id = 0 then 'Contract type other than standard contract types. ' else '' end

		
	 FROM    
		MtBilateralContract_Interface MBI    
	 WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id and isnull(MtBilateralContract_Deleted,0) = 0; 



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
	 
	 DECLARE @vTotalRecords BIGINT = 0;

	 SELECT @vTotalRecords = COUNT(1) FROM MtBilateralContract_Interface mbci
	 WHERE mbci.MtSOFileMaster_Id = @MtSOFileMaster_Id
	 AND ISNULL(mbci.MtBilateralContract_Deleted,0) = 0;
    
    
	UPDATE MtSOFileMaster SET InvalidRecords= @vInvalidCount , TotalRecords = @vTotalRecords   
	WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id    
    
	SELECT @vInvalidCount, @vTotalRecords;    

	
end
