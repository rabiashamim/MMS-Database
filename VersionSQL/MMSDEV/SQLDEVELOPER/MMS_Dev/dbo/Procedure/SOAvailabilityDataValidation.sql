/****** Object:  Procedure [dbo].[SOAvailabilityDataValidation]    Committed by VersionSQL https://www.versionsql.com ******/

--exec dbo.SOAvailabilityDataValidation 295,100            
CREATE   PROCEDURE  dbo.SOAvailabilityDataValidation                
@MtSOFileMaster_Id DECIMAL(18,0),                
@userID DECIMAL(18,0)                
AS                
BEGIN                
      
Declare @vAccountingMonth as int      
, @vAccountingYear as int      
      
select @vAccountingMonth=lam.LuAccountingMonth_Month,      
@vAccountingYear=lam.LuAccountingMonth_Year      
from MtSOFileMaster sfm      
inner join LuAccountingMonth lam on lam.LuAccountingMonth_Id=sfm.LuAccountingMonth_Id      
where sfm.MtSOFileMaster_Id=@MtSOFileMaster_Id      
          
UPDATE  MDI            
SET            
MDI.MtAvailibilityData_Message=            
   CASE WHEN ISDATE(MtAvailibilityData_Date)=0 THEN  'Date is not valid, ' else       
  CASE WHEN DATEPART(Month,MtAvailibilityData_Date)=@vAccountingMonth THEN '' ELSE 'Date should be of selected settlement month only, ' END+      
  CASE WHEN DATEPART(Year,MtAvailibilityData_Date)=@vAccountingYear THEN '' ELSE 'Date should be of selected settlement year only, ' END      
   end            
  +CASE WHEN ISNULL(MtGenerationUnit_Id,'')='' THEN  'Gen Unit is not valid, ' else '' end            
  +CASE WHEN ISNUMERIC(MtAvailibilityData_Hour)=0   THEN  'Hour is not valid, ' else '' end            
  +CASE WHEN ISNUMERIC(MtAvailibilityData_Hour)=1 and (ISNULL(cast(MtAvailibilityData_Hour as decimal(10,2)),0)<0 OR ISNULL(cast(MtAvailibilityData_Hour as decimal(10,2)),0)>23)    THEN  'Hour must be between 0-23, ' else '' end            
  +CASE WHEN ISNUMERIC(MtAvailibilityData_ActualCapacity)=0  THEN  'Actual Available Capacity is not valid, ' else '' end            
  +CASE WHEN ISNUMERIC(MtAvailibilityData_AvailableCapacityASC)=0  THEN  'Actual Capacity for ASC is not valid, ' else '' END
  
  +CASE WHEN MtAvailibilityData_SyncStatus NOT IN ('1','0') THEN  'Sync Status should be 1 or 0, ' else '' end
FROM            
 MtAvailibilityData_Interface MDI            
WHERE            
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id            
          
          
SELECT distinct MtGenerationUnit_SOUnitId into #tempGU FROM MtGenerationUnit            
WHERE ISNULL(isDeleted,0)=0            
            
            
UPDATE  MDI            
SET            
MDI.MtAvailibilityData_Message=MDI.MtAvailibilityData_Message+ 'Generation SO UnitId does not exist,'            
FROM            
 MtAvailibilityData_Interface MDI            
WHERE            
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id            
AND ISNULL(MDI.MtAvailibilityData_IsDeleted,0)=0            
AND MDI.MtGenerationUnit_Id not in (SELECT cast(MtGenerationUnit_SOUnitId as varchar(32)) FROm #tempGU  )             
            
            
            
UPDATE  MDI            
SET            
MDI.MtAvailibilityData_IsValid=0            
FROM            
 MtAvailibilityData_Interface MDI            
WHERE            
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id            
 and ISNULL(MDI.MtAvailibilityData_Message,'')<>''            
 AND ISNULL(MDI.MtAvailibilityData_IsDeleted,0)=0           
         
        
 IF EXISTS(SELECT 1 FROM MtAvailibilityData_Interface WHERE MtAvailibilityData_IsValid=0 and  MtSOFileMaster_Id=@MtSOFileMaster_Id)          
 BEGIN           
 ;WITH CTE AS(          
 SELECT MtAvailibilityData_RowNumber,MtAvailibilityData_IsValid,MtAvailibilityData_Id,           
 ROW_NUMBER() OVER(order by MtAvailibilityData_IsValid,MtAvailibilityData_RowNumber ) AS MtAvailibilityData_RowNumber_new            
 FROM MtAvailibilityData_Interface WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id--          
 )          
          
 UPDATE M            
 SET MtAvailibilityData_RowNumber = MtAvailibilityData_RowNumber_new            
 FROM MtAvailibilityData_Interface M INNER JOIN CTE c on c.MtAvailibilityData_Id=m.MtAvailibilityData_Id          
 WHERE m.MtSOFileMaster_Id=@MtSOFileMaster_Id--MtSOFileMaster_Id=277          
          
          
 END         
        
        
            
            
DECLARE @vInvalidCount BIGINT=0;            
            
SELECT @vInvalidCount=COUNT(1)  FROM MtAvailibilityData_Interface MDI            
WHERE            
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id            
 AND ISNULL(MDI.MtAvailibilityData_IsDeleted,0)=0            
 AND MtAvailibilityData_IsValid=0            
      
 DECLARE @vTotalRecords BIGINT = 0;      
      
SELECT @vTotalRecords = COUNT(1) FROM MtAvailibilityData_Interface  mbci      
WHERE mbci.MtSOFileMaster_Id = @MtSOFileMaster_Id      
AND ISNULL(mbci.MtAvailibilityData_IsDeleted,0) = 0;      
            
            
UPDATE MtSOFileMaster SET InvalidRecords= @vInvalidCount , TotalRecords = @vTotalRecords           
WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id     
select @vInvalidCount,@vTotalRecords  
END              
              
              
              
