/****** Object:  Function [dbo].[GetPartyNameFromPartyCategoryId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Sadaf Malik>
-- Create date: <24-Feb-2022>
-- =============================================
CREATE function [dbo].[GetPartyNameFromPartyCategoryId]
(
@MtPartyCategoryId decimal(18,0)
)
RETURNS varchar(200)-- <Function_Data_Type, ,int>
AS
BEGIN
Return(
Select MPR.MtPartyRegisteration_Name from MtPartyRegisteration MPR 
inner join MtPartyCategory MPC on MPC.MtPartyRegisteration_Id=MPR.MtPartyRegisteration_Id
where MPC.MtPartyCategory_Id=@MtPartyCategoryId
)
END
