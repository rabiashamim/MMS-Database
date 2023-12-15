/****** Object:  ScalarFunction [dbo].[GetValueFromReference]    Committed by VersionSQL https://www.versionsql.com ******/

--select dbo.GetValueFromReference('Tax % for SC')
CREATE FUNCTION dbo.GetValueFromReference
(@pName VARCHAR(MAX))
RETURNs  VARCHAR(max)
AS
BEGIN
	DECLARE @vValue VARCHAR(MAx)
	SELECT TOP 1 @vValue=CAST(ROUND(RV.RuReferenceValue_Value, 2) AS DECIMAL(10, 1)) FROM SrReferenceType RT
JOIN RuReferenceValue RV ON RT.SrReferenceType_Id=RV.SrReferenceType_Id
WHERE RT.SrReferenceType_Name=@pName and RV.RuReferenceValue_IsDeleted=0

RETURN @vValue
END
