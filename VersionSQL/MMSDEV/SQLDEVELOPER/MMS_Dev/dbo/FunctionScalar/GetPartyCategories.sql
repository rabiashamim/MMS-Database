/****** Object:  ScalarFunction [dbo].[GetPartyCategories]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION dbo.GetPartyCategories
(
@pMtPartyRegistrationId decimal(18,0)
)
RETURNS  varchar(500)
AS
BEGIN
	DECLARE @vCategories as varchar(50)


select 
@vCategories=STRING_AGG(SC.SrCategory_Name,',')  WITHIN GROUP ( ORDER BY SC.SrCategory_Name ASC)
from MtPartyCategory MPC
inner join SrCategory SC on SC.SrCategory_Code=MPC.SrCategory_Code
where MtPartyRegisteration_Id=@pMtPartyRegistrationId
and ISNULL(isDeleted,0)=0

	RETURN @vCategories

END
