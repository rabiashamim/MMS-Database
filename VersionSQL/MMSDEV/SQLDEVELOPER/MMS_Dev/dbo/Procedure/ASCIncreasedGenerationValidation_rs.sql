/****** Object:  Procedure [dbo].[ASCIncreasedGenerationValidation_rs]    Committed by VersionSQL https://www.versionsql.com ******/

            
            
--exec [dbo].[ASCIncreasedGenerationValidation] 295,100              
CREATE PROCEDURE  [dbo].[ASCIncreasedGenerationValidation_rs]                  
@MtSOFileMaster_Id DECIMAL(18,0),                  
@userID DECIMAL(18,0),        
@SettlementMonth varchar(16)        
AS                  
BEGIN            
        
  declare @month varchar(16)        
   select @month=LuAccountingMonth_Month from LuAccountingMonth   where LuAccountingMonth_MonthName=@SettlementMonth         
                                                                    and LuAccountingMonth_IsDeleted=0        
      
UPDATE  MDI              
SET              
MDI.MtAscIG_Message=              
   CASE WHEN ISDATE(MtAscIG_Date)=0 THEN  'Date is not valid, ' else '' end              
  +CASE WHEN ISNULL(MtGenerationUnit_Id,'')='' THEN  'Generation  Unit is not valid, ' else '' end              
  +CASE WHEN ISNUMERIC(MtAscIG_Hour)=0   THEN  'Hour is not valid, ' else '' end              
  +CASE WHEN ISNUMERIC(MtAscIG_Hour)=1 and (ISNULL(cast (MtAscIG_Hour as decimal(18,2)),0)<0 OR ISNULL(cast (MtAscIG_Hour as decimal(18,2)),0)>23)    THEN  'Hour must be between 0-23, ' else '' end              
  +CASE WHEN ISNUMERIC(EnergyProduceIfNoAncillaryServices)=0  THEN  'Expected Energy is missing, ' else '' end              
  +CASE WHEN ISNUMERIC(MtAscIG_VariableCost)=0  THEN  'Variable Cost is missing, ' else '' end         
  +CASE WHEN month(MtAscIG_Date)!=@month THEN  'Date should be of selected settlement month only, ' else '' end            
FROM              
 MtAscIG_Interface MDI              
WHERE              
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id              
              
              
SELECT distinct MtGenerationUnit_SOUnitId into #tempGU FROM MtGenerationUnit              
WHERE ISNULL(isDeleted,0)=0              
              
              
UPDATE  MDI              
SET              
MDI.MtAscIG_Message=MDI.MtAscIG_Message+ 'Generation Unit does not exist,'              
FROM              
 MtAscIG_Interface MDI              
WHERE              
 MDI.MtSOFileMaster_Id=  @MtSOFileMaster_Id            
AND ISNULL(MDI.MtAscIG_IsDeleted,0)=0      
AND MDI.MtGenerationUnit_Id not in (SELECT cast(MtGenerationUnit_SOUnitId as varchar)FROm #tempGU  )               
              
              
               
UPDATE  MDI              
SET              
MDI.MtAscIG_Message=left(MtAscIG_Message,len(MtAscIG_Message)-1)          
FROM              
 MtAscIG_Interface MDI              
WHERE              
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id              
 and ISNULL(MDI.MtAscIG_Message,'')<>''              
 AND ISNULL(MDI.MtAscIG_IsDeleted,0)=0            
             
              
          
          
              
UPDATE  MDI              
SET              
MDI.MtAscIG_IsValid=0              
FROM              
 MtAscIG_Interface MDI              
WHERE              
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id              
 and ISNULL(MDI.MtAscIG_Message,'')<>''              
 AND ISNULL(MDI.MtAscIG_IsDeleted,0)=0              
              
              
DECLARE @vInvalidCount BIGINT=0;              
              
SELECT @vInvalidCount=COUNT(1)  FROM MtAscIG_Interface MDI              
WHERE              
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id              
 AND ISNULL(MDI.MtAscIG_IsDeleted,0)=0              
 AND MtAscIG_IsValid=0              
              
              
UPDATE MtSOFileMaster SET InvalidRecords= @vInvalidCount              
WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id              
END 
