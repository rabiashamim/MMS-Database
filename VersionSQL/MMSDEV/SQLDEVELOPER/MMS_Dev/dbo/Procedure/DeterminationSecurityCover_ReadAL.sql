/****** Object:  Procedure [dbo].[DeterminationSecurityCover_ReadAL]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  ALINA JAVED
-- CREATE date: 19 June 2023
-- Description: 
-- ============================================= 
--exec DeterminationSecurityCover_Read @pSoFileMasterId=1088,@pPageSize=0,@pPageNumber=1
--exec DeterminationSecurityCover_Read @pSoFileMasterId=1088
--exec DeterminationSecurityCover_Read @pSoFileMasterId=1089,@pPageSize=10,@pPageNumber=1
CREATE   PROCEDURE dbo.DeterminationSecurityCover_ReadAL @pSoFileMasterId DECIMAL(18, 0)
, @pUserId INT = 1
, @pPageNumber INT =NULL
, @pPageSize INT = NULL
,@pcontracttype NVARCHAR(MAX) = NULL
, @pYear NVARCHAR(MAX) = NULL
, @pBuyerID NVARCHAR(MAX) = NULL
, @pSellerID NVARCHAR(MAX) = NULL
, @pIsValid NVARCHAR(MAX) = NULL      
, @pMessage NVARCHAR(MAX) = NULL  
, @pMonth VARCHAR(MAX) = NULL 
, @pBName NVARCHAR(MAX) = NULL
, @pSName NVARCHAR(MAX) = NULL
, @pGDisProMon NVARCHAR(MAX) = NULL
, @pLoadProB NVARCHAR(MAX) = NULL
, @pFQC NVARCHAR(MAX) = NULL
, @pMonAvgMP NVARCHAR(MAX) = NULL
, @pDSP NVARCHAR(MAX) = NULL
, @pLV NVARCHAR(MAX) = NULL
,@pLPAG nvarchar(max)= null
,@pExpImbS nvarchar(max)= null
,@pExpImB nvarchar(max) =null
,@pExpImbMonS nvarchar(max) =null
,@pExpImbMonB nvarchar(max) =null

AS
BEGIN

/*********************************************************************************
*********************************************************************************
*********************************************************************************/
	DECLARE @vStatus VARCHAR(3);
	SELECT
		@vStatus =
		LuStatus_Code
	FROM MtSOFileMaster
	WHERE MtSOFileMaster_Id = @pSoFileMasterId

/*********************************************************************************
****************************From Interface **************************************
*********************************************************************************/

	IF (@vStatus = 'UPL')
	BEGIN
		WITH CTE_InterfaceData
		AS
		(SELECT
				MTDeterminationofSecurityCover_Id 
			   , ROW_NUMBER() OVER (ORDER BY MTDeterminationofSecurityCover_Interface_Year,MTDeterminationofSecurityCover_Interface_Buyer_Id,MTDeterminationofSecurityCover_Interface_Seller_Id, MTDeterminationofSecurityCover_Interface_RowNumber)    AS RowNumber
			   ,[MtSOFileMaster_Id]
			   ,[MTDeterminationofSecurityCover_Interface_ContractType]
			   ,MTDeterminationofSecurityCover_Interface_Buyer_Id
			   ,MTDeterminationofSecurityCover_Interface_Seller_Id
			   ,MTDeterminationofSecurityCover_Interface_Year
			   ,MTDeterminationofSecurityCover_Interface_Month
			   ,[MTDeterminationofSecurityCover_Interface_DSP]
			   ,[MTDeterminationofSecurityCover_Interface_LineVoltage]
			   ,MTDeterminationofSecurityCover_Interface_GeneratorDispatchProfileforMonth_MWh
			   ,[MTDeterminationofSecurityCover_Interface_LoadProfileBuyer]
			   ,MTDeterminationofSecurityCover_Interface_FixedQtyContract
			   ,[MTDeterminationofSecurityCover_Interface_MonthlyAvgMarginalPrice] 			   
			   ,[MTDeterminationofSecurityCover_Interface_IsValid] 
			   ,[MTDeterminationofSecurityCover_Interface_Message] 

			FROM [dbo].[MTDeterminationofSecurityCover_Interface]
			WHERE MtSOFileMaster_Id = @pSoFileMasterId
			AND (@pcontracttype IS NULL
			OR MTDeterminationofSecurityCover_Interface_ContractType = @pcontracttype)	
			AND (@pSellerID IS NULL
			OR MTDeterminationofSecurityCover_Interface_Seller_Id = @pSellerID)
			AND (@pBuyerID IS NULL
			OR MTDeterminationofSecurityCover_Interface_Buyer_Id = @pBuyerID)					
			AND (@pMonth IS NULL
			OR MTDeterminationofSecurityCover_Interface_Month = @pMonth)
			AND (@pDSP IS NULL
			OR [MTDeterminationofSecurityCover_Interface_DSP] = @pDSP)
			AND (@pLV IS NULL
			OR [MTDeterminationofSecurityCover_Interface_LineVoltage] = @pLV)
			AND (@pGDisProMon IS NULL
			OR MTDeterminationofSecurityCover_Interface_GeneratorDispatchProfileforMonth_MWh = @pGDisProMon)
			AND (@pLoadProB IS NULL
			OR [MTDeterminationofSecurityCover_Interface_LoadProfileBuyer] = @pLoadProB)
				AND (@pFQC IS NULL
			OR MTDeterminationofSecurityCover_Interface_FixedQtyContract = @pFQC)
			AND (@pIsValid IS NULL
			OR [MTDeterminationofSecurityCover_Interface_IsValid] = @pIsValid)								
			)
						
			SELECT
			* INTO #tempDetSC_Int
		FROM CTE_InterfaceData 
	

		SELECT
	*
FROM #tempDetSC_Int TC
WHERE (RowNumber > ((@pPageNumber - 1) * @pPageSize)
		AND RowNumber <= (@pPageNumber * @pPageSize))
		ORDER BY RowNumber

SELECT
	COUNT(1) AS FilteredRows
FROM #tempDetSC_Int TC;

	END
/*********************************************************************************
****************************From Operational ************************************
*********************************************************************************/
	ELSE
	BEGIN
		WITH CTE_InterfaceData
		AS
		(SELECT
				[MTDeterminationSecurityCover_Id]
			    ,ROW_NUMBER() OVER (ORDER BY [MTDeterminationSecurityCover_Year],[MTDeterminationSecurityCover_BuyerID],[MTDeterminationSecurityCover_SellerID], [MTDeterminationSecurityCover_RowNumber])    AS RowNumber
			   ,[MtSOFileMaster_Id]
			   ,CASE
					WHEN MTDeterminationofSecurityCover_ContractTypeID = 1 THEN 'Generation Following' 
					WHEN MTDeterminationofSecurityCover_ContractTypeID =2 THEN 'Load Following'
					WHEN MTDeterminationofSecurityCover_ContractTypeID =3 THEN 'Fixed Quantity'
				END ContractType 
			   ,[MTDeterminationSecurityCover_BuyerID]
			   ,[MTDeterminationSecurityCover_SellerID]
			   ,[MTDeterminationSecurityCover_Year]
			   ,[MTDeterminationSecurityCover_Month] 
				,[MTDeterminationSecurityCover_DSP] 
				,[MTDeterminationSecurityCover_LineVoltage] 
				,[MTDeterminationSecurityCover_GeneratorDispatchProfileforMonth]  
				,[MTDeterminationSecurityCover_LoadProfileBuyer] 
				,[MTDeterminationSecurityCover_FixedQtyContract]  
				,[MTDeterminationSecurityCover_MonthlyAvgMarginalPrice]  
				,[MTDeterminationSecurityCover_LoadProfileAfterGrossUpT&DLosses]  
				,[MTDeterminationSecurityCover_ExpectedImbalanceMonthlySeller]  
				,[MTDeterminationSecurityCover_ExpectedImbalanceMonthlyBuyer]  
				,[MTDeterminationSecurityCover_ExpectedImbalanceSeller]  
				,[MTDeterminationSecurityCover_ExpectedImbalanceBuyer]  
				,(SELECT
							PR.MtPartyRegisteration_Name
						FROM MtPartyRegisteration PR
						WHERE PR.MtPartyRegisteration_Id = [MTDeterminationSecurityCover_BuyerID])
					AS BuyerName
				   ,(SELECT
							PR.MtPartyRegisteration_Name
						FROM MtPartyRegisteration PR
						WHERE PR.MtPartyRegisteration_Id = [MTDeterminationSecurityCover_SellerID])
					AS SellerName
				,MTDeterminationSecurityCoverSummary_Seller_SC
				,MTDeterminationSecurityCoverSummary_Seller_SGC
				,MTDeterminationSecurityCoverSummary_Seller_TaxIncSC
				,MTDeterminationSecurityCoverSummary_Seller_SGCTaxInc
				,MTDeterminationSecurityCoverSummary_Buyer_SC
				,MTDeterminationSecurityCoverSummary_Buyer_SGC
				,MTDeterminationSecurityCoverSummary_Buyer_TaxIncSC
				,MTDeterminationSecurityCoverSummary_Buyer_SGCTaxInc,
				(select RuReferenceValue_Value 
				from RuReferenceValue where SrReferenceType_Id=1018) AS Factor				
			FROM [dbo].[MTDeterminationSecurityCover] inner join MTDeterminationSecurityCoverSummary DSCS
			on DSCS.MtSofileMasterId=MTDeterminationSecurityCover.MtSOFileMaster_Id
			WHERE [dbo].[MTDeterminationSecurityCover].MtSOFileMaster_Id = @pSoFileMasterId
			AND (@pYear IS NULL
			OR [MTDeterminationSecurityCover_Year] = @pYear)
			AND (@pMonth IS NULL
			OR [MTDeterminationSecurityCover_Month] = @pMonth)
			AND (@pBuyerID IS NULL
			OR [MTDeterminationSecurityCover_BuyerID] = @pBuyerID)
			AND (@pSellerID IS NULL
			OR [MTDeterminationSecurityCover_SellerID] = @pSellerID)
			AND (@pDSP IS NULL
			OR [MTDeterminationSecurityCover_DSP] = @pDSP)
			AND (@pLV IS NULL
			OR [MTDeterminationSecurityCover_LineVoltage] = @pLV)
			AND (@pGDisProMon IS NULL
			OR [MTDeterminationSecurityCover_GeneratorDispatchProfileforMonth] = @pGDisProMon)
			AND (@pLoadProB IS NULL
			OR [MTDeterminationSecurityCover_LoadProfileBuyer] = @pLoadProB)
			AND (@pFQC IS NULL
			OR [MTDeterminationSecurityCover_FixedQtyContract] = @pFQC)
			AND (@pMonAvgMP IS NULL
			OR [MTDeterminationSecurityCover_MonthlyAvgMarginalPrice] = @pMonAvgMP)			
			AND (@pLPAG IS NULL
			OR floor([MTDeterminationSecurityCover_LoadProfileAfterGrossUpT&DLosses] ) =floor(cast(@pLPAG as decimal(28,13))))
			AND (@pExpImbMonS IS NULL
			OR floor([MTDeterminationSecurityCover_ExpectedImbalanceMonthlySeller]) =floor(cast(@pExpImbMonS as decimal(28,13))))
			AND (@pExpImbMonB IS NULL
			OR floor([MTDeterminationSecurityCover_ExpectedImbalanceMonthlyBuyer]) =floor(cast(@pExpImbMonB as decimal(28,13))))
			AND (@pExpImbS IS NULL
			OR floor([MTDeterminationSecurityCover_ExpectedImbalanceSeller]) =floor(cast(@pExpImbS as decimal(28,13))))
			AND (@pExpImB IS NULL
			OR floor([MTDeterminationSecurityCover_ExpectedImbalanceBuyer]) =floor(cast(@pExpImB as decimal(28,13))))
			AND (@pSName IS NULL
				OR (SELECT
							PR.MtPartyRegisteration_Name
						FROM MtPartyRegisteration PR
						WHERE PR.MtPartyRegisteration_Id = [MTDeterminationSecurityCover_SellerID]
		AND ISNULL(PR.isDeleted, 0) = 0)
				LIKE '%' + @pSName + '%')
			AND (@pBName IS NULL
				OR (SELECT
							PR.MtPartyRegisteration_Name
						FROM MtPartyRegisteration PR
						WHERE PR.MtPartyRegisteration_Id = [MTDeterminationSecurityCover_BuyerID]
		AND ISNULL(PR.isDeleted, 0) = 0)
				LIKE '%' + @pBName + '%')	

			)

			SELECT
			* INTO #tempDetSC
		FROM CTE_InterfaceData 

		
		 SELECT  
    *  
   FROM #tempDetSC TC  
   WHERE (RowNumber > ((@pPageNumber - 1) * @pPageSize)  
   AND RowNumber <= (@pPageNumber * @pPageSize))  
   ORDER BY RowNumber ASC  
  
   SELECT  
    COUNT(1) AS FilteredRows  
   FROM #tempDetSC TC; 


	END

DROP TABLE IF EXISTS #tempDetSC_Int;
DROP TABLE IF EXISTS #tempDetSC;
/*********************************************************************************
*********************************************************************************
*********************************************************************************/
  

END
