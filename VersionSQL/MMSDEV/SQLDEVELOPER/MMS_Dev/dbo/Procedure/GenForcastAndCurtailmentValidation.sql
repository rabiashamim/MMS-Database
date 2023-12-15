/****** Object:  Procedure [dbo].[GenForcastAndCurtailmentValidation]    Committed by VersionSQL https://www.versionsql.com ******/

-- dbo.GenForcastAndCurtailmentValidation  600,1
 CREATE  procedure dbo.GenForcastAndCurtailmentValidation  
@MtSOFileMaster_Id DECIMAL(18,0),                          
@userID DECIMAL(18,0)             
AS                          
BEGIN    
    
  DECLARE @vfiscalyearstart Date;      
  DECLARE @vfiscalyearend Date;      
      
  SELECT      
   @vfiscalyearstart = lam.LuAccountingMonth_FromDate,      
   @vfiscalyearend=lam.LuAccountingMonth_ToDate      
  FROM MtSOFileMaster msm      
  INNER JOIN LuAccountingMonth lam      
   ON msm.LuAccountingMonth_Id = lam.LuAccountingMonth_Id      
  WHERE msm.MtSOFileMaster_Id = @MtSOFileMaster_Id      
  AND ISNULL(lam.LuAccountingMonth_IsDeleted, 0) = 0      
  AND ISNULL(msm.MtSOFileMaster_IsDeleted, 0) = 0;      
    
  --select * from MtSOFileMaster where MtSOFileMaster_Id=954    
  --select * from LuAccountingMonth where LuAccountingMonth_Id=39    
    
    
    
UPDATE  MDI                      
SET                      
MDI.MTGenForcastAndCurtailment_Interface_Message=                      
   CASE      
    WHEN ISNULL(MDI.MTGenForcastAndCurtailment_Interface_Date, '') = ''     
     THEN 'Date cannot be empty.'       
    WHEN ISDATE(MDI.MTGenForcastAndCurtailment_Interface_Date) = 0     
  THEN 'Invalid Date'      
       WHEN MDI.MTGenForcastAndCurtailment_Interface_Date>=@vfiscalyearstart and MDI.MTGenForcastAndCurtailment_Interface_Date<=@vfiscalyearend     
  THEN ''      
 ELSE 'Date should be of selected Fiscal year only.'       
  END                                 
  +CASE WHEN ISNUMERIC(MTGenForcastAndCurtailment_Interface_Hour)=0   THEN  'Hour is not valid, ' else '' end                      
  +CASE WHEN ISNUMERIC(MTGenForcastAndCurtailment_Interface_Hour)=1 and (ISNULL(cast(MTGenForcastAndCurtailment_Interface_Hour as decimal(10,2)),0)<0 OR ISNULL(cast(MTGenForcastAndCurtailment_Interface_Hour as decimal(10,2)),0)>23)    THEN  'Hour must be 
  
between 0-23, ' else '' end                          
 +CASE when MTGenForcastAndCurtailment_Interface_Forecast_MW is null then ''   
   WHEN ISNUMERIC(MTGenForcastAndCurtailment_Interface_Forecast_MW)=0 
   THEN  'Forecast data should be in numbers, ' 
   ELSE '' END                      
  
    +
	CASE 
	when MTGenForcastAndCurtailment_Interface_Curtailemnt_MW is null then ''   
   WHEN ISNUMERIC(MTGenForcastAndCurtailment_Interface_Curtailemnt_MW)=0  THEN  'Curtailment data should be in numbers, ' 
   ELSE ''
   END  
  
  +CASE WHEN EXISTS (SELECT  
          mg.MtGenerator_Id  
         FROM MtGenerator mg  
          WHERE cast(MDI.MtGenerator_Id as varchar(256))= cast(mg.MtGenerator_Id  as varchar(256)  )              
         AND ISNULL(mg.isDeleted, 0) = 0)  THEN ''  
       ELSE 'Generator Id does not exist. '  
      END  
   
                   
FROM                      
 MTGenForcastAndCurtailment_Interface MDI                      
WHERE                      
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id                
                                 
 /*********************************************************
 Avoid repeating hours	 *******************************
 **********************************************************/
update MDI
SET MTGenForcastAndCurtailment_Interface_Message=MTGenForcastAndCurtailment_Interface_Message+'Data for this Hour is repeating. '

from MTGenForcastAndCurtailment_Interface MDI
WHERE MTGenForcastAndCurtailment_Interface_Id in (
select min(MTGenForcastAndCurtailment_Interface_Id)
from MTGenForcastAndCurtailment_Interface MDI
WHERE                      
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id 
group by
MtSOFileMaster_Id,MTGenForcastAndCurtailment_Interface_Date,	MTGenForcastAndCurtailment_Interface_Hour, MtGenerator_Id
having count(1)>1
)
 /*********************************************************
 Avoid repeating hours	 *******************************
 **********************************************************/

UPDATE  MDI                      
SET                      
MDI.MTGenForcastAndCurtailment_Interface_Message=left(MTGenForcastAndCurtailment_Interface_Message,len(MTGenForcastAndCurtailment_Interface_Message)-1)                  
FROM                      
 MTGenForcastAndCurtailment_Interface MDI                      
WHERE                      
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id                      
 and ISNULL(MDI.MTGenForcastAndCurtailment_Interface_Message,'')<>''                      
 AND ISNULL(MDI.MTGenForcastAndCurtailment_IsDeleted,0)=0          
                      
UPDATE  MDI                      
SET                      
MDI.MTGenForcastAndCurtailment_Interface_IsValid=0                      
FROM                      
 MTGenForcastAndCurtailment_Interface MDI                      
WHERE                      
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id                      
 and ISNULL(MDI.MTGenForcastAndCurtailment_Interface_Message,'')<>''                      
 AND ISNULL(MDI.MTGenForcastAndCurtailment_IsDeleted,0)=0                      
          
IF EXISTS(SELECT 1 FROM MTGenForcastAndCurtailment_Interface WHERE MTGenForcastAndCurtailment_Interface_IsValid=0 and  MtSOFileMaster_Id=@MtSOFileMaster_Id)                  
 BEGIN                   
 ;WITH CTE AS(                  
 SELECT MTGenForcastAndCurtailment_Interface_RowNumber,MTGenForcastAndCurtailment_Interface_IsValid,MTGenForcastAndCurtailment_Interface_Id,                   
 ROW_NUMBER() OVER(order by MTGenForcastAndCurtailment_Interface_IsValid,MTGenForcastAndCurtailment_Interface_RowNumber ) AS MTGenForcastAndCurtailment_RowNumber_new                    
 FROM MTGenForcastAndCurtailment_Interface WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id--                  
 )                  
                  
 UPDATE M                    
 SET MTGenForcastAndCurtailment_Interface_RowNumber = MTGenForcastAndCurtailment_RowNumber_new                    
 FROM MTGenForcastAndCurtailment_Interface M INNER JOIN CTE c on c.MTGenForcastAndCurtailment_Interface_Id=m.MTGenForcastAndCurtailment_Interface_Id                  
 WHERE m.MtSOFileMaster_Id=@MtSOFileMaster_Id--MtSOFileMaster_Id=277                  
                  
                  
 END                  
                                 
DECLARE @vInvalidCount BIGINT=0;                      
                      
SELECT @vInvalidCount=COUNT(1)  FROM MTGenForcastAndCurtailment_Interface MDI                      
WHERE                      
 MDI.MtSOFileMaster_Id=@MtSOFileMaster_Id                      
 AND ISNULL(MDI.MTGenForcastAndCurtailment_IsDeleted,0)=0                      
 AND MTGenForcastAndCurtailment_Interface_IsValid=0           
           
 DECLARE @vTotalRecords BIGINT = 0;          
          
  SELECT @vTotalRecords = COUNT(1) FROM MTGenForcastAndCurtailment_Interface maii          
  WHERE maii.MtSOFileMaster_Id = @MtSOFileMaster_Id          
  AND ISNULL(maii.MTGenForcastAndCurtailment_IsDeleted,0) = 0;          
                      
                      
UPDATE MtSOFileMaster SET InvalidRecords= @vInvalidCount , TotalRecords = @vTotalRecords                     
WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id         
 SELECT @vInvalidCount, @vTotalRecords;           
END 
