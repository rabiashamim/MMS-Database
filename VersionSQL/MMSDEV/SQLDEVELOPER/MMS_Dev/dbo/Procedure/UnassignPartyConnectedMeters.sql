/****** Object:  Procedure [dbo].[UnassignPartyConnectedMeters]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[UnassignPartyConnectedMeters]
@vpartyRegistrationId decimal(18,0)
AS
BEGIN
	
		update 
			MtConnectedMeter 
		set 
			IsAssigned = 0,
			mtconnectedmeter_effectiveto = getutcdate() 
		where MtConnectedMeter_Id in
			(SELECT 
				CM.MtConnectedMeter_Id 
			FROM MtPartyRegisteration PR
			JOIN MtPartyCategory PC 
			on 
				PC.MtPartyRegisteration_Id=PR.MtPartyRegisteration_Id
			JOIN MtConnectedMeter CM 
			on 
				CM.MtPartyCategory_Id = PC.MtPartyCategory_Id
			WHERE 
				ISNULL(CM.IsAssigned,0) = 1
				AND ISNULL(PC.isDeleted,0) = 0
				AND ISNULL(PR.isDeleted,0) = 0
				AND PR.MtPartyRegisteration_Id=@vpartyRegistrationId)

END
