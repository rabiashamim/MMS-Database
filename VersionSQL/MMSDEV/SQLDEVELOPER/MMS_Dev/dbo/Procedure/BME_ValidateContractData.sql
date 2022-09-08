/****** Object:  Procedure [dbo].[BME_ValidateContractData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 18, 2022 
-- ALTER date: June 01, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
CREATE  Procedure [dbo].[BME_ValidateContractData](			 
			@SoFileMasterId decimal(18,0)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
DECLARE @COUNT_CONTRACT INT=0;
DECLARE @COUNT_CONTRACT_VIEW INT=0;
    IF EXISTS(SELECT TOP 1 MtBilateralContract_Id FROM MtBilateralContract WHERE MtSOFileMaster_Id=@SoFileMasterId)
    BEGIN
        select @COUNT_CONTRACT = COUNT(1)
	    from MtBilateralContract WHERE MtSOFileMaster_Id=@SoFileMasterId;

     	select @COUNT_CONTRACT_VIEW = COUNT(1)
	    from dbo.Bme_ContractParties
	    WHERE MtSOFileMaster_Id=@SoFileMasterId;

--------------------------------------        

    DECLARE @COUNT_CONTRACT_TYPE_MISSMATCH INT=0;
        select @COUNT_CONTRACT_TYPE_MISSMATCH = COUNT(1)
	    from MtBilateralContract C WHERE MtSOFileMaster_Id=@SoFileMasterId
        AND  (SrContractType_Id is null  or SrContractType_Id not in(1,2,3,4) OR ContractSubType_Id is null or ContractSubType_Id not in(0,21,22,23,41,42));

---------------------------------

    DECLARE @COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH INT=0;
        select @COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH = COUNT(1)
	    from MtBilateralContract C WHERE MtSOFileMaster_Id=@SoFileMasterId
        AND SellerSrCategory_Code not in(SELECT SrCategory_Code FROM dbo.SrCategory);

    DECLARE @COUNT_CONTRACT_BUYER_CATEGORY_CODE_MISSMATCH INT=0;
        select @COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH = COUNT(1)
	    from MtBilateralContract C WHERE  MtSOFileMaster_Id=@SoFileMasterId
        AND BuyerSrCategory_Code not in(SELECT SrCategory_Code FROM dbo.SrCategory);

DECLARE @COUNT_WITHIN_CONTRACT_MISSMATCH INT=0;

WITH CONTRACTS_CTE
AS
(
select distinct c.MtBilateralContract_ContractId, c.MtBilateralContract_SellerMPId, SellerSrCategory_Code,C.MtBilateralContract_BuyerMPId, C.BuyerSrCategory_Code,
c.SrContractType_Id,c.ContractSubType_Id            
from MtBilateralContract C 
WHERE  C.MtSOFileMaster_Id = @SoFileMasterId
)
SELECT @COUNT_WITHIN_CONTRACT_MISSMATCH = COUNT(1)
FROM
( select MtBilateralContract_ContractId from CONTRACTS_CTE C
 GROUP BY c.MtBilateralContract_ContractId
 HAVING COUNT(1)>1) C;

---------------------------

        IF(@COUNT_CONTRACT<>@COUNT_CONTRACT_VIEW 
        OR @COUNT_CONTRACT_TYPE_MISSMATCH>0
        OR @COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH>0
        OR @COUNT_CONTRACT_BUYER_CATEGORY_CODE_MISSMATCH>0
        OR @COUNT_WITHIN_CONTRACT_MISSMATCH>0
        )
        BEGIN
        SELECT 'INVALID CONTRACT DATA' AS ErrorMessage
        , @COUNT_CONTRACT - @COUNT_CONTRACT_VIEW as [COUNT_CONTRACT_PARTIES_MISSMATCH]        
        , @COUNT_CONTRACT_TYPE_MISSMATCH as [COUNT_CONTRACT_TYPE_MISSMATCH]
        , @COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH as [COUNT_CONTRACT_SELLER_CATEGORY_CODE_MISSMATCH]
        , @COUNT_CONTRACT_BUYER_CATEGORY_CODE_MISSMATCH as [COUNT_CONTRACT_BUYER_CATEGORY_CODE_MISSMATCH]
        , @COUNT_WITHIN_CONTRACT_MISSMATCH as [COUNT_WITHIN_CONTRACT_MISSMATCH]
        ;
        RETURN;
        END
 
SELECT 1 AS [IS_VALID], @@ROWCOUNT AS [ROW_COUNT], OBJECT_NAME(@@PROCID) AS [SP_NAME];
 END
 ELSE
 BEGIN
 SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME];
 END 
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
