/****** Object:  Procedure [dbo].[ValidateBilateralContractData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: June 27, 2022 
-- ALTER date: July 05, 2022   
-- Description: 
--              
-- ============================================= 

-- [dbo].[ValidateBilateralContractData] 200

CREATE PROCEDURE [dbo].[ValidateBilateralContractData](			 
			@SoFileMasterId decimal(18,0)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
/*
SELECT 
      [MtBilateralContract_Date]
      ,[MtBilateralContract_Hour]
      ,[MtBilateralContract_ContractId]
      ,[MtBilateralContract_SellerMPId]
      ,[MtBilateralContract_BuyerMPId]
      ,[MtBilateralContract_ContractType]      
      ,[MtBilateralContract_CDPID]
      ,[MtBilateralContract_AncillaryServices]
      ,[SrContractType_Id]
      ,[ContractSubType_Id]      
      ,[BuyerSrCategory_Code]
      ,[SellerSrCategory_Code]
      ,[MtBilateralContract_CongestedZoneID]
      
  FROM [MtBilateralContract] C WHERE C.MtBilateralContract_Deleted=0 
*/
DECLARE @COUNT_CONTRACT INT=0;
DECLARE @COUNT_NULL_DATE INT=0;
DECLARE @COUNT_NULL_HOUR INT=0;
DECLARE @COUNT_NULL_CONTRACT_ID INT=0;
DECLARE @COUNT_INVALID_SELLER_MP_ID INT=0;
DECLARE @COUNT_INVALID_BUYER_MP_ID INT=0;
DECLARE @COUNT_NULL_CONTRACT_TYPE INT=0;
DECLARE @COUNT_INVALID_CDP_ID INT=0;
DECLARE @COUNT_NULL_ANCILLARY_SERVICES INT=0;
DECLARE @COUNT_NULL_CONTRACT_TYPE_ID INT=0;
DECLARE @COUNT_NULL_CONTRACT_SUB_TYPE_ID INT=0;
DECLARE @COUNT_INVALID_BUYER_CATEGORY_CODE INT=0;
DECLARE @COUNT_INVALID_SELLER_CATEGORY_CODE INT=0;
DECLARE @COUNT_NULL_CONGESTED_ZONE_ID INT=0;
DECLARE @COUNT_CONTRACT_VIEW INT=0;
/*
1.4.6.	“Fixed Quantity Contract” without Contracted Quantity
*/
DECLARE @COUNT_FIXED_QUANTITY_CONTRACT_WITHOUT_CONTRACT_QUANTITY INT=0;
/*
1.4.7.	Percentage value missing for Load Following Contract
*/
DECLARE @COUNT_LOAD_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE INT=0;
/*
1.4.8.	Percentage value missing for Generation Following Contract
*/
DECLARE @COUNT_GENERATION_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE INT=0;

/*
1.4.9-A.	Invalid value in Percentage column of the Load Following Contract
*/
DECLARE @COUNT_LOAD_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE INT=0;
/*
1.4.9-B. Invalid value in Percentage column of the Generation Following Contract
*/
DECLARE @COUNT_GENERATION_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE INT=0;


        select @COUNT_CONTRACT = COUNT(1), 
        @COUNT_NULL_DATE=SUM(CASE WHEN C.MtBilateralContract_Date is null THEN 1 ELSE 0 END),
        @COUNT_NULL_HOUR=SUM(CASE WHEN C.MtBilateralContract_Hour is null THEN 1 ELSE 0 END),
@COUNT_NULL_CONTRACT_ID=SUM(CASE WHEN C.MtBilateralContract_ContractId is null THEN 1 ELSE 0 END),

@COUNT_NULL_CONTRACT_TYPE=SUM(CASE WHEN C.MtBilateralContract_ContractType is null THEN 1 ELSE 0 END),

@COUNT_NULL_ANCILLARY_SERVICES=SUM(CASE WHEN C.MtBilateralContract_AncillaryServices is null THEN 1 ELSE 0 END),
@COUNT_NULL_CONTRACT_TYPE_ID=SUM(CASE WHEN C.SrContractType_Id is null THEN 1 ELSE 0 END),
@COUNT_NULL_CONTRACT_SUB_TYPE_ID=SUM(CASE WHEN C.ContractSubType_Id is null THEN 1 ELSE 0 END),


@COUNT_FIXED_QUANTITY_CONTRACT_WITHOUT_CONTRACT_QUANTITY=SUM(CASE WHEN c.SrContractType_Id=3 and C.MtBilateralContract_ContractedQuantity is null THEN 1 ELSE 0 END),
@COUNT_LOAD_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE=SUM(CASE WHEN c.SrContractType_Id=2 and C.MtBilateralContract_Percentage is null THEN 1 ELSE 0 END),
@COUNT_LOAD_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE=SUM(CASE WHEN c.SrContractType_Id=2 and (C.MtBilateralContract_Percentage<=0 OR C.MtBilateralContract_Percentage>100) THEN 1 ELSE 0 END),
@COUNT_GENERATION_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE =SUM(CASE WHEN c.SrContractType_Id=1 and C.MtBilateralContract_Percentage is null THEN 1 ELSE 0 END),
@COUNT_GENERATION_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE=SUM(CASE WHEN c.SrContractType_Id=1 and (C.MtBilateralContract_Percentage<=0 OR C.MtBilateralContract_Percentage>100) THEN 1 ELSE 0 END)
        FROM [MtBilateralContract] C WHERE C.MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtBilateralContract_Deleted,0)=0 ;
 

select @COUNT_CONTRACT_VIEW = COUNT(1)
	    from dbo.Bme_ContractParties
	    WHERE MtSOFileMaster_Id=@SoFileMasterId;

---------------------
SET
@COUNT_INVALID_SELLER_MP_ID=	(SELECT 
			count(DISTINCT c.MtBilateralContract_ContractId )
        FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0  
			AND C.MtBilateralContract_SellerMPId NOT IN(select P.MtPartyRegisteration_Id from dbo.MtPartyRegisteration P WHERE ISNULL(P.isDeleted,0)=0));
SET @COUNT_INVALID_BUYER_MP_ID=(SELECT 
			count(DISTINCT c.MtBilateralContract_ContractId )
        FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0  
			AND C.MtBilateralContract_BuyerMPId NOT IN(select P.MtPartyRegisteration_Id from dbo.MtPartyRegisteration P WHERE ISNULL(P.isDeleted,0)=0));

SET @COUNT_INVALID_CDP_ID=(SELECT 
			COUNT(DISTINCT c.MtBilateralContract_ContractId)
		FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND C.MtBilateralContract_CDPID is NULL OR C.MtBilateralContract_CDPID NOT IN (
			SELECT rc.RuCDPDetail_CdpId FROM RuCDPDetail rc 
			));


SET @COUNT_INVALID_SELLER_CATEGORY_CODE=(
	SELECT 
			count (DISTINCT c.MtBilateralContract_ContractId)
		FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND  C.SellerSrCategory_Code is NULL OR C.SellerSrCategory_Code NOT IN (
			SELECT sc.SrCategory_Code FROM SrCategory sc
			)
)

SET @COUNT_INVALID_BUYER_CATEGORY_CODE = (	SELECT 
			count (DISTINCT c.MtBilateralContract_ContractId)
		FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND  C.BuyerSrCategory_Code is NULL OR C.BuyerSrCategory_Code NOT IN (
			SELECT sc.SrCategory_Code FROM SrCategory sc
			)
)
--------------------------------------        

    DECLARE @COUNT_CONTRACT_TYPE_MISSMATCH INT=0;
     --   select @COUNT_CONTRACT_TYPE_MISSMATCH = COUNT(1)
	    --from MtBilateralContract C WHERE MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtBilateralContract_Deleted,0)=0 
     --   AND  (SrContractType_Id is null  or SrContractType_Id not in(1,2,3,4) OR ContractSubType_Id is null or ContractSubType_Id not in(0,21,22,23,41,42));

	 
			SET @COUNT_CONTRACT_TYPE_MISSMATCH =( 	select COUNT(DISTINCT C.MtBilateralContract_ContractId)
	    from MtBilateralContract C WHERE MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtBilateralContract_Deleted,0)=0 
        AND  (SrContractType_Id is null  or SrContractType_Id not in(SELECT sct.SrContractType_Id FROM SrContractType sct) OR ContractSubType_Id is null or ContractSubType_Id not in(
		SELECT ssct.SrSubContractType FROM SrSubContractType ssct
		)
		OR C.SrContractType_Id NOT IN (
		SELECT 
			CASE
				WHEN sct.SrSubContractType IN (21,22,23) THEN 2
				WHEN sct.SrSubContractType IN (41,42) THEN 4
				 ELSE 0
			END AS contract_types
			FROM SrSubContractType sct
		)
		OR C.MtBilateralContract_ContractType IS NULL 
		OR c.MtBilateralContract_ContractType NOT IN (SELECT sct.SrContractType_Name FROM SrContractType sct)
		)    )

---------------------------------

    DECLARE @COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH INT=0;
        select @COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH = COUNT(1)
	    from MtBilateralContract C WHERE MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtBilateralContract_Deleted,0)=0 
        AND SellerSrCategory_Code not in(SELECT SrCategory_Code FROM dbo.SrCategory);

    DECLARE @COUNT_CONTRACT_BUYER_CATEGORY_CODE_MISSMATCH INT=0;
        select @COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH = COUNT(1)
	    from MtBilateralContract C WHERE  MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtBilateralContract_Deleted,0)=0 
        AND BuyerSrCategory_Code not in(SELECT SrCategory_Code FROM dbo.SrCategory);

DECLARE @COUNT_WITHIN_CONTRACT_MISSMATCH INT=0;

WITH CONTRACTS_CTE
AS
(
select distinct c.MtBilateralContract_ContractId, c.MtBilateralContract_SellerMPId, SellerSrCategory_Code,C.MtBilateralContract_BuyerMPId, C.BuyerSrCategory_Code,
c.SrContractType_Id,c.ContractSubType_Id            
from MtBilateralContract C 
WHERE  C.MtSOFileMaster_Id = @SoFileMasterId AND ISNULL(C.MtBilateralContract_Deleted,0)=0 
)
SELECT @COUNT_WITHIN_CONTRACT_MISSMATCH = COUNT(1)
FROM
( select MtBilateralContract_ContractId from CONTRACTS_CTE C
 GROUP BY c.MtBilateralContract_ContractId
 HAVING COUNT(1)>1) C;

--------------------------------------------



--SELECT @COUNT_CONTRACT as COUNT_CONTRACT,
--@COUNT_NULL_DATE as COUNT_NULL_DATE,
--@COUNT_NULL_HOUR as COUNT_NULL_HOUR,
--@COUNT_NULL_CONTRACT_ID as COUNT_NULL_CONTRACT_ID,
--@COUNT_NULL_SELLER_MP_ID as COUNT_NULL_SELLER_MP_ID,
--@COUNT_NULL_BUYER_MP_ID as COUNT_NULL_BUYER_MP_ID,
--@COUNT_NULL_CONTRACT_TYPE as COUNT_NULL_CONTRACT_TYPE,
--@COUNT_NULL_CONTRACT_SUB_TYPE_ID as COUNT_NULL_CONTRACT_SUB_TYPE_ID,
--@COUNT_NULL_BUYER_CATEGORY_CODE as COUNT_NULL_BUYER_CATEGORY_CODE,
--@COUNT_NULL_SELLER_CATEGORY_CODE as COUNT_NULL_SELLER_CATEGORY_CODE
--, @COUNT_CONTRACT - @COUNT_CONTRACT_VIEW as [COUNT_CONTRACT_PARTIES_MISSMATCH]        
--        , @COUNT_CONTRACT_TYPE_MISSMATCH as [COUNT_CONTRACT_TYPE_MISSMATCH]
--        , @COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH as [COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH]
--        , @COUNT_CONTRACT_BUYER_CATEGORY_CODE_MISSMATCH as [COUNT_CONTRACT_BUYER_CATEGORY_CODE_MISSMATCH]
--        , @COUNT_WITHIN_CONTRACT_MISSMATCH as [COUNT_WITHIN_CONTRACT_MISSMATCH]
--        ,@COUNT_FIXED_QUANTITY_CONTRACT_WITHOUT_CONTRACT_QUANTITY as COUNT_FIXED_QUANTITY_CONTRACT_WITHOUT_CONTRACT_QUANTITY
--        ,@COUNT_LOAD_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE as COUNT_LOAD_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE
--        ,@COUNT_LOAD_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE as COUNT_LOAD_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE
--        ,@COUNT_GENERATION_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE AS COUNT_GENERATION_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE
--        ,@COUNT_GENERATION_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE AS COUNT_GENERATION_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE;
	
    -----------------------------------------
    DECLARE @logMessage_missing_seller_id VARCHAR(MAX),
	@logMessage_missing_buyer_id VARCHAR(MAX),
	@logMessage_missing_cdp VARCHAR(MAX),
	@logMessage_missing_seller_cat VARCHAR(MAX),
	@logMessage_missing_buyer_cat VARCHAR(MAX),
	@logMessage_fixed_Quantity_without_contract_quantity VARCHAR(MAX),
	@logMessage_load_fol_contract_missing_percentage VARCHAR(MAX),
	@logMessage_load_fol_contract_invalid_percentage VARCHAR(MAX),
	@logMessage_gen_fol_contract_missing_percentage VARCHAR(MAX),
	@logMessage_gen_fol_contract_invalid_percentage VARCHAR(MAX),
	@logMessage_contract_type_other_than_standard VARCHAR(MAX),
	@BilateralContract_List NVARCHAR(MAX);


	IF(@COUNT_INVALID_SELLER_MP_ID > 0 )
	BEGIN
	SET @BilateralContract_List = NULL;

	WITH contracts_cte
	AS (
		SELECT DISTINCT C.MtBilateralContract_ContractId FROM MtBilateralContract C
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0  
			AND C.MtBilateralContract_SellerMPId NOT IN(select P.PartyRegisteration_Id from dbo.Bme_Parties P)
	)

	SELECT 
			@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
        FROM contracts_cte C ;

		SET @logMessage_missing_seller_id = 'Missing Total - ' + CAST(@COUNT_INVALID_SELLER_MP_ID AS NVARCHAR(MAX)) + ': Invalid or Missing Seller Id in Contract sheet: ' + @BilateralContract_List;
		
	END

	IF(@COUNT_INVALID_BUYER_MP_ID > 0)
	BEGIN 
	SET @BilateralContract_List = NULL;

	WITH contracts_cte
	AS (
		SELECT DISTINCT C.MtBilateralContract_ContractId FROM MtBilateralContract C
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0  
			AND C.MtBilateralContract_BuyerMPId NOT IN(select P.PartyRegisteration_Id from dbo.Bme_Parties P)
	)


	SELECT 
		@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
	FROM contracts_cte C ;

		SET @logMessage_missing_buyer_id ='Missing Total - ' +  CAST(@COUNT_INVALID_BUYER_MP_ID AS NVARCHAR(MAX)) + ': Invalid or Missing Buyer Id in Contract sheet: ' + @BilateralContract_List;
		
	END
	 
	IF(@COUNT_INVALID_CDP_ID > 0)
	BEGIN
		SET @BilateralContract_List = NULL;

		WITH contracts_cte
	AS (
		SELECT DISTINCT C.MtBilateralContract_ContractId FROM MtBilateralContract C
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND C.MtBilateralContract_CDPID is NULL OR C.MtBilateralContract_CDPID NOT IN (
			SELECT rc.RuCDPDetail_CdpId FROM RuCDPDetail rc 
			)
	)

		SELECT 
			@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
		FROM contracts_cte C ;
	

		SET @logMessage_missing_cdp = 'Missing Total - ' + CAST(@COUNT_INVALID_CDP_ID AS NVARCHAR(MAX)) + ': Invalid or Missing CDP Id in Contract sheet: ' + @BilateralContract_List;
		
	END

	IF(@COUNT_INVALID_SELLER_CATEGORY_CODE > 0)
	BEGIN
		SET @BilateralContract_List = NULL;

		WITH contracts_cte
		AS (
		SELECT 
			DISTINCT c.MtBilateralContract_ContractId
		FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND  C.SellerSrCategory_Code is NULL OR C.SellerSrCategory_Code NOT IN (
			SELECT sc.SrCategory_Code FROM SrCategory sc
			)
		)

		SELECT 
			@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
		FROM contracts_cte C 

		SET @logMessage_missing_seller_cat = 'Missing Total - ' + CAST(@COUNT_INVALID_SELLER_CATEGORY_CODE AS NVARCHAR(MAX)) +  ': Invalid or Missing Seller Category in Contract sheet: ' + @BilateralContract_List;
		
	END

	IF(@COUNT_INVALID_BUYER_CATEGORY_CODE > 0)
	BEGIN
		SET @BilateralContract_List = NULL;

		WITH contracts_cte
		AS (
			SELECT 
			DISTINCT c.MtBilateralContract_ContractId
		FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND  C.BuyerSrCategory_Code is NULL OR C.BuyerSrCategory_Code NOT IN (
			SELECT sc.SrCategory_Code FROM SrCategory sc
			
		)
	)

		SELECT 
			@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
		FROM contracts_cte C 
	
		SET @logMessage_missing_buyer_cat ='Missing Total - ' +  CAST(@COUNT_INVALID_BUYER_CATEGORY_CODE AS NVARCHAR(MAX)) +': Invalid or Missing Buyer Category in Contract sheet: ' + @BilateralContract_List;
		
	END

	IF(@COUNT_FIXED_QUANTITY_CONTRACT_WITHOUT_CONTRACT_QUANTITY > 0)
	BEGIN
		SET @BilateralContract_List = NULL;
		SELECT 
			@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
		FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND c.SrContractType_Id=3 
			AND C.MtBilateralContract_ContractedQuantity is NULL;

		SET @logMessage_fixed_Quantity_without_contract_quantity = 'Missing Total - ' + CAST(@COUNT_FIXED_QUANTITY_CONTRACT_WITHOUT_CONTRACT_QUANTITY AS NVARCHAR(MAX)) +': "Fixed Quantity Contract” without Contracted Quantity: ' + @BilateralContract_List;
		
	END

	IF(@COUNT_GENERATION_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE > 0)
	BEGIN
		SET @BilateralContract_List = NULL;
		SELECT 
			@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
		FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND c.SrContractType_Id=1 
			AND C.MtBilateralContract_Percentage is NULL;

		SET @logMessage_gen_fol_contract_missing_percentage = 'Missing Total - ' +   CAST(@COUNT_GENERATION_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE AS NVARCHAR(MAX)) + ': Percentage value missing for Generation Following Contract: ' + @BilateralContract_List;

		
	END

	IF(@COUNT_GENERATION_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE > 0)
	BEGIN
		SET @BilateralContract_List = NULL;
		SELECT 
			@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
		FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND c.SrContractType_Id=1 
			and (C.MtBilateralContract_Percentage<=0 OR C.MtBilateralContract_Percentage>100);

		SET @logMessage_gen_fol_contract_invalid_percentage = 'Missing Total - ' + CAST(@COUNT_GENERATION_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE AS NVARCHAR(MAX)) +': Invalid value in Percentage column of the generation following Contract: ' + @BilateralContract_List;
		
	END


	IF(@COUNT_LOAD_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE > 0)
	BEGIN
		SET @BilateralContract_List = NULL
		SELECT 
			@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
		FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND c.SrContractType_Id=2 
			AND C.MtBilateralContract_Percentage is NULL;

		SET @logMessage_load_fol_contract_missing_percentage ='Missing Total - ' + CAST(@COUNT_LOAD_FOLLOWING_CONTRACT_WITHOUT_PERCENTAGE_VALUE AS NVARCHAR(MAX)) + ': Percentage value missing for Load Following Contract: ' + @BilateralContract_List;
		
	END

	IF(@COUNT_LOAD_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE > 0)
	BEGIN
		SET @BilateralContract_List = NULL;

		SELECT 
			@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
		FROM [MtBilateralContract] C 
		WHERE C.MtSOFileMaster_Id=@SoFileMasterId 
			AND ISNULL(C.MtBilateralContract_Deleted,0)=0
			AND c.SrContractType_Id=2 
			AND (C.MtBilateralContract_Percentage<=0 OR C.MtBilateralContract_Percentage>100);

		SET @logMessage_load_fol_contract_invalid_percentage ='Missing Total - ' +  CAST(@COUNT_LOAD_FOLLOWING_CONTRACT_INVALID_PERCENTAGE_VALUE AS NVARCHAR(MAX)) + ': Invalid value in Percentage column of the load following Contract: ' + @BilateralContract_List;

		
	END

	IF(@COUNT_CONTRACT_TYPE_MISSMATCH > 0
		)
	BEGIN

		DECLARE @COUNT_CONTRACT_IDS INT;
		SET @BilateralContract_List = NULL;

		WITH contracts_cte
		AS (
			 
					SELECT DISTINCT C.MtBilateralContract_ContractId
	    from MtBilateralContract C WHERE MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtBilateralContract_Deleted,0)=0 
        AND  (SrContractType_Id is null  or SrContractType_Id not in(SELECT sct.SrContractType_Id FROM SrContractType sct) OR ContractSubType_Id is null or ContractSubType_Id not in(
		SELECT ssct.SrSubContractType FROM SrSubContractType ssct
		)
		--OR C.SrContractType_Id NOT IN (
		--SELECT 
		--	CASE
		--		WHEN sct.SrSubContractType IN (21,22,23) THEN 2
		--		WHEN sct.SrSubContractType IN (41,42) THEN 4
		--		 ELSE 0
		--	END AS contract_types
		--	FROM SrSubContractType sct
		--)
		--  OR C.MtBilateralContract_ContractType IS NULL 
		--OR c.MtBilateralContract_ContractType NOT IN (SELECT sct.SrContractType_Name FROM SrContractType sct)
		)  
		)


		SELECT 
			@BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') + CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
		FROM contracts_cte C 
	

			--SELECT @COUNT_CONTRACT_IDS = COUNT(MtBilateralContract_ContractId) FROM MtBilateralContract mbc
			--WHERE mbc.MtSOFileMaster_Id=@SoFileMasterId 
			--	AND ISNULL(mbc.MtBilateralContract_Deleted,0)=0
			--	AND (mbc.MtBilateralContract_ContractId is NULL
			--		OR mbc.ContractSubType_Id is NULL
			--		OR mbc.MtBilateralContract_ContractType is null
			--	);
		SET @logMessage_contract_type_other_than_standard = 'Missing Total - ' +  CAST(@COUNT_CONTRACT_TYPE_MISSMATCH AS NVARCHAR(MAX)) + ': Contract type other than standard contract types: ' + @BilateralContract_List;
	END

	DECLARE @logMessage_count_within_contract_missing NVARCHAR(MAX);
	IF(@COUNT_WITHIN_CONTRACT_MISSMATCH > 0)
	BEGIN

		SET @BilateralContract_List = NULL;
		WITH CONTRACTS_CTE
			AS
			(
			select distinct c.MtBilateralContract_ContractId, c.MtBilateralContract_SellerMPId, SellerSrCategory_Code,C.MtBilateralContract_BuyerMPId, C.BuyerSrCategory_Code,
			c.SrContractType_Id,c.ContractSubType_Id            
			from MtBilateralContract C 
			WHERE  C.MtSOFileMaster_Id = @SoFileMasterId AND ISNULL(C.MtBilateralContract_Deleted,0)=0 
			)
			SELECT @BilateralContract_List = ISNULL(@BilateralContract_List + ', ', '') +CAST(c.MtBilateralContract_ContractId AS VARCHAR(MAX))
			FROM
			( select MtBilateralContract_ContractId from CONTRACTS_CTE C
			 GROUP BY c.MtBilateralContract_ContractId
			 HAVING COUNT(1)>1) C;

			 SET @logMessage_count_within_contract_missing = 'Missing Total - ' + CAST(@COUNT_WITHIN_CONTRACT_MISSMATCH AS NVARCHAR(MAX)) +': Within contract mismatch: ' + @BilateralContract_List;
			 
	END



	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_missing_seller_id AS [LOG_MESSAGE], CASE WHEN @logMessage_missing_seller_id IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_missing_seller_id IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_missing_buyer_id AS [LOG_MESSAGE], CASE WHEN @logMessage_missing_buyer_id IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_missing_buyer_id IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_missing_cdp AS [LOG_MESSAGE], CASE WHEN @logMessage_missing_cdp IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_missing_cdp IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_missing_seller_cat AS [LOG_MESSAGE], CASE WHEN @logMessage_missing_seller_cat IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_missing_seller_cat IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_missing_buyer_cat AS [LOG_MESSAGE], CASE WHEN @logMessage_missing_buyer_cat IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_missing_buyer_cat IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_fixed_Quantity_without_contract_quantity AS [LOG_MESSAGE], CASE WHEN @logMessage_fixed_Quantity_without_contract_quantity IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_fixed_Quantity_without_contract_quantity IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_load_fol_contract_missing_percentage AS [LOG_MESSAGE], CASE WHEN @logMessage_load_fol_contract_missing_percentage IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_load_fol_contract_missing_percentage IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_load_fol_contract_invalid_percentage AS [LOG_MESSAGE], CASE WHEN @logMessage_load_fol_contract_invalid_percentage IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_load_fol_contract_invalid_percentage IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_gen_fol_contract_missing_percentage AS [LOG_MESSAGE], CASE WHEN @logMessage_gen_fol_contract_missing_percentage IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_gen_fol_contract_missing_percentage IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_gen_fol_contract_invalid_percentage AS [LOG_MESSAGE], CASE WHEN @logMessage_gen_fol_contract_invalid_percentage IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_gen_fol_contract_invalid_percentage IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_contract_type_other_than_standard AS [LOG_MESSAGE], CASE WHEN @logMessage_contract_type_other_than_standard IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_contract_type_other_than_standard IS NOT NULL
	UNION
	SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_count_within_contract_missing AS [LOG_MESSAGE], CASE WHEN @logMessage_count_within_contract_missing IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
	WHERE @logMessage_count_within_contract_missing IS NOT NULL



 END TRY
BEGIN CATCH
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

END
