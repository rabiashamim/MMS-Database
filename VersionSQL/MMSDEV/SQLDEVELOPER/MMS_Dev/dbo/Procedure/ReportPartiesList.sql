/****** Object:  Procedure [dbo].[ReportPartiesList]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--CreatedDate : 2 Sep 2022
--Comments : ASC Reports Summary
--======================================================================

CREATE PROCEDURE dbo.ReportPartiesList

AS
BEGIN

select MtPartyRegisteration_Id, MtPartyRegisteration_Name from MtPartyRegisteration where SrPartyType_Code='MP' and ISNULL(isDeleted,0)=0 and ISNULL(MtPartyRegisteration_IsPowerPool,0)<>1


END
