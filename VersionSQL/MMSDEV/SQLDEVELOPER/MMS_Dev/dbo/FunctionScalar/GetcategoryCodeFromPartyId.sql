/****** Object:  ScalarFunction [dbo].[GetcategoryCodeFromPartyId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Alina Javed>
-- Create date: <24-Feb-2022>
-- =============================================
Create function dbo.GetcategoryCodeFromPartyId
(
@MtPartyRegistration_Id decimal(18,0)
)
RETURNS varchar(200)-- <Function_Data_Type, ,int>
AS
BEGIN
Return(
Select SrCategory_Code from MtPartyRegisteration MPR 
inner join MtPartyCategory PC on PC.MtPartyRegisteration_Id=
MPR.MtPartyRegisteration_Id
where MPR.MtPartyRegisteration_Id=@MtPartyRegistration_Id
)
END
