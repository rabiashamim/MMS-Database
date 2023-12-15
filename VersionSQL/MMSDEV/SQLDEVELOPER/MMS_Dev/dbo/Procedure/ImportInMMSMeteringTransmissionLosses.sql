/****** Object:  Procedure [dbo].[ImportInMMSMeteringTransmissionLosses]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--Reviewer : <>
--CreatedDate : 11 Jan 2023
--Comments : Import transmission losses data
--======================================================================

CREATE   PROCEDURE dbo.ImportInMMSMeteringTransmissionLosses    
AS    
BEGIN    
  DROP TABLE IF EXISTS #ReadyForOpertaion
  DROP TABLE IF EXISTS #temp0
  DROP TABLE IF EXISTS #temp
  DROP TABLE IF EXISTS #Interface
  DROP TABLE IF EXISTS #AlreadyExist
  
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
	  @vInterface_LastRecordId =InterfaceMtTransmissionLosses_Id    
	 ,@vInterface_LastRecordDate=InterfaceMtTransmissionLosses_NtdcDateTime    
FROM     
	  InterfaceMtTransmissionLosses   
WHERE     
	  ISNULL(InterfaceMtTransmissionLosses_IsDeleted,0)=0    
ORDER BY    
	InterfaceMtTransmissionLosses_Id DESC    
 
 /*********************************************************************    
settings hours
*********************************************************************/

SELECT   IBR.InterfaceMtTransmissionLosses_NtdcDateTime,
	 
		 CASE WHEN  DATEPART(MINUTE, IBR.InterfaceMtTransmissionLosses_NtdcDateTime) > 0 then   DATEPART(HOUR, IBR.InterfaceMtTransmissionLosses_NtdcDateTime)+1 
		 WHEN  DATEPART(Hour, IBR.InterfaceMtTransmissionLosses_NtdcDateTime) = 0 then   24 
		 else DATEPART(HOUR, IBR.InterfaceMtTransmissionLosses_NtdcDateTime)
		 end as ReadingHour
		
		,CASE WHEN   DATEPART(Hour, IBR.InterfaceMtTransmissionLosses_NtdcDateTime) = 0 and DATEPART(MINUTE, InterfaceMtTransmissionLosses_NtdcDateTime) = 0 
					 THEN CAST( DATEADD(Day,-1,InterfaceMtTransmissionLosses_NtdcDateTime) AS DATE) 
					 else CAST(InterfaceMtTransmissionLosses_NtdcDateTime AS DATE)  
		END
		AS
		ReadingDate
		,InterfaceMtTransmissionLosses_TspName 
		,InterfaceMtTransmissionLosses_importMWh
		,InterfaceMtTransmissionLosses_exportMWh
		,InterfaceMtTransmissionLosses_tranmissionLossMWh
		,InterfaceMtTransmissionLosses_IsDeleted
into #temp0    
FROM    
	  InterfaceMtTransmissionLosses IBR  
	  
	  
/*********************************************************************    
Convert half hourly info from interface table to hourly info and save in
#temp table.
*********************************************************************/
SELECT     
		 Min(InterfaceMtTransmissionLosses_NtdcDateTime) AS ReadingDateTime      
		,InterfaceMtTransmissionLosses_TspName AS InterfaceMtTransmissionLosses_TspName    
		, SUM(InterfaceMtTransmissionLosses_importMWh) AS InterfaceMtTransmissionLosses_importMWh    
		,SUM(InterfaceMtTransmissionLosses_exportMWh) AS InterfaceMtTransmissionLosses_exportMWh    
		,SUM(InterfaceMtTransmissionLosses_tranmissionLossMWh) AS InterfaceMtTransmissionLosses_tranmissionLossMWh     
		,ReadingDate
		,ReadingHour
INTO 
	  #temp    
FROM    
	  #temp0
WHERE     
	  ISNULL(InterfaceMtTransmissionLosses_IsDeleted,0)=0    
GROUP BY     
	 InterfaceMtTransmissionLosses_TspName    
    ,ReadingDate
    ,ReadingHour
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
     @vMtMeteringImportInfo_Id= ISNUll(MtTranmissionLossesImportInfo_Id,0)+1    
    ,@vLastImportDateInMMS=MtTranmissionLossesImportInfo_ImportInMMSDate    
    ,@BatchNo=MtTranmissionLossesImportInfo_BatchNo    
 FROM     
	[dbo].[MtTranmissionLossesImportInfo] 
 order by
	MtTranmissionLossesImportInfo_Id desc    

/*********************************************************************    
Generate Batch
*********************************************************************/ 

 IF(@vLastImportDateInMMS is null )    
      BEGIN    
   		SET @NewBatchNo=1    
		SET @vMtMeteringImportInfo_Id=1
      END    
 ELSE    
	 BEGIN    
		  
			SET @NewBatchNo = ISNULL(@BatchNo,0)+1    
		
	END    
   
 /*********************************************************************    
 ROW_NUMBER added which we use as uique key for further prosessing
*********************************************************************/ 

select ROW_NUMBER() over(order by InterfaceMtTransmissionLosses_TspName,ReadingDateTime)as rn, * 
into #Interface
FROM #temp

 /*********************************************************************    
 find records in operational table IF already exists so that we can not insert again 
*********************************************************************/ 
  SELECT     rn
			,ReadingDateTime      
            ,InterfaceMtTransmissionLosses_TspName    
            ,InterfaceMtTransmissionLosses_importMWh    
            ,InterfaceMtTransmissionLosses_exportMWh    
            ,InterfaceMtTransmissionLosses_tranmissionLossMWh     
			,ReadingDate
			,ReadingHour
		
	into #AlreadyExist
	FROM #Interface   t  
	JOIN [dbo].[MtTransmissionLosses] TL ON TL.MtTransmissionLosses_NtdcDateTime =t.ReadingDateTime
	and TL.MtTransmissionLosses_TspName=t.InterfaceMtTransmissionLosses_TspName



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


 if  exists (SELECT 1 FROM #ReadyForOpertaion)
 BEGIN
    

INSERT INTO [dbo].[MtTranmissionLossesImportInfo]
           ([MtTranmissionLossesImportInfo_ImportInMMSDate]
           ,[MtTranmissionLossesImportInfo_BatchNo]
           ,[Interface_LastRecordId]
           ,[Interface_LastRecordDate]
           ,[MtTranmissionLossesImportInfo_CreatedBy]
           ,[MtTranmissionLossesImportInfo_CreatedOn])
     VALUES    
           (DATEADD(HOUR,5,GetUTCDATE())    
		   ,@NewBatchNo    
		   ,@vInterface_LastRecordId    
           ,@vInterface_LastRecordDate    
           ,1    
           ,DATEADD(HOUR,5,GetUTCDATE())    
           )  

/*********************************************************************    
insert  into operational table from interface table
*********************************************************************/ 

INSERT INTO [dbo].[MtTransmissionLosses]
           (MtTranmissionLossesImportInfo_Id
		   ,MtTransmissionLosses_NtdcDateTime
           ,[MtTransmissionLosses_TspName]
           ,[MtTransmissionLosses_importMWh]
           ,[MtTransmissionLosses_exportMWh]
           ,[MtTransmissionLosses_tranmissionLossMWh]
           ,[MtTransmissionLosses_CreatedBy]
           ,[MtTransmissionLosses_CreatedOn]
           ,[MtTransmissionLosses_ReadingDate]
           ,[MtTransmissionLosses_ReadingHour])

      SELECT     
			 @vMtMeteringImportInfo_Id
			 ,ReadingDateTime      
            ,InterfaceMtTransmissionLosses_TspName    
            ,InterfaceMtTransmissionLosses_importMWh    
            ,InterfaceMtTransmissionLosses_exportMWh    
            ,InterfaceMtTransmissionLosses_tranmissionLossMWh     
			,1    
			,DATEADD(HOUR,5,GetUTCDATE())    
			,ReadingDate
			,ReadingHour
	FROM #ReadyForOpertaion   t  
	
	
 END
 ;

/*********************************************************************    
Update [MtBvmReading] Already Exists records
*********************************************************************/ 
IF EXISTS (SELECT 1 FROM #AlreadyExist)
BEGIN

UPDATE [dbo].[MtTransmissionLosses]
   SET [MtTransmissionLosses_importMWh] = AE.[InterfaceMtTransmissionLosses_importMWh]
      ,[MtTransmissionLosses_exportMWh] = AE.[InterfaceMtTransmissionLosses_exportMWh]
      ,[MtTransmissionLosses_tranmissionLossMWh] = AE.[InterfaceMtTransmissionLosses_tranmissionLossMWh]
      ,[MtTransmissionLosses_ModifiedOn] = GetDate()
      ,[MtTransmissionLosses_ModifiedBy] = 1
FROM [dbo].[MtTransmissionLosses] TL
JOIN #AlreadyExist AE ON AE.ReadingDateTime=TL.[MtTransmissionLosses_NtdcDateTime]
and TL.[MtTransmissionLosses_TspName]=AE.[InterfaceMtTransmissionLosses_TspName]
where 
TL.[MtTransmissionLosses_importMWh]<> AE.[InterfaceMtTransmissionLosses_importMWh] OR
TL.[MtTransmissionLosses_exportMWh]<> AE.[InterfaceMtTransmissionLosses_exportMWh] OR
TL.[MtTransmissionLosses_tranmissionLossMWh]<> AE.[InterfaceMtTransmissionLosses_tranmissionLossMWh] 
 

    
END
/*********************************************************************    
Once the record is insert in operational table we need to clean it
*********************************************************************/  

 Truncate Table  [dbo].[InterfaceMtTransmissionLosses]   
  
    


END
