/****** Object:  Function [dbo].[GetPartyNameFromPartyId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Sadaf Malik>
-- Create date: <24-Feb-2022>
-- =============================================
CREATE function [dbo].[GetPartyNameFromPartyId]
(
@MtPartyRegistration_Id decimal(18,0)
)
RETURNS varchar(200)-- <Function_Data_Type, ,int>
AS
BEGIN
Return(
Select MPR.MtPartyRegisteration_Name from MtPartyRegisteration MPR 
where MPR.MtPartyRegisteration_Id=@MtPartyRegistration_Id
)
END
