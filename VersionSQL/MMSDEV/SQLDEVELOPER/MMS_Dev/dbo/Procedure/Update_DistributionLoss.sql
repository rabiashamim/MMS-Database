/****** Object:  Procedure [dbo].[Update_DistributionLoss]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Update_DistributionLoss]
	@entityID decimal(18,0),
	@distLossesID decimal(18,0),
	@lineVoltage Int,
	@distLossesFactor decimal(18,4),
    @distLossesEffectiveFrom datetime,
	@distLossesEffectiveTo datetime
	
AS
BEGIN
    SET NOCOUNT ON;

	declare @mpRegName varchar(100);

	SELECT @mpRegName=MtPartyRegisteration_Name from MtPartyRegisteration where MtPartyRegisteration_Id=@entityID


	UPDATE [dbo].[Lu_DistLosses] 
	SET 
	Lu_DistLosses_MP_Id = @entityID,
	Lu_DistLosses_MP_Name = @mpRegName,
	Lu_DistLosses_LineVoltage = @lineVoltage,
	Lu_DistLosses_Factor = @distLossesFactor,
	Lu_DistLosses_EffectiveFrom = @distLossesEffectiveFrom,
	Lu_DistLosses_EffectiveTo = @distLossesEffectiveTo,
	Lu_DistLosses_UpdatedDate = GETUTCDATE(),
	MtPartyRegisteration_Id = @entityID

	WHERE
	Lu_DistLosses_Id = @distLossesID

END
