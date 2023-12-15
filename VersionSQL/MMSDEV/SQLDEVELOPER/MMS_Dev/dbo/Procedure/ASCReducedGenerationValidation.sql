/****** Object:  Procedure [dbo].[ASCReducedGenerationValidation]    Committed by VersionSQL https://www.versionsql.com ******/

              
--exec [dbo].[ASCIncreasedGenerationValidation] 295,100                
CREATE   PROCEDURE  dbo.ASCReducedGenerationValidation                    
@MtSOFileMaster_Id DECIMAL(18,0),                    
@userID DECIMAL(18,0),          
@SettlementMonth varchar(16)          
AS                    
BEGIN              
          
  declare @month varchar(16)          
  , @year varchar(16)      
   select @month=LuAccountingMonth_Month, @year=LuAccountingMonth_Year from LuAccountingMonth   where LuAccountingMonth_MonthName=@SettlementMonth           
                                                                    and LuAccountingMonth_IsDeleted=0          
                    
UPDATE  MDI                
SET                
MDI.MtAscRG_Message=                
   CASE WHEN ISDATE(MtAscRG_Date)=0 THEN  'Date is not valid, ' else '' end                
  +CASE WHEN ISNULL(MtGenerationUnit_Id,'')='' THEN  'Generation  Unit is not valid, ' else '' end                
  +CASE WHEN ISNUMERIC(MtAscRG_Hour)=0   THEN  'Hour is not valid, ' else '' end                
  +CASE WHEN ISNUMERIC(MtAscRG_Hour)=1 and (ISNULL(cast(MtAscRG_Hour as decimal(10,2)),0)<0 OR ISNULL(cast(MtAscRG_Hour as decimal(10,2)),0)>23)    THEN  'Hour must be between 0-23, ' else '' end                    
  +CASE WHEN ISNUMERIC(MtAscRG_ExpectedEnergy)=0 AND MDI.MtAscRG_ExpectedEnergy <> ''  THEN  'Expected Energy not in correct format, ' ELSE '' END                
  +CASE WHEN ISNUMERIC(MtAscRG_VariableCost)=0  THEN  'Variable Cost is missing, ' else '' end             
    +CASE WHEN ISDATE(MtAscRG_Date)=1 and month(MtAscRG_Date)!=@month THEN  'Date should be of selected settlement month only, ' else '' end         
  +CASE WHEN ISDATE(MtAscRG_Date)=1 and YEAR(MtAscRG_Date)!=@Year THEN  'Date should be of selected settlement year only, ' else ''      end      
  +CASE WHEN isnull(GenerationUnitTypeARE,'') not in ('ARE','Thermal')  THEN  'Generation Unit Type must be ARE or Thermal, ' else '' end           
FROM                
 MtAscRG_Interface MDI                
WHERE                
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id          
     
    
                
SELECT distinct MtGenerationUnit_SOUnitId into #tempGU FROM MtGenerationUnit                
WHERE ISNULL(isDeleted,0)=0                
                
                
UPDATE  MDI                
SET                
MDI.MtAscRG_Message=MDI.MtAscRG_Message+ 'Generation Unit does not exist,'                
FROM                
 MtAscRG_Interface MDI                
WHERE                
 MDI.MtSOFileMaster_Id=  @MtSOFileMaster_Id              
AND ISNULL(MDI.MtAscRG_IsDeleted,0)=0                 
AND MDI.MtGenerationUnit_Id not in (SELECT cast(MtGenerationUnit_SOUnitId as varchar(32)) FROm #tempGU  )        
                
                
                 
UPDATE  MDI                
SET                
MDI.MtAscRG_Message=left(MtAscRG_Message,len(MtAscRG_Message)-1)            
FROM                
 MtAscRG_Interface MDI                
WHERE                
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id                
 and ISNULL(MDI.MtAscRG_Message,'')<>''                
 AND ISNULL(MDI.MtAscRG_IsDeleted,0)=0              
               
                
            
            
                
UPDATE  MDI                
SET                
MDI.MtAscRG_IsValid=0                
FROM                
 MtAscRG_Interface MDI                
WHERE                
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id                
 and ISNULL(MDI.MtAscRG_Message,'')<>''                
 AND ISNULL(MDI.MtAscRG_IsDeleted,0)=0                
    
IF EXISTS(SELECT 1 FROM MtAscRG_Interface WHERE MtAscRG_IsValid=0 and  MtSOFileMaster_Id=@MtSOFileMaster_Id)            
 BEGIN             
 ;WITH CTE AS(            
 SELECT MtAscRG_RowNumber,MtAscRG_IsValid,MtAscRG_Id,             
 ROW_NUMBER() OVER(order by MtAscRG_IsValid,MtAscRG_RowNumber ) AS MtAscRG_RowNumber_new              
 FROM MtAscRG_Interface WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id--            
 )            
            
 UPDATE M              
 SET MtAscRG_RowNumber = MtAscRG_RowNumber_new              
 FROM MtAscRG_Interface M INNER JOIN CTE c on c.MtAscRG_Id=m.MtAscRG_Id            
 WHERE m.MtSOFileMaster_Id=@MtSOFileMaster_Id--MtSOFileMaster_Id=277            
            
            
 END            
            
          
    
                
                
DECLARE @vInvalidCount BIGINT=0;                
                
SELECT @vInvalidCount=COUNT(1)  FROM MtAscRG_Interface MDI                
WHERE                
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id                
 AND ISNULL(MDI.MtAscRG_IsDeleted,0)=0                
 AND MtAscRG_IsValid=0     
     
 DECLARE @vTotalRecords BIGINT = 0;    
    
  SELECT @vTotalRecords = COUNT(1) FROM MtAscRG_Interface maii    
  WHERE maii.MtSOFileMaster_Id = @MtSOFileMaster_Id    
  AND ISNULL(maii.MtAscRG_IsDeleted,0) = 0;    
                
                
UPDATE MtSOFileMaster SET InvalidRecords= @vInvalidCount , TotalRecords = @vTotalRecords               
WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id   
 SELECT @vInvalidCount, @vTotalRecords;     
END 
