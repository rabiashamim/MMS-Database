/****** Object:  Procedure [dbo].[ContractReg_ProfileValidation]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author Updated  Ali Imran 
-- CREATE date: 
-- ALTER date: 25 august 2023
-- Description: Task Id 3730 updated. 
-- Parameters: 
-- =============================================         
CREATE   Procedure dbo.ContractReg_ProfileValidation      
(      
    @pContractRegistration_id INT,      
    -- this parameter is to be used later - to check if the user is authorized to initiate approval flow or no.          
    @pUserId INT = NULL      
)      
AS      
BEGIN      
    DECLARE @vCountCPEnergy INT,      
            @vCountContractHours INT,      
            @vCountCPEnergyHours INT,      
            @vCountCPCapacity INT,      
            @vCountCDPTradingPoints INT,      
            --@vCountPhysicalAssets INT,          
            --@vCountDocuments INT,  
			@vContractType INT,
            @vValidationMessage VARCHAR(256);      
      
      
    SET @vValidationMessage = '';      
    SELECT @vCountCPEnergy = COUNT(*)      
    FROM MtContractProfileEnergy mcpe      
    WHERE mcpe.MtContractRegistration_Id = @pContractRegistration_id      
          AND ISNULL(mcpe.MtContractProfileEnergy_IsDeleted, 0) = 0;      
      
    IF @vCountCPEnergy != 0      
    BEGIN      
        SELECT @vCountContractHours      
            = DATEDIFF(HOUR, mcr.MtContractRegistration_EffectiveFrom, mcr.MtContractRegistration_EffectiveTo) +24     
			,@vContractType=mcr.SrContractType_Id
        FROM MtContractRegistration mcr      
        WHERE mcr.MtContractRegistration_Id = @pContractRegistration_id      
              AND ISNULL(mcr.MtContractRegistration_IsDeleted, 0) = 0;      
      
      
        WITH cte_CPEnergy      
        AS (SELECT (DATEDIFF(DAY, mcpe.MtContractProfileEnergy_DateFrom, mcpe.MtContractProfileEnergy_DateTo) +1   )  
                   * ((ISNULL(mcpe.MtContractProfileEnergy_HourTo, 0)  - ISNULL(mcpe.MtContractProfileEnergy_HourFrom, 0))+1     
                             ) AS ProfileHours      
            FROM MtContractProfileEnergy mcpe      
            WHERE mcpe.MtContractRegistration_Id = @pContractRegistration_id      
                  AND ISNULL(mcpe.MtContractProfileEnergy_IsDeleted, 0) = 0      
           )      
        SELECT @vCountCPEnergyHours = SUM(ISNULL(ProfileHours, 0))      
        FROM cte_CPEnergy      
      
        IF @vCountContractHours != @vCountCPEnergyHours      
        BEGIN      
            SET @vValidationMessage      
                = @vValidationMessage       
                  + 'Sum of total profile hours defined should be equal to the total number of contract hours, ';      
        END      
      


      
    END      
      
    SELECT @vCountCPCapacity = COUNT(*)      
    FROM MtContractProfileCapacity mcpc      
    WHERE mcpc.MtContractRegistration_Id = @pContractRegistration_id      
          AND ISNULL(mcpc.MtContractProfileCapacity_IsDeleted, 0) = 0;      
      

 
    SELECT @vCountCDPTradingPoints = COUNT(*)      
    FROM MtContractTradingCDPs mctc      
    WHERE mctc.MtContractRegistration_Id = @pContractRegistration_id      
          AND ISNULL(mctc.MtContractTradingCDPs_IsDeleted, 0) = 0;      
   
      
      
    IF @vCountCPCapacity = 0      
       AND @vCountCPEnergy = 0      
    BEGIN      
        SET @vValidationMessage = @vValidationMessage + 'Capacity or Energy needs to be defined';      
    END      
	
	/*
	* Task Id 3730
	* Updated by ali imran on 25 Augus 2023
	*/

    IF @vCountCDPTradingPoints = 0    AND @vContractType <> 3
    BEGIN      
        SET @vValidationMessage = @vValidationMessage + ' ,' + 'Missing CDP Trading Points';      
    END      
     
    IF (@vValidationMessage = '')      
    BEGIN      
        SELECT 1 AS IsValid,      
               '' AS ValidationMessage      
    END      
    ELSE      
    BEGIN      
        SELECT 0 AS IsValid,      
               @vValidationMessage AS ValidationMessage      
    END      
      
      
      
      
END
