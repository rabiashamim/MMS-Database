/****** Object:  Procedure [dbo].[Insert_DeterminationSecurityCover]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Alina Javed | Ali Imran
-- CREATE date: 20 June 2023
-- Description: 
-- ============================================= 
-- EXECUTE [Insert_DeterminationSecurityCover] @pMtSOFileMaster_Id=1084
CREATE PROCEDURE dbo.Insert_DeterminationSecurityCover @pMtSOFileMaster_Id DECIMAL(18, 0), @pUserId INT            
, @pIsUseForSettlement BIT
AS
BEGIN

  DECLARE @value VARCHAR(max),
		  @value1 VARCHAR(max),
		  @value2 VARCHAR(max),
		  @value3 VARCHAR(max);
  --Tax % for SC
-- Call the function and store the result in the variable
SET @value = [dbo].[GetValueFromReference]('Factor for incorporating losses')
set @value1 = [dbo].[GetValueFromReference]('Tax % for SC')
set @value2 = [dbo].[GetValueFromReference]('SGC Factor')
set @value3 = [dbo].[GetValueFromReference]('Tax % for SGC')

IF @value IS NULL OR @value1 is null  OR @value2 is null OR @value3 is null
BEGIN
   DECLARE @errorMessage VARCHAR(100) = 'Configurations required for: '
    IF @value IS NULL
        SET @errorMessage = @errorMessage + 'Factor for incorporating losses'
    IF @value1 IS NULL
        SET @errorMessage = @errorMessage + 'Tax % for SC'
    IF @value2 IS NULL
        SET @errorMessage = @errorMessage + 'SGC Factor'
    IF @value3 IS NULL
        SET @errorMessage = @errorMessage + 'Tax % for SGC'
    
    RAISERROR(@errorMessage, 16, 1)
END

else
begin
	IF NOT EXISTS (SELECT TOP 1
				1
			FROM [MTDeterminationSecurityCover]
			WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id
			AND MTDeterminationSecurityCover_IsDeleted = 0)
	BEGIN
		INSERT INTO [dbo].[MTDeterminationSecurityCover] ([MTDeterminationSecurityCover_RowNumber]
		, [MtSOFileMaster_Id]
		, [MTDeterminationofSecurityCover_ContractTypeID]
		, [MTDeterminationSecurityCover_BuyerID]
		, [MTDeterminationSecurityCover_SellerID]
		, [MTDeterminationSecurityCover_Year]
		, [MTDeterminationSecurityCover_Month]
		, [MTDeterminationSecurityCover_DSP]
		, [MTDeterminationSecurityCover_LineVoltage]
		, [MTDeterminationSecurityCover_GeneratorDispatchProfileforMonth]
		, [MTDeterminationSecurityCover_LoadProfileBuyer]
		, [MTDeterminationSecurityCover_FixedQtyContract]
		, [MTDeterminationSecurityCover_MonthlyAvgMarginalPrice]
		, [MTDeterminationSecurityCover_CreatedOn])
			SELECT
				MTDeterminationofSecurityCover_Interface_RowNumber
			   ,MtSOFileMaster_Id
			   ,CASE
					WHEN MTDeterminationofSecurityCover_Interface_ContractType IN ('Generation Following', 'Generation Following Supply Contract') THEN 1
					WHEN MTDeterminationofSecurityCover_Interface_ContractType IN ('Load Following', 'Load Following Supply Contract') THEN 2
					WHEN MTDeterminationofSecurityCover_Interface_ContractType IN ('Fixed Quantity', 'Financial Supply Contract with Fixed Quantities') THEN 3
				END
			   ,MTDeterminationofSecurityCover_Interface_Buyer_Id
			   ,MTDeterminationofSecurityCover_Interface_Seller_Id
			   ,MTDeterminationofSecurityCover_Interface_Year
			   ,MTDeterminationofSecurityCover_Interface_Month
			   ,MTDeterminationofSecurityCover_Interface_DSP
			   ,MTDeterminationofSecurityCover_Interface_LineVoltage
			   ,MTDeterminationofSecurityCover_Interface_GeneratorDispatchProfileforMonth_MWh
			   ,MTDeterminationofSecurityCover_Interface_LoadProfileBuyer
			   , TRY_CONVERT(decimal(18, 2), MTDeterminationofSecurityCover_Interface_FixedQtyContract)
			   ,[MTDeterminationofSecurityCover_Interface_MonthlyAvgMarginalPrice]
			   ,GETDATE()
			FROM [dbo].[MTDeterminationofSecurityCover_Interface]
			WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id


		UPDATE DSC
		set [MTDeterminationSecurityCover_LoadProfileAfterGrossUpT&DLosses]=
		MTDeterminationSecurityCover_LoadProfileBuyer * 1.09
		--CASE
  --      WHEN (MTDeterminationSecurityCover_LoadProfileBuyer * 1.09) - FLOOR(MTDeterminationSecurityCover_LoadProfileBuyer * 1.09) > 0.5
  --      THEN CEILING(MTDeterminationSecurityCover_LoadProfileBuyer * 1.09)
  --      ELSE FLOOR(MTDeterminationSecurityCover_LoadProfileBuyer * 1.09)
		--END
		FROM MTDeterminationSecurityCover DSC
		WHERE DSC.MtSOFileMaster_Id = @pMtSOFileMaster_Id
		AND DSC.MTDeterminationSecurityCover_IsDeleted = 0

		UPDATE DSC
		--SELECT
		SET MTDeterminationSecurityCover_ExpectedImbalanceMonthlySeller =
			CASE
				WHEN MTDeterminationofSecurityCover_ContractTypeID = 3 THEN -- Fixed Contract
					MTDeterminationSecurityCover_GeneratorDispatchProfileforMonth - MTDeterminationSecurityCover_FixedQtyContract
				WHEN MTDeterminationofSecurityCover_ContractTypeID = 2 THEN  -- Load 
				MTDeterminationSecurityCover_GeneratorDispatchProfileforMonth -
					[MTDeterminationSecurityCover_LoadProfileAfterGrossUpT&DLosses]	
					END
		   ,MTDeterminationSecurityCover_ExpectedImbalanceMonthlyBuyer =
			CASE
				WHEN MTDeterminationofSecurityCover_ContractTypeID = 3 --fixed contract
				--THEN MTDeterminationSecurityCover_LoadProfileBuyer - MTDeterminationSecurityCover_FixedQtyContract
				Then [MTDeterminationSecurityCover_LoadProfileAfterGrossUpT&DLosses] - MTDeterminationSecurityCover_FixedQtyContract
				WHEN MTDeterminationofSecurityCover_ContractTypeID = 1 -- Generation
				THEN MTDeterminationSecurityCover_GeneratorDispatchProfileforMonth -[MTDeterminationSecurityCover_LoadProfileAfterGrossUpT&DLosses]
			END

		FROM MTDeterminationSecurityCover DSC
		WHERE DSC.MtSOFileMaster_Id = @pMtSOFileMaster_Id
		AND DSC.MTDeterminationSecurityCover_IsDeleted = 0


		UPDATE DSC
		--SELECT
		SET MTDeterminationSecurityCover_ExpectedImbalanceSeller =
		CASE WHEN MTDeterminationofSecurityCover_ContractTypeID in (2,3) --Fixed Contract, load following
		THEN
			DSC.MTDeterminationSecurityCover_MonthlyAvgMarginalPrice *
			MTDeterminationSecurityCover_ExpectedImbalanceMonthlySeller *
			[dbo].[GetValueFromReference]('Factor for incorporating losses')
			END
		   ,MTDeterminationSecurityCover_ExpectedImbalanceBuyer =
			CASE
				WHEN MTDeterminationofSecurityCover_ContractTypeID in (3,1) THEN -- Fixed Contract, Generation following
					DSC.MTDeterminationSecurityCover_MonthlyAvgMarginalPrice *
					DSC.MTDeterminationSecurityCover_ExpectedImbalanceMonthlyBuyer *
				[dbo].[GetValueFromReference]('Factor for incorporating losses')
	            
				--WHEN MTDeterminationofSecurityCover_ContractTypeID = 1 THEN -- Fixed Contract
				--	DSC.MTDeterminationSecurityCover_MonthlyAvgMarginalPrice *
				--	DSC.MTDeterminationSecurityCover_ExpectedImbalanceMonthlyBuyer *
				--[dbo].[GetValueFromReference]('Factor for incorporating losses')
			END

		FROM MTDeterminationSecurityCover DSC
		WHERE DSC.MtSOFileMaster_Id = @pMtSOFileMaster_Id
		AND DSC.MTDeterminationSecurityCover_IsDeleted = 0;

   END



		/*******************************************************************************************************
		Insert in summary tax details.
		********************************************************************************************************/

		IF NOT EXISTS (SELECT TOP 1
					1
				FROM [MTDeterminationSecurityCoverSummary]
				WHERE [MtSofileMasterId] = @pMtSOFileMaster_Id
				AND MTDeterminationSecurityCoverSummary_IsDeleted = 0)
		BEGIN
			INSERT INTO [dbo].[MTDeterminationSecurityCoverSummary] ([MtSofileMasterId]
			, [MTDeterminationSecurityCoverSummary_Seller_SC]
			, [MTDeterminationSecurityCoverSummary_Seller_SGC]
			, [MTDeterminationSecurityCoverSummary_Seller_TaxIncSC]
			, [MTDeterminationSecurityCoverSummary_Seller_SGCTaxInc]
			, [MTDeterminationSecurityCoverSummary_Buyer_SC]
			, [MTDeterminationSecurityCoverSummary_Buyer_SGC]
			, [MTDeterminationSecurityCoverSummary_Buyer_TaxIncSC]
			, [MTDeterminationSecurityCoverSummary_Buyer_SGCTaxInc]
			, [MTDeterminationSecurityCoverSummary_CreatedBy])

				SELECT
					@pMtSOFileMaster_Id,
				    MAX(MTDeterminationSecurityCover_ExpectedImbalanceSeller) AS Seller_SC,
					MAX(MTDeterminationSecurityCover_ExpectedImbalanceSeller) * 1.5 AS Seller_SGC,
					MAX(MTDeterminationSecurityCover_ExpectedImbalanceSeller) * 1.18 AS Seller_TaxIncSC,
					MAX((MTDeterminationSecurityCover_ExpectedImbalanceSeller) * 1.5) * 1.18 AS Seller_SGCTaxInc,
					MAX(MTDeterminationSecurityCover_ExpectedImbalanceBuyer) AS Buyer_SC,
					MAX(MTDeterminationSecurityCover_ExpectedImbalanceBuyer) * 1.5 AS Buyer_SGC,
					MAX(MTDeterminationSecurityCover_ExpectedImbalanceBuyer) * 1.18 AS Buyer_TaxIncSC,
					MAX(MTDeterminationSecurityCover_ExpectedImbalanceBuyer) * 1.5 * 1.18 AS Buyer_SGCTaxInc,
				   1

				FROM MTDeterminationSecurityCover
				WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id
		END


UPDATE MtSOFileMaster
SET LuStatus_Code = 'DRAF'
   ,MtSOFileMaster_IsUseForSettlement = @pIsUseForSettlement
WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id;

DELETE FROM MTDeterminationofSecurityCover_Interface
WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id;

	END


END
