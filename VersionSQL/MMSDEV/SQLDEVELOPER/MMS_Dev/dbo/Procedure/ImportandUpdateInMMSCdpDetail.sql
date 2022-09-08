/****** Object:  Procedure [dbo].[ImportandUpdateInMMSCdpDetail]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Ali Imran
--Reviewer : <>
--CreatedDate : 16 Feb 2022
--Comments : Import  and Update CdpDetail
--======================================================================
-- use mms
CREATE PROCEDURE [dbo].[ImportandUpdateInMMSCdpDetail]
AS
BEGIN


/*********************************************************************  
if no record found for update or add than resturn 0
*********************************************************************/  
if not exists(select 1 FROM InterfaceRuCdpDetail WHERE ISNULL(InterfaceRuCDPDetail_IsDeleted,0)=0)
BEGIN
 SELECT 0 as response
 return
END


/*********************************************************************  
Identify the new Records in interface table which not exist in MMS befor.
save that records in temp table #NewRecords
*********************************************************************/  

SELECT
		* 
INTO 
		#NewRecords
FROM 
		[dbo].[InterfaceRuCDPDetail]
WHERE
		InterfaceRuCDPDetail_CdpId NOT IN (SELECT RuCDPDetail_CdpId FROM RuCDPDetail)
	    AND ISNULL(InterfaceRuCDPDetail_IsDeleted,0)=0




/*********************************************************************  
Update the existing records from Interface table
*********************************************************************/  


	UPDATE 
		CDP 
    SET
            CDP.RuCDPDetail_CdpName				=ICDP.InterfaceRuCDPDetail_CdpName
           ,CDP.RuCDPDetail_CdpStatus			=ICDP.InterfaceRuCDPDetail_CdpStatus
           ,CDP.RuCDPDetail_ToCustomer			=ICDP.InterfaceRuCDPDetail_ToCustomer
           ,CDP.RuCDPDetail_FromCustomer		=ICDP.InterfaceRuCDPDetail_FromCustomer
           ,CDP.RuCDPDetail_LineVoltage			=ICDP.InterfaceRuCDPDetail_LineVoltage
           ,CDP.RuCDPDetail_Station				=ICDP.InterfaceRuCDPDetail_Station
           ,CDP.RuCDPDetail_EffectiveFrom		=ICDP.InterfaceRuCDPDetail_EffectiveFrom
           ,CDP.RuCDPDetail_EffectiveTo			=ICDP.InterfaceRuCDPDetail_EffectiveTo
           ,CDP.RuCDPDetail_CreatedDateTime		=ICDP.InterfaceRuCDPDetail_CreatedDateTime
           ,CDP.RuCDPDetail_UpdatedDateTime		=ICDP.InterfaceRuCDPDetail_UpdatedDateTime
           ,CDP.RuCDPDetail_ModifiedOn			=GETUTCDATE()
           ,CDP.RuCDPDetail_ModifiedBy			=101
FROM
RuCDPDetail CDP 
JOIN InterfaceRuCdpDetail ICDP ON CDP.RuCDPDetail_CdpId = ICDP.InterfaceRuCDPDetail_CdpId

/*********************************************************************  
Insert the new records which we save in temp table #NewRecords
*********************************************************************/  


		

IF Exists(SELECT 1 FROM #NewRecords)
BEGIN

	INSERT INTO [dbo].[RuCDPDetail]
           (
            [RuCDPDetail_CdpId]
           ,[RuCDPDetail_CdpName]
           ,[RuCDPDetail_CdpStatus]
           ,[RuCDPDetail_ToCustomer]
           ,[RuCDPDetail_FromCustomer]
           ,[RuCDPDetail_LineVoltage]
           ,[RuCDPDetail_Station]
           ,[RuCDPDetail_EffectiveFrom]
           ,[RuCDPDetail_EffectiveTo]
           ,[RuCDPDetail_CreatedDateTime]
           ,[RuCDPDetail_UpdatedDateTime]
           ,[RuCDPDetail_CreatedBy]
           ,[RuCDPDetail_CreatedOn]
           )
	SELECT  
		     InterfaceRuCDPDetail_CdpId
			,InterfaceRuCDPDetail_CdpName
			,InterfaceRuCDPDetail_CdpStatus	
			,InterfaceRuCDPDetail_ToCustomer	
			,InterfaceRuCDPDetail_FromCustomer	
			,InterfaceRuCDPDetail_LineVoltage	
			,InterfaceRuCDPDetail_Station	
			,InterfaceRuCDPDetail_EffectiveFrom	
			,InterfaceRuCDPDetail_EffectiveTo	
			,InterfaceRuCDPDetail_CreatedDateTime	
			,InterfaceRuCDPDetail_UpdatedDateTime	
			,101
			,GETUTCDATE()
	FROM
		#NewRecords

	END

/*********************************************************************  
Delete the records after import and update is complete
*********************************************************************/  

UPDATE 
	InterfaceRuCDPDetail
SET 
	InterfaceRuCDPDetail_IsDeleted=1
WHERE 
	ISNULL(InterfaceRuCDPDetail_IsDeleted,0)=0





/*********************************************************************    
Once the record is insert in operational table we need to clean it
*********************************************************************/  

  Truncate Table  	InterfaceRuCDPDetail  
  

  END
