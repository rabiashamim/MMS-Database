/****** Object:  Procedure [dbo].[ASCIncreasedGenerationValidation]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE   PROCEDURE  dbo.ASCIncreasedGenerationValidation                      
@MtSOFileMaster_Id DECIMAL(18,0),                      
@userID DECIMAL(18,0),            
@SettlementMonth varchar(16)            
AS                      
BEGIN                
            
  declare @month varchar(16)            
  declare @Year varchar(16)            
   select @month=LuAccountingMonth_Month from LuAccountingMonth   where LuAccountingMonth_MonthName=@SettlementMonth             
   select @Year=LuAccountingMonth_Year from LuAccountingMonth   where LuAccountingMonth_MonthName=@SettlementMonth             
    
          
UPDATE  MDI                  
SET                  
MDI.MtAscIG_Message=                  
   CASE WHEN ISDATE(MtAscIG_Date)=0 THEN  'Date is not valid, ' else '' end                  
  +CASE WHEN ISNULL(MtGenerationUnit_Id,'')='' THEN  'Generation  Unit is not valid, ' else '' end                  
  +CASE WHEN ISNUMERIC(MtAscIG_Hour)=0   THEN  'Hour is not valid, ' else '' end                  
  +CASE WHEN ISNUMERIC(MtAscIG_Hour)=1 and (ISNULL(cast(MtAscIG_Hour as decimal(10,2)),0)<0 OR ISNULL(cast(MtAscIG_Hour as decimal(10,2)),0)>23)    THEN  'Hour must be between 0-23, ' else '' end                  
  +CASE WHEN ISNUMERIC(EnergyProduceIfNoAncillaryServices)=0 AND MDI.EnergyProduceIfNoAncillaryServices <> '' THEN  'Expected Energy not in correct format, ' else '' end                  
  +CASE WHEN ISNUMERIC(MtAscIG_VariableCost)=0  THEN  'Variable Cost is missing, ' else '' end             
  +CASE WHEN ISDATE(MtAscIG_Date)=1 and month(MtAscIG_Date)!=@month THEN  'Date should be of selected settlement month only, ' else '' end       
  +CASE WHEN ISDATE(MtAscIG_Date)=1 and YEAR(MtAscIG_Date)!=@Year THEN  'Date should be of selected settlement year only, ' else ''      end           
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
AND MDI.MtGenerationUnit_Id not in (SELECT cast(MtGenerationUnit_SOUnitId as varchar(32)) FROm #tempGU  )                
                  
                  
                   
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
         
        
  IF EXISTS(SELECT 1 FROM MtAscIG_Interface WHERE MtAscIG_IsValid=0 and  MtSOFileMaster_Id=@MtSOFileMaster_Id)          
 BEGIN           
 ;WITH CTE AS(          
 SELECT MtAscIG_RowNumber,MtAscIG_IsValid,MtAscIG_Id,           
 ROW_NUMBER() OVER(order by MtAscIG_IsValid,MtAscIG_RowNumber ) AS MtAscIG_RowNumber_new            
 FROM MtAscIG_Interface WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id--          
 )          
          
 UPDATE M            
 SET MtAscIG_RowNumber = MtAscIG_RowNumber_new            
 FROM MtAscIG_Interface M INNER JOIN CTE c on c.MtAscIG_Id=m.MtAscIG_Id          
 WHERE m.MtSOFileMaster_Id=@MtSOFileMaster_Id--MtSOFileMaster_Id=277          
          
          
 END          
          
        
        
        
               
                  
DECLARE @vInvalidCount BIGINT=0;                  
                  
SELECT @vInvalidCount=COUNT(1)  FROM MtAscIG_Interface MDI                  
WHERE                  
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id                  
 AND ISNULL(MDI.MtAscIG_IsDeleted,0)=0              
 AND MtAscIG_IsValid=0      
     
 DECLARE @vTotalRecords BIGINT = 0;    
    
  SELECT @vTotalRecords = COUNT(1) FROM MtAscIG_Interface maii    
  WHERE maii.MtSOFileMaster_Id = @MtSOFileMaster_Id    
  AND ISNULL(maii.MtAscIG_IsDeleted,0) = 0;    
                  
                  
UPDATE MtSOFileMaster SET InvalidRecords= @vInvalidCount , TotalRecords = @vTotalRecords                 
WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id    
 SELECT @vInvalidCount, @vTotalRecords;   
END 
