/****** Object:  Procedure [dbo].[GETCDPDetails_Temp]    Committed by VersionSQL https://www.versionsql.com ******/

--  GETCDPDetails 723
CREATE PROCEDURE [dbo].[GETCDPDetails_Temp]
@pPartyId decimal(18,0)
AS
BEGIN
Declare @vPartyRegisteration_Id DECIMAL(18,0);

	SELECT 
		@vPartyRegisteration_Id=MtPartyRegisteration_Id  
	FROM 
		MtPartyCategory 
	WHERE 
		MtPartyCategory_Id=@pPartyId

   SELECT MtCDPDetail_Id into #temp FROM MtConnectedMeter WHERE 
    ISNULL(MtConnectedMeter_isDeleted,0)=0
	AND ISNULL(IsAssigned,0)=1
   AND MtPartyCategory_Id in (

   SELECT MtPartyCategory_Id FROM MtPartyCategory WHERE MtPartyRegisteration_Id =@vPartyRegisteration_Id AND ISNULL(isDeleted,0)=0
   
   )

	select distinct
	    RuCDPDetail_Id AS ID
		,RuCDPDetail_CdpId AS CdpId
		,RuCDPDetail_CdpName AS cdpName
		,RuCDPDetail_ToCustomer AS ToCustomer
		,RuCDPDetail_FromCustomer AS FromCustomer
		,RuCDPDetail_LineVoltage AS LineVoltage
		,'' AS Primary_MTMeterDetail
		,'' AS BackUp_MTMeterDetail
		 ,(SELECT MtPartyRegisteration_Name FROM MtPartyRegisteration WHERE MCM.MtConnectedMeter_ConnectedFrom=MtPartyRegisteration_Id ) as Connected_ToParty
		 ,(SELECT MtPartyRegisteration_Name FROM MtPartyRegisteration WHERE MCM.MtConnectedMeter_ConnectedTo=MtPartyRegisteration_Id ) as Connected_FromParty	
	from  
		[dbo].[RuCDPDetail] RCDP
	LEFT JOIN MtConnectedMeter MCM ON MCM.MtCDPDetail_Id=RCDP.RuCDPDetail_Id
	WHERE
	RCDP.RuCDPDetail_Id NOT IN (
	SELECT MtCDPDetail_Id FROM #temp
	)


END
