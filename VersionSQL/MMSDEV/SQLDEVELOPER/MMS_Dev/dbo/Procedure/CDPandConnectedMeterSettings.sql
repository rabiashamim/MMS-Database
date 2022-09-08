/****** Object:  Procedure [dbo].[CDPandConnectedMeterSettings]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Ali Imran
--Reviewer : <>
--CreatedDate : 23 Feb 2022
--Comments : Connected Meter  CDP settings for connected to and connected From
--======================================================================

CREATE PROCEDURE [dbo].[CDPandConnectedMeterSettings]

--DECLARE 
--@pCdpId int=1,        
--@pCategoryId int=799,
--@pIsNewConnectedMeter bit=1
@pCdpId int,        
@pCategoryId int,
@pIsNewConnectedMeter bit

AS
BEGIN
/***********************************************************
declare variables
************************************************************/
DECLARE @vConnectedFrom DECIMAL(18,0)  
,@vConnectedTo DECIMAL(18,0)
,@vEffectiveFrom DATETIME
,@vEffectiveTo DATETIME



/***********************************************************
SET Variables
************************************************************/


SELECT TOP 1
	 @vConnectedFrom=CM.MtConnectedMeter_ConnectedFrom
	,@vConnectedTo=CM.MtConnectedMeter_ConnectedTo
	,@vEffectiveFrom=CM.MtConnectedMeter_EffectiveFrom
	,@vEffectiveTo = CM.MtConnectedMeter_EffectiveTo
FROM 
	RuCDPDetail CDP
JOIN  MtConnectedMeter CM ON CM.MtCDPDetail_Id=CDP.RuCDPDetail_Id
WHERE
	CDP.RuCDPDetail_Id =@pCdpId
	AND CM.IsAssigned=1
	AND CM.MtConnectedMeter_isDeleted=0
	AND 
		(
			(@pIsNewConnectedMeter=1 and CM.MtPartyCategory_Id <> @pCategoryId)
		 OR (@pIsNewConnectedMeter=0 and CM.MtPartyCategory_Id = @pCategoryId)
		)	


/***********************************************************
UPDATE ConnectedMeter Information 
************************************************************/
SELECT @vConnectedFrom,@vConnectedTo,@vEffectiveFrom,@vEffectiveTo


UPDATE MtConnectedMeter 
		SET MtConnectedMeter_ConnectedFrom=@vConnectedFrom
			,MtConnectedMeter_ConnectedTo=@vConnectedTo
			,MtConnectedMeter_EffectiveFrom=@vEffectiveFrom
			,MtConnectedMeter_EffectiveTo=@vEffectiveTo
WHERE 
			MtCDPDetail_Id=@pCdpId
		AND	IsAssigned=1
        AND
		(
			(@pIsNewConnectedMeter=1 and MtPartyCategory_Id = @pCategoryId)
		 OR (@pIsNewConnectedMeter=0 and MtPartyCategory_Id <> @pCategoryId)
		 )
END
