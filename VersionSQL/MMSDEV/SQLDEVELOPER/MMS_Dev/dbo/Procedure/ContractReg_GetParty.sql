/****** Object:  Procedure [dbo].[ContractReg_GetParty]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.ContractReg_GetParty
AS
	SELECT
		MtPartyRegisteration_Id AS PartyId
	   ,MtPartyRegisteration_Name AS PartyName
	FROM MtPartyRegisteration
	WHERE LuStatus_Code_Applicant = 'AACT'
	AND SrPartyType_Code IN ('MP', 'EP')
	AND ISNULL(isDeleted, 0) = 0
