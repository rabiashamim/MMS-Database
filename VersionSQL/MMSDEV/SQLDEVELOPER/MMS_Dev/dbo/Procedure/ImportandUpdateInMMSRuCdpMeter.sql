/****** Object:  Procedure [dbo].[ImportandUpdateInMMSRuCdpMeter]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Ali Imran
--Reviewer : <>
--CreatedDate : 17 Feb 2022
--Comments : Import  and Update Cdp Meter information
--======================================================================

CREATE PROCEDURE [dbo].[ImportandUpdateInMMSRuCdpMeter]
AS
BEGIN

/*********************************************************************  
Identify the new Records in interface table which not exist in MMS before.
save that records in temp table #NewRecords
*********************************************************************/


UPDATE
	CM
 SET
		    
            [CM].[RuCDPDetail_CdpId]			=InterfaceRuCDPDetail_CdpId	
           ,[CM].[RuCdpMeters_DeviceName]		=InterfaceRuCdpMeters_DeviceName
           ,[CM].[RuCdpMeters_Status]			=InterfaceRuCdpMeters_Status
           ,[CM].[RuCdpMeters_MeterNo]			=InterfaceRuCdpMeters_MeterNo
           ,[CM].[RuCdpMeters_MeterQualifier]	=InterfaceRuCdpMeters_MeterQualifier
           ,[CM].[RuCdpMeters_MeterModelType]	=InterfaceRuCdpMeters_MeterModelType
           ,[CM].[RuCdpMeters_Latitude]			=InterfaceRuCdpMeters_Latitude
           ,[CM].[RuCdpMeters_Longitude]		=InterfaceRuCdpMeters_Longitude
           ,[CM].[RuCdpMeters_MeterType]		=InterfaceRuCdpMeters_MeterType
           ,[CM].[RuCdpMeters_EffectiveFrom]	=InterfaceRuCdpMeters_EffectiveFrom
           ,[CM].[RuCdpMeters_EffectiveTo]		=InterfaceRuCdpMeters_EffectiveTo
           ,[CM].[RuCdpMeters_CreatedDateTime]	=InterfaceRuCdpMeters_CreatedDateTime
           ,[CM].[RuCdpMeters_UpdatedDateTime]	=InterfaceRuCdpMeters_UpdatedDateTime
		   ,[CM].[RuCdpMeters_ModifiedBy]		=101
		   ,[CM].[RuCdpMeters_ModifiedOn]		=GETUTCDATE()
		
FROM  [dbo].[RuCdpMeters] CM
JOIN [dbo].[InterfaceRuCdpMeters] ICM  ON CM.RuCdpMeters_MeterId=ICM.InterfaceRuCdpMeters_MeterId;

--SELECT
--		* 
--INTO 
--		#NewRecords
--FROM 
--		[dbo].[InterfaceRuCdpMeters]
--WHERE
--		[InterfaceRuCdpMeters_MeterId] NOT IN (SELECT  [RuCdpMeters_MeterId] FROM [dbo].[RuCdpMeters])
--	   	AND ISNULL(InterfaceRuCdpMeters_IsDeleted,0)=0

INSERT INTO [dbo].[RuCdpMeters] (
	[RuCdpMeters_MeterId]
    ,[RuCDPDetail_CdpId]
    ,[RuCdpMeters_DeviceName]
    ,[RuCdpMeters_Status]
    ,[RuCdpMeters_MeterNo]
    ,[RuCdpMeters_MeterQualifier]
    ,[RuCdpMeters_MeterModelType]
    ,[RuCdpMeters_Latitude]
    ,[RuCdpMeters_Longitude]
    ,[RuCdpMeters_MeterType]
    ,[RuCdpMeters_EffectiveFrom]
    ,[RuCdpMeters_EffectiveTo]
    ,[RuCdpMeters_CreatedDateTime]
    ,[RuCdpMeters_UpdatedDateTime]
    ,[RuCdpMeters_CreatedBy]
    ,[RuCdpMeters_CreatedOn]
	)
SELECT
	 [InterfaceRuCdpMeters_MeterId]
    ,[InterfaceRuCDPDetail_CdpId]
    ,[InterfaceRuCdpMeters_DeviceName]
    ,[InterfaceRuCdpMeters_Status]
    ,[InterfaceRuCdpMeters_MeterNo]
    ,[InterfaceRuCdpMeters_MeterQualifier]
    ,[InterfaceRuCdpMeters_MeterModelType]
    ,[InterfaceRuCdpMeters_Latitude]
    ,[InterfaceRuCdpMeters_Longitude]
    ,[InterfaceRuCdpMeters_MeterType]
	,InterfaceRuCdpMeters_EffectiveFrom
    ,InterfaceRuCdpMeters_EffectiveTo
    ,InterfaceRuCdpMeters_CreatedDateTime
    ,InterfaceRuCdpMeters_UpdatedDateTime
	,101
	,[InterfaceRuCdpMeters_CreatedOn]
FROM
	[dbo].[InterfaceRuCdpMeters]
WHERE
	NOT EXISTS ( 
				SELECT 
					'X' 
				FROM
					[dbo].[RuCdpMeters]
				WHERE
					[InterfaceRuCdpMeters_MeterId] = [RuCdpMeters_MeterId]
				)
	AND
		ISNULL(InterfaceRuCdpMeters_IsDeleted,0) = 0
					

/*********************************************************************  
Update the existing records from Interface table
*********************************************************************/


/*********************************************************************  
Insert the new records which we save in temp table #NewRecords
*********************************************************************/

--IF Exists(SELECT 1 FROM #NewRecords)
--BEGIN
--INSERT INTO [dbo].[RuCdpMeters]
--           (
--           [RuCdpMeters_MeterId]
--           ,[RuCDPDetail_CdpId]
--           ,[RuCdpMeters_DeviceName]
--           ,[RuCdpMeters_Status]
--           ,[RuCdpMeters_MeterNo]
--           ,[RuCdpMeters_MeterQualifier]
--           ,[RuCdpMeters_MeterModelType]
--           ,[RuCdpMeters_Latitude]
--           ,[RuCdpMeters_Longitude]
--           ,[RuCdpMeters_MeterType]
--           ,[RuCdpMeters_EffectiveFrom]
--           ,[RuCdpMeters_EffectiveTo]
--           ,[RuCdpMeters_CreatedDateTime]
--           ,[RuCdpMeters_UpdatedDateTime]
--           ,[RuCdpMeters_CreatedBy]
--           ,[RuCdpMeters_CreatedOn]
--           )
     
--SELECT
      
--		    [InterfaceRuCdpMeters_MeterId]
--            ,[InterfaceRuCDPDetail_CdpId]
--           ,[InterfaceRuCdpMeters_DeviceName]
--           ,[InterfaceRuCdpMeters_Status]
--           ,[InterfaceRuCdpMeters_MeterNo]
--           ,[InterfaceRuCdpMeters_MeterQualifier]
--           ,[InterfaceRuCdpMeters_MeterModelType]
--           ,[InterfaceRuCdpMeters_Latitude]
--           ,[InterfaceRuCdpMeters_Longitude]
--           ,[InterfaceRuCdpMeters_MeterType]
--		   ,InterfaceRuCdpMeters_EffectiveFrom
--           ,InterfaceRuCdpMeters_EffectiveTo
--           ,InterfaceRuCdpMeters_CreatedDateTime
--           ,InterfaceRuCdpMeters_UpdatedDateTime
--		   ,101
--	       ,[InterfaceRuCdpMeters_CreatedOn]
		   
           
--FROM 
--			#NewRecords
         
--END


/*********************************************************************  
Delete the records after import and update is complete
*********************************************************************/  

UPDATE 
	[dbo].[InterfaceRuCdpMeters]
SET 
	InterfaceRuCdpMeters_IsDeleted=1
WHERE 
	ISNULL(InterfaceRuCdpMeters_IsDeleted,0)=0


	TRUNCATE TABLE	[dbo].[InterfaceRuCdpMeters]

END
