/****** Object:  Procedure [dbo].[ImportInMMSMeteringBVMData]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Ali Imran
--Reviewer : <>
--CreatedDate : 15 Feb 2022
--Comments : Import Metering BVM Reading tables
--======================================================================

CREATE PROCEDURE [dbo].[ImportInMMSMeteringBVMData]    
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
Get Last interface table record so that we can use this info  
[MTMeteringInmportInfo while] saving the import info.
*********************************************************************/
SELECT TOP 1    
	  @vInterface_LastRecordId =InterfaceMtBvmReading_Id    
	 ,@vInterface_LastRecordDate=InterfaceMtBvmReadingIntf_NtdcDateTime    
FROM     
	  [dbo].[InterfaceMtBvmReading]    
WHERE     
	  ISNULL(InterfaceMtBvmReading_IsDeleted,0)=0    
ORDER BY    
	InterfaceMtBvmReading_Id DESC    
 
 /*********************************************************************    
settings hours
*********************************************************************/

SELECT   InterfaceMtBvmReadingIntf_NtdcDateTime,

		 
		 CASE WHEN  DATEPART(MINUTE, InterfaceMtBvmReadingIntf_NtdcDateTime) > 0 then   DATEPART(HOUR, InterfaceMtBvmReadingIntf_NtdcDateTime)+1 
		 WHEN  DATEPART(Hour, InterfaceMtBvmReadingIntf_NtdcDateTime) = 0 then   24 
		 else DATEPART(HOUR, InterfaceMtBvmReadingIntf_NtdcDateTime)
		 end as ReadingHour
		
		,CASE WHEN   DATEPART(Hour, InterfaceMtBvmReadingIntf_NtdcDateTime) = 0 and DATEPART(MINUTE, InterfaceMtBvmReadingIntf_NtdcDateTime) = 0 
					 THEN CAST( DATEADD(Day,-1,InterfaceMtBvmReadingIntf_NtdcDateTime) AS DATE) 
					 else CAST(InterfaceMtBvmReadingIntf_NtdcDateTime AS DATE)  
		END
		AS
		ReadingDate
		,InterfaceRuCDPDetail_CdpId 
		, InterfaceRuCdpMeters_MeterIdImport 
		,InterfaceMtBvmReading_IncEnergyImport 
		,InterfaceMtBvmReading_DataSourceImport
		,InterfaceMtBvmReading_MeterQualifierImport
		,InterfaceRuCdpMeters_MeterIdExport 
		,InterfaceMtBvmReading_IncEnergyExport
		,InterfaceMtBvmReading_DataSourceExport 
		,InterfaceMtBvmReading_MeterQualifierExport
		,InterfaceMtBvmReading_IsDeleted
into #temp0    
FROM    
	  [dbo].[InterfaceMtBvmReading] IBR  

/*********************************************************************    
Convert half hourly info from interface table to hourly info and save in
#temp table.
*********************************************************************/
SELECT     
		 Min(InterfaceMtBvmReadingIntf_NtdcDateTime) AS ReadingDateTime      
		,InterfaceRuCDPDetail_CdpId AS CdpId    
		, InterfaceRuCdpMeters_MeterIdImport AS MeterIdImport    
		,SUM(InterfaceMtBvmReading_IncEnergyImport) AS EnergyImport    
		,InterfaceMtBvmReading_DataSourceImport AS DateSourceImport     
		,InterfaceMtBvmReading_MeterQualifierImport As MeterQualifierImport
		,InterfaceRuCdpMeters_MeterIdExport AS MeterIdExport    
		,SUM(InterfaceMtBvmReading_IncEnergyExport) AS EnergyExport     
		,InterfaceMtBvmReading_DataSourceExport AS DataSourceExport 
		,InterfaceMtBvmReading_MeterQualifierExport As MeterQualifierExport
		,ReadingDate
		,ReadingHour
INTO 
	  #temp    
FROM    
	  #temp0
WHERE     
	  ISNULL(InterfaceMtBvmReading_IsDeleted,0)=0    
GROUP BY     
	 InterfaceRuCDPDetail_CdpId    
    ,ReadingDate
    ,ReadingHour
   ,InterfaceRuCdpMeters_MeterIdImport    
   ,InterfaceMtBvmReading_DataSourceImport    
   ,InterfaceMtBvmReading_MeterQualifierImport    
   ,InterfaceRuCdpMeters_MeterIdExport    
   ,InterfaceMtBvmReading_DataSourceExport    
   ,InterfaceMtBvmReading_MeterQualifierExport
HAVING COUNT(ReadingDate)>1

/*********************************************************************    
If no record found in interface or temp table not need to move.
*********************************************************************/
    
  if not exists(select 1 from #temp)      
  BEGIN   
   Select '0' as response
   return;    
  END    

/*********************************************************************    
GET Metering master Info
*********************************************************************/ 
     
 SELECT Top 1    
     @vMtMeteringImportInfo_Id=ISNUll(MtMeteringImportInfo_Id,0)+1    
    ,@vLastImportDateInMMS=[MtMeteringImportInfo_ImportInMMSDate]    
    ,@BatchNo=MtMeteringImportInfo_BatchNo    
 FROM     
	[dbo].[MtMeteringImportInfo]    
 order by
	MtMeteringImportInfo_Id desc    

/*********************************************************************    
Generate Batch
*********************************************************************/ 

 IF(@vLastImportDateInMMS is null )    
      BEGIN    
   		SET @NewBatchNo=1    
      END    
 ELSE    
	 BEGIN    
		  
			SET @NewBatchNo = ISNULL(@BatchNo,0)+1    
		
	END    
    
 --select @vMtMeteringImportInfo_Id,@vLastImportDateInMMS as lastimportdate,@BatchNo,@NewBatchNo
 --return;
  


 /*********************************************************************    
 ROW_NUMBER added which we use as uique key for further prosessing
*********************************************************************/ 

select ROW_NUMBER() over(order by CdpId)as rn, * 
into #Interface
FROM #temp

 /*********************************************************************    
 find records in operational table IF already exists so that we can not insert again 
*********************************************************************/ 
  SELECT     rn
			,ReadingDateTime      
            ,CdpId    
            ,MeterIdImport    
            ,EnergyImport    
            ,DateSourceImport   
			,MeterQualifierImport
            ,MeterIdExport    
            ,EnergyExport     
            ,DataSourceExport   
			,MeterQualifierExport
			
	into #AlreadyExist
	FROM #Interface   t  
	JOIN [dbo].[MtBvmReading] BVM ON BVM.MtBvmReadingIntf_NtdcDateTime =t.ReadingDateTime
	and BVM.RuCDPDetail_CdpId=t.CdpId	



/*********************************************************************    
Exclude already exists record and final data in interface tables.
*********************************************************************/ 

select * 
into #ReadyForOpertaion
from
#Interface   
WHERE 
rn  not  in (select rn from #AlreadyExist)


/*********************************************************************    
insert import master Information In MtMeteringImportInfo
*********************************************************************/    
    
 if not exists (SELECT 1 FROM #ReadyForOpertaion)
 BEGIN
	return;
 END
   
 INSERT INTO [dbo].[MtMeteringImportInfo]    
           ([MtMeteringImportInfo_Id]    
           ,[MtMeteringImportInfo_ImportInMMSDate]    
           ,[MtMeteringImportInfo_BatchNo]    
           ,[Interface_LastRecordId]    
           ,[Interface_LastRecordDate]    
           ,[MtMeteringImportInfo_CreatedBy]    
           ,[MtMeteringImportInfo_CreatedOn]    
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
insert  into operational table from interface table
*********************************************************************/ 
 
   INSERT INTO [dbo].[MtBvmReading]    
           (    
      MtMeteringImportInfo_Id    
           ,[MtBvmReadingIntf_NtdcDateTime]    
           ,[RuCDPDetail_CdpId]    
           ,[RuCdpMeters_MeterIdImport]    
           ,[MtBvmReading_IncEnergyImport]    
           ,[MtBvmReading_DataSourceImport]    
		   ,MtBvmReading_MeterQualifierImport
           ,[RuCdpMeters_MeterIdExport]    
           ,[MtBvmReading_IncEnergyExport]    
           ,[MtBvmReading_DataSourceExport]   
		   ,MtBvmReading_MeterQualifierExport
           ,[MtBvmReading_CreatedBy]    
           ,[MtBvmReading_CreatedOn] 
		   ,MtBvmReading_ReadingDate
		   ,MtBvmReading_ReadingHour
   )		
      SELECT     
			 @vMtMeteringImportInfo_Id    
			,ReadingDateTime      
            ,CdpId    
            ,MeterIdImport    
            ,EnergyImport    
            ,DateSourceImport 
			,MeterQualifierImport
            ,MeterIdExport    
            ,EnergyExport     
            ,DataSourceExport     
			,MeterQualifierExport
			,1    
			,DATEADD(HOUR,5,GetUTCDATE())    
			,ReadingDate
			,ReadingHour
	FROM #ReadyForOpertaion   t  
	



/*********************************************************************    
Once the record is insert in operational table we need to clean it
*********************************************************************/  

 -- Truncate Table  [dbo].[InterfaceMtBvmReading]     
  
    
    
END
