/****** Object:  Procedure [dbo].[SOBilateralContractDataValidation]    Committed by VersionSQL https://www.versionsql.com ******/

    
CREATE PROCEDURE dbo.SOBilateralContractDataValidation @MtSOFileMaster_Id DECIMAL(18, 0),
@userID DECIMAL(18, 0)
AS
BEGIN

	DECLARE @month VARCHAR(MAX)
		   ,@year VARCHAR(MAX)

	SELECT
		@month = LuAccountingMonth_Month
	   ,@year = LuAccountingMonth_Year
	FROM LuAccountingMonth
	WHERE LuAccountingMonth_Id = (SELECT
			LuAccountingMonth_Id
		FROM MtSOFileMaster
		WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id)


	UPDATE MBI
	SET MBI.MtBilateralContract_Message = ISNULL(MtBilateralContract_Message + ',', '')

	+
	CASE
		WHEN SrContractType_Id = 1 AND
			MBI.MtBilateralContract_MeterOwnerMPId <> MBI.MtBilateralContract_SellerMPId THEN 'Value of Meter Owner will always be of Seller. '
		ELSE ''
	END

	+
	CASE
		WHEN (SrContractType_Id IN (1, 2)) AND
			MtBilateralContract_Percentage IS NULL THEN 'Percentage value is must. '
		ELSE ''
	END

	+
	CASE
		WHEN (SrContractType_Id IN (1, 2)) AND
			(MtBilateralContract_ContractedQuantity IS NOT NULL AND
			LEN(RTRIM(ISNULL(MtBilateralContract_ContractedQuantity, ''))) > 0) THEN 'Contracted quantity should be empty. '
		ELSE ''
	END

	+
	CASE
		WHEN (SrContractType_Id IN (1, 2, 3)) AND
			(MtBilateralContract_CapQuantity IS NOT NULL AND
			LEN(RTRIM(ISNULL(MtBilateralContract_CapQuantity, ''))) > 0) THEN 'Cap Quantity should be empty. '
		ELSE ''
	END

	--+ case when (SrContractType_Id IN (1,2,3)) and (MtBilateralContract_DistributionLosses IS NOT NULL AND LEN(RTRIM(ISNULL(MtBilateralContract_DistributionLosses, ''))) > 0) then 'Distribution Losses should be empty. ' else '' end  

	--+ case when (SrContractType_Id IN (1,2,3)) and (MtBilateralContract_TransmissionLoss is not NULL AND  LEN(RTRIM(ISNULL(MtBilateralContract_TransmissionLoss, ''))) > 0) then 'Transmission loss should be empty. ' else '' end  

	+
	CASE
		WHEN SrContractType_Id = 2 AND
			MtBilateralContract_MeterOwnerMPId <> MtBilateralContract_BuyerMPId THEN 'Value of Meter Owner will always be of Buyer. '
		ELSE ''
	END

	--+ case when SrContractType_Id = 3 and MtBilateralContract_MeterOwnerMPId is not NULL AND   LEN(RTRIM(ISNULL(MtBilateralContract_MeterOwnerMPId, ''))) > 0 then 'Meter owner ID should be empty for Fixed Contract. ' else '' end  

	--+ case when SrContractType_Id = 3 and (MtBilateralContract_CDPID is not null AND   LEN(RTRIM(ISNULL(MtBilateralContract_CDPID, ''))) > 0)then 'CDP ID should be empty for Fixed Contract. ' else '' end  

	+
	CASE
		WHEN SrContractType_Id = 3 AND
			(MtBilateralContract_Percentage IS NOT NULL AND
			LEN(RTRIM(CAST(ISNULL(MtBilateralContract_Percentage, 0) AS DECIMAL(18, 5)))) > 0) THEN 'Percentage should be empty for Fixed Contract. '
		ELSE ''
	END

	+
	CASE
		WHEN SrContractType_Id = 3 AND
			MtBilateralContract_ContractedQuantity IS NULL THEN 'Contracted Quantity value is must. '
		ELSE ''
	END

	+
	CASE
		WHEN SrContractType_Id = 4 AND
			((MtBilateralContract_Percentage IS NULL AND
			MtBilateralContract_ContractedQuantity IS NULL) OR
			(MtBilateralContract_Percentage IS NOT NULL AND
			MtBilateralContract_ContractedQuantity IS NOT NULL)) THEN 'Either Percentage value or Contracted Quantity is must, Both columns cannot have values at a same time. '
		ELSE ''
	END

	+
	CASE
		WHEN SrContractType_Id = 4 AND
			MtBilateralContract_DistributionLosses IS NULL THEN 'Distribution loss is mandatory. '
		ELSE ''
	END

	+
	CASE
		WHEN SrContractType_Id = 4 AND
			MtBilateralContract_DistributionLosses IS NOT NULL AND
			MtBilateralContract_DistributionLosses NOT IN ('Buyer', 'Seller') THEN 'Distribution loss must be buyer or seller. '
		ELSE ''
	END

	--+ case when SrContractType_Id = 4 and MtBilateralContract_TransmissionLoss is null then 'Transmission loss is mandatory. ' else '' end  

	--+ case when SrContractType_Id = 4 and MtBilateralContract_TransmissionLoss is not null  and MtBilateralContract_TransmissionLoss not in ('Buyer','Seller') then 'Transmission loss must be buyer or seller. ' else '' end  

	+
	CASE
		WHEN MtBilateralContract_SellerMPId IS NULL THEN 'Seller ID is missing. '
		ELSE ''
	END

	+
	CASE
		WHEN MtBilateralContract_SellerMPId IS NOT NULL AND
			MtBilateralContract_SellerMPId NOT IN (SELECT
					P.MtPartyRegisteration_Id
				FROM dbo.MtPartyRegisteration P
				WHERE ISNULL(P.isDeleted, 0) = 0) THEN 'Seller ID is invalid. '
		ELSE ''
	END

	+
	CASE
		WHEN MtBilateralContract_BuyerMPId IS NULL THEN 'Buyer ID is missing. '
		ELSE ''
	END

	+
	CASE
		WHEN MtBilateralContract_BuyerMPId IS NOT NULL AND
			MtBilateralContract_BuyerMPId NOT IN (SELECT
					P.MtPartyRegisteration_Id
				FROM dbo.MtPartyRegisteration P
				WHERE ISNULL(P.isDeleted, 0) = 0) THEN 'Buyer ID is invalid. '
		ELSE ''
	END

	+
	CASE
		WHEN (MBI.SrContractType_Id <> 3 AND
			MtBilateralContract_CDPID IS NULL) THEN 'CDP ID is missing. '
		ELSE ''
	END

	+
	CASE
		WHEN (MBI.SrContractType_Id <> 3 AND
			MtBilateralContract_CDPID IS NOT NULL AND
			MtBilateralContract_CDPID NOT IN (SELECT
					rc.RuCDPDetail_CdpId
				FROM RuCDPDetail rc)
			) THEN 'Invalid CDP ID. '
		ELSE ''
	END

	+
	CASE
		WHEN MtBilateralContract_AncillaryServices IS NOT NULL AND
			MtBilateralContract_AncillaryServices <> '' AND
			MtBilateralContract_AncillaryServices NOT IN ('Buyer', 'Seller') THEN 'Ancillary can only be buyer or seller'
		ELSE ''
	END

	--+ CASE WHEN MBI.MtBilateralContract_Date IS NULL THEN 'Date is missing. ' ELSE '' END   

	+
	CASE
		WHEN ISDATE(MtBilateralContract_Date) = 0 THEN 'Date is not valid. '
		ELSE CASE
				WHEN DATEPART(MONTH, MtBilateralContract_Date) = @month THEN ''
				ELSE 'Date should be of selected settlement month only. '
			END
			+
			CASE
				WHEN DATEPART(YEAR, MtBilateralContract_Date) = @year THEN ''
				ELSE 'Date should be of selected settlement year only. '
			END
	END

	+
	CASE
		WHEN ISNUMERIC(MBI.MtBilateralContract_Hour) = 0 THEN 'Hour is missing. '
		ELSE ''
	END

	+
	CASE
		WHEN ISNULL(MBI.MtBilateralContract_Hour, 0) < 0 OR
			ISNULL(MBI.MtBilateralContract_Hour, 0) > 23 THEN 'Hour must be between 0-23. '
		ELSE ''
	END

	+
	CASE
		WHEN (MBI.MtBilateralContract_ContractType IS NULL) THEN 'Contract Type is missing. '
		ELSE ''
	END

	+
	CASE
		WHEN SrContractType_Id <> 3 AND
			MBI.MtBilateralContract_MeterOwnerMPId IS NULL THEN 'Meter owner Id is missing. '
		ELSE ''
	END

	+
	CASE
		WHEN MtBilateralContract_Percentage IS NOT NULL AND
			(CAST(MBI.MtBilateralContract_Percentage AS DECIMAL(18, 5)) < 0 OR
			CAST(MBI.MtBilateralContract_Percentage AS DECIMAL(18, 5)) > 100) THEN 'Invalid Percentage. '
		ELSE ''
	END

	+
	CASE
		WHEN (MBI.SrContractType_Id IN (1, 2)) AND
			MBI.MtBilateralContract_Percentage IS NULL THEN 'Percentage is missing. '
		ELSE ''
	END

	+
	CASE
		WHEN SellerSrCategory_Code IS NULL THEN 'Seller category code is missing. '
		ELSE ''
	END

	+
	CASE
		WHEN SellerSrCategory_Code IS NOT NULL AND
			SellerSrCategory_Code NOT IN (SELECT
					sc.SrCategory_Code
				FROM SrCategory sc) THEN 'Invalid Seller Category Code. '
		ELSE ''
	END

	+
	CASE
		WHEN BuyerSrCategory_Code IS NULL THEN 'Buyer category code is missing. '
		ELSE ''
	END

	+
	CASE
		WHEN BuyerSrCategory_Code IS NOT NULL AND
			BuyerSrCategory_Code NOT IN (SELECT
					sc.SrCategory_Code
				FROM SrCategory sc) THEN 'Invalid Buyer Category Code. '
		ELSE ''
	END

	-- + case when MtBilateralContract_ContractType is null then 'Contract type is missing. ' else '' end  

	+
	CASE
		WHEN SrContractType_Id IS NOT NULL AND
			MtBilateralContract_ContractType IS NOT NULL AND
			SrContractType_Id = 0 THEN 'Contract type other than standard contract types. '
		ELSE ''
	END


	FROM MtBilateralContract_Interface MBI
	WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id
	AND ISNULL(MtBilateralContract_Deleted, 0) = 0;



	UPDATE MtBilateralContract_Interface
	SET MtBilateralContract_IsValid = 0
	WHERE ISNULL(MtBilateralContract_Message, '') <> ''
	AND ISNULL(MtBilateralContract_Deleted, 0) = 0

	IF EXISTS (SELECT
				1
			FROM MtBilateralContract_Interface
			WHERE MtBilateralContract_IsValid = 0
			AND MtSOFileMaster_Id = @MtSOFileMaster_Id)
	BEGIN
		;
		WITH CTE
		AS
		(SELECT
				MtBilateralContract_RowNumber
			   ,MtBilateralContract_IsValid
			   ,MtBilateralContract_Id
			   ,ROW_NUMBER() OVER (ORDER BY MtBilateralContract_IsValid, MtBilateralContract_RowNumber) AS MtBilateralContract_RowNumber_new
			FROM MtBilateralContract_Interface
			WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id--    
		)

		UPDATE M
		SET MtBilateralContract_RowNumber = MtBilateralContract_RowNumber_new
		FROM MtBilateralContract_Interface M
		INNER JOIN CTE c
			ON c.MtBilateralContract_Id = M.MtBilateralContract_Id
		WHERE M.MtSOFileMaster_Id = @MtSOFileMaster_Id--MtSOFileMaster_Id=277    


	END




	DECLARE @vInvalidCount BIGINT = 0;

	SELECT
		@vInvalidCount = COUNT(1)
	FROM MtBilateralContract_Interface mbci
	WHERE mbci.MtSOFileMaster_Id = @MtSOFileMaster_Id
	AND ISNULL(mbci.MtBilateralContract_Deleted, 0) = 0
	AND mbci.MtBilateralContract_IsValid = 0

	DECLARE @vTotalRecords BIGINT = 0;

	SELECT
		@vTotalRecords = COUNT(1)
	FROM MtBilateralContract_Interface mbci
	WHERE mbci.MtSOFileMaster_Id = @MtSOFileMaster_Id
	AND ISNULL(mbci.MtBilateralContract_Deleted, 0) = 0;


	UPDATE MtSOFileMaster
	SET InvalidRecords = @vInvalidCount
	   ,TotalRecords = @vTotalRecords
	WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id

	SELECT
		@vInvalidCount
	   ,@vTotalRecords;


END
