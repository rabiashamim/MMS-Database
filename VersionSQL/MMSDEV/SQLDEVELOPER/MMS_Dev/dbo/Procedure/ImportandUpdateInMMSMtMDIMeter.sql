/****** Object:  Procedure [dbo].[ImportandUpdateInMMSMtMDIMeter]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--Reviewer : <>
--CreatedDate : 27 Jun 2022
--Comments : Import  and Update MDI Meter information
--======================================================================

CREATE PROCEDURE [dbo].[ImportandUpdateInMMSMtMDIMeter]
AS
BEGIN

/*********************************************************************  
This block only declare variables which we use with in this sp
*********************************************************************/  

DECLARE     
  @vMtMeteringImportInfo_Id		Decimal(18,0)    
, @vInterface_LastRecordId		Decimal(18,0)    
, @vInterface_LastRecordDate	DATETIME    
, @vLastImportDateInMMS			DATETIME    
, @NewBatchNo					INT    
, @BatchNo						INT    

/*********************************************************************  
Update the existing records from Interface table
*********************************************************************/


UPDATE
	MDI
 SET
--		     [MDI].[MtMDIImportInfo_Id]						=[IMDI].[InterfaceMtMDIImportInfo_Id]						
			[MDI].[MtMonthlyMDI_DateTimeStampImport] 		=case when ([IMDI].[InterfaceMtMonthlyMDI_DateTimeStampImport] is not NULL AND [IMDI].[InterfaceMtMonthlyMDI_DateTimeStampImport] <>'') then convert(DATETIME, [IMDI].[InterfaceMtMonthlyMDI_DateTimeStampImport],105) else null end
			,[MDI].[MtMonthlyMDI_MdiMonthImport] 			=[IMDI].[InterfaceMtMonthlyMDI_MdiMonthImport] 
			,[MDI].[MtMonthlyMDI_MeterIdImport]				=[IMDI].[InterfaceMtMonthlyMDI_MeterIdImport]	
			,[MDI].[MtMonthlyMDI_DataSourceImport]			=[IMDI].[InterfaceMtMonthlyMDI_DataSourceImport]	
			,[MDI].[MtMonthlyMDI_MeterQualifierImport]		=[IMDI].[InterfaceMtMonthlyMDI_MeterQualifierImport]	
			,[MDI].[MtMonthlyMDI_DataLabelImport] 			=[IMDI].[InterfaceMtMonthlyMDI_DataLabelImport] 	
			,[MDI].[MtMonthlyMDI_DataStatusImport]			=[IMDI].[InterfaceMtMonthlyMDI_DataStatusImport]
			,[MDI].[MtMonthlyMDI_DateTimeStampExport] 		=	 case when ([IMDI].[InterfaceMtMonthlyMDI_DateTimeStampExport] is not NULL AND [IMDI].[InterfaceMtMonthlyMDI_DateTimeStampExport] <>'') then convert(DATETIME, [IMDI].[InterfaceMtMonthlyMDI_DateTimeStampExport],105) else null end
			,[MDI].[MtMonthlyMDI_MdiMonthExport]			=[IMDI].[InterfaceMtMonthlyMDI_MdiMonthExport]	
			,[MDI].[MtMonthlyMDI_MeterIdExport]				=[IMDI].[InterfaceMtMonthlyMDI_MeterIdExport]	
			,[MDI].[MtMonthlyMDI_DataSourceExport] 			=[IMDI].[InterfaceMtMonthlyMDI_DataSourceExport] 
			,[MDI].[MtMonthlyMDI_MeterQualifierExport]		=[IMDI].[InterfaceMtMonthlyMDI_MeterQualifierExport]
			,[MDI].[MtMonthlyMDI_DataLabelExport] 			=[IMDI].[InterfaceMtMonthlyMDI_DataLabelExport] 	
			,[MDI].[MtMonthlyMDI_DataStatusExport] 			=[IMDI].[InterfaceMtMonthlyMDI_DataStatusExport] 	
   		    ,[MDI].[MtMonthlyMDI_ModifiedBy]				=101
		    ,[MDI].[MtMonthlyMDI_ModifiedOn]				=GETUTCDATE()
		
FROM  [dbo].MtMonthlyMDI MDI
JOIN [dbo].InterfaceMtMonthlyMDI IMDI  ON MDI.RuCDPDetail_CdpId=IMDI.RuCDPDetail_CdpId
and MDI.MtMonthlyMDI_Month=IMDI.InterfaceMtMonthlyMDI_Month
and MDI.MtMonthlyMDI_Year=IMDI.InterfaceMtMonthlyMDI_Year
 
/*********************************************************************    
GET Metering master Info
*********************************************************************/ 
IF EXISTS(
SELECT top 1 InterfaceMtMonthlyMDI_Id
FROM
	[dbo].InterfaceMtMonthlyMDI
WHERE
	NOT EXISTS ( 
				SELECT 
					'X' 
				FROM
					[dbo].MtMonthlyMDI
				WHERE
					InterfaceMtMonthlyMDI_Month =MtMonthlyMDI_Month AND
					InterfaceMtMonthlyMDI_Year =MtMonthlyMDI_Year AND
					InterfaceMtMonthlyMDI.RuCDPDetail_CdpId=MtMonthlyMDI.RuCDPDetail_CdpId
				)

)  
BEGIN

 SELECT Top 1    
     @vMtMeteringImportInfo_Id=ISNUll(MtMDIImportInfo_Id,0)+1    
    ,@vLastImportDateInMMS=MtMDIImportInfo_ImportInMMSDate    
    ,@BatchNo=MtMDIImportInfo_BatchNo    
 FROM     
	[dbo].MtMDIImportInfo    
 order by
	MtMDIImportInfo_Id desc    


	
 IF(@vLastImportDateInMMS is null )    
      BEGIN    
   		SET @NewBatchNo=1    
      END    
 ELSE    
	 BEGIN    
		  
			SET @NewBatchNo = ISNULL(@BatchNo,0)+1    
		
	END    
    
	/*********************************************************************    
insert import master Information In MtMeteringImportInfo
*********************************************************************/    
    
 --if not exists (SELECT 1 FROM #ReadyForOpertaion)
 --BEGIN
	--return;
 --END
   
 INSERT INTO [dbo].MtMDIImportInfo    
           (MtMDIImportInfo_Id    
           ,MtMDIImportInfo_ImportInMMSDate    
           ,MtMDIImportInfo_BatchNo    
           ,[Interface_LastRecordId]    
           ,[Interface_LastRecordDate]    
           ,MtMDIImportInfo_CreatedBy    
           ,MtMDIImportInfo_CreatedOn    
           )    
     VALUES    
           (ISNULL(@vMtMeteringImportInfo_Id,1)    
           ,DATEADD(HOUR,5,GetUTCDATE())    
		   ,@NewBatchNo    
		   ,@vInterface_LastRecordId    
           ,@vInterface_LastRecordDate    
           ,1    
           ,DATEADD(HOUR,5,GetUTCDATE())    
           )  



/*********************************************************************  
Insert the new records which we save in temp table #NewRecords
*********************************************************************/

INSERT INTO [dbo].[MtMonthlyMDI]
           ([MtMDIImportInfo_Id]
           ,[RuCDPDetail_CdpId]
           ,[MtMonthlyMDI_Month]
           ,[MtMonthlyMDI_Year]
           ,[MtMonthlyMDI_DateTimeStampImport]
           ,[MtMonthlyMDI_MdiMonthImport]
           ,[MtMonthlyMDI_MeterIdImport]
           ,[MtMonthlyMDI_DataSourceImport]
           ,[MtMonthlyMDI_MeterQualifierImport]
           ,[MtMonthlyMDI_DataLabelImport]
           ,[MtMonthlyMDI_DataStatusImport]
           ,[MtMonthlyMDI_DateTimeStampExport]
           ,[MtMonthlyMDI_MdiMonthExport]
           ,[MtMonthlyMDI_MeterIdExport]
           ,[MtMonthlyMDI_DataSourceExport]
           ,[MtMonthlyMDI_MeterQualifierExport]
           ,[MtMonthlyMDI_DataLabelExport]
           ,[MtMonthlyMDI_DataStatusExport]
           ,[MtMonthlyMDI_CreatedBy]
           ,[MtMonthlyMDI_CreatedOn]
		   ,[MtMonthlyMDI_IsDeleted]
)


SELECT
		ISNULL(@vMtMeteringImportInfo_Id,1) 
      ,[RuCDPDetail_CdpId]
      ,[InterfaceMtMonthlyMDI_Month]
      ,[InterfaceMtMonthlyMDI_Year]
  --    ,[InterfaceMtMonthlyMDI_DateTimeStampImport]
	, case when ([InterfaceMtMonthlyMDI_DateTimeStampImport] is not NULL AND [InterfaceMtMonthlyMDI_DateTimeStampImport] <>'') then convert(DATETIME,[InterfaceMtMonthlyMDI_DateTimeStampImport],105) else null end
      ,[InterfaceMtMonthlyMDI_MdiMonthImport]
      ,[InterfaceMtMonthlyMDI_MeterIdImport]
      ,[InterfaceMtMonthlyMDI_DataSourceImport]
      ,[InterfaceMtMonthlyMDI_MeterQualifierImport]
      ,[InterfaceMtMonthlyMDI_DataLabelImport]
      ,[InterfaceMtMonthlyMDI_DataStatusImport]
--      ,[InterfaceMtMonthlyMDI_DateTimeStampExport]
	, case when ([InterfaceMtMonthlyMDI_DateTimeStampExport] is not NULL AND [InterfaceMtMonthlyMDI_DateTimeStampExport] <>'') then convert(DATETIME,[InterfaceMtMonthlyMDI_DateTimeStampExport],105) else null end
      ,[InterfaceMtMonthlyMDI_MdiMonthExport]
      ,[InterfaceMtMonthlyMDI_MeterIdExport]
      ,[InterfaceMtMonthlyMDI_DataSourceExport]
      ,[InterfaceMtMonthlyMDI_MeterQualifierExport]
      ,[InterfaceMtMonthlyMDI_DataLabelExport]
      ,[InterfaceMtMonthlyMDI_DataStatusExport]
      ,101
      ,[InterfaceMtMonthlyMDI_CreatedOn]
	  ,[InterfaceMtMonthlyMDI_IsDeleted]
FROM
	[dbo].InterfaceMtMonthlyMDI
WHERE
	NOT EXISTS ( 
				SELECT 
					'X' 
				FROM
					[dbo].MtMonthlyMDI
				WHERE
					InterfaceMtMonthlyMDI_Month =MtMonthlyMDI_Month AND
					InterfaceMtMonthlyMDI_Year =MtMonthlyMDI_Year AND
					InterfaceMtMonthlyMDI.RuCDPDetail_CdpId=MtMonthlyMDI.RuCDPDetail_CdpId
				)
	AND
		ISNULL(InterfaceMtMonthlyMDI_IsDeleted,0) = 0
					

/*********************************************************************  
Update the existing records from Interface table
*********************************************************************/


/*********************************************************************  
Insert the new records which we save in temp table #NewRecords
*********************************************************************/

/*********************************************************************  
Delete the records after import and update is complete
*********************************************************************/  

UPDATE 
	[dbo].InterfaceMtMonthlyMDI
SET 
	InterfaceMtMonthlyMDI_IsDeleted=1
WHERE 
	ISNULL(InterfaceMtMonthlyMDI_IsDeleted,0)=0


	TRUNCATE TABLE	[dbo].InterfaceMtMonthlyMDI

END  -- IF ENDS HERE ---------------------------------------------------------

END
