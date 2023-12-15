/****** Object:  Procedure [dbo].[ContractReg_GetExistingContractDocuments]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.ContractReg_GetExistingContractDocuments          
    @pMtDocuments_ID int = null,          
    @pMtContractRegistration_Id decimal(18, 0) = null,          
    @pRuDocument_ID int = null,        
    @pRuDocuments_FormName   varchar(max) = null        
AS          
if isnull(@pMtDocuments_ID, 0) = 0          
   --and isnull(@pMtContractRegistration_Id, 0) != 0          
   and isnull(@pRuDocument_ID, 0) = 0          
BEGIN          
    SELECT RuDocuments_Id,          
           RuDocuments_Name,          
           count(MD.RuDocument_ID) as RuDocuments_Count          
    FROM RuDocuments RD          
        LEFT JOIN MtDocuments MD          
            ON MD.RuDocument_ID = RD.RuDocuments_Id  AND ISNULL(md.MtDocuments_isDeleted, 0) = 0  and MtContractRegistration_Id=isnull(@pMtContractRegistration_Id, 0)  
    WHERE RD.RuDocuments_FormName = @pRuDocuments_FormName          
                   
    GROUP BY RuDocuments_Name,          
             RuDocuments_Id          
END          
else if isnull(@pMtDocuments_ID, 0) != 0          
BEgin          
    SELECT *          
    FROM MtDocuments md          
    WHERE md.MtDocuments_ID = @pMtDocuments_ID          
          AND ISNULL(md.MtDocuments_isDeleted, 0) = 0          
end          
else if isnull(@pMtContractRegistration_Id, 0) != 0          
        and isnull(@pRuDocument_ID, 0) != 0          
begin          
    SELECT *          
    FROM MtDocuments md          
    WHERE md.RuDocument_ID = @pRuDocument_ID          
          AND md.MtContractRegistration_Id = @pMtContractRegistration_Id          
          AND ISNULL(md.MtDocuments_isDeleted, 0) = 0          
end 
