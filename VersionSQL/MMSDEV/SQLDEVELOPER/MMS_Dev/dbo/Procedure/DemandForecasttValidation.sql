/****** Object:  Procedure [dbo].[DemandForecasttValidation]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  ALINA JAVED
-- CREATE date: 17 May 2023
-- Description: 
-- ============================================= 
-- dbo.DemandForecasttValidation  1027,1
 CREATE   PROCEDUREdbo.DemandForecasttValidation  
@MtSOFileMaster_Id DECIMAL(18,0),                          
@userID DECIMAL(18,0)             
AS                          
BEGIN    
                  
declare @val varchar(32);

UPDATE  MDF                      
SET                      
MDF.MTDemandForecast_Interface_Message=                      
   CASE      
    WHEN ISNULL(MDF.MTDemandForecast_Interface_Year, '') = ''     
     THEN 'Year cannot be empty.'
	      
    WHEN charindex('-',MDF.MTDemandForecast_Interface_Year)!=5     
  THEN 'Invalid Year. '
  WHEN len(MDF.MTDemandForecast_Interface_Year)-charindex('-',MDF.MTDemandForecast_Interface_Year) !=4     
  THEN 'Invalid Year. '
  WHEN EXISTS (
           SELECT MDF2.MTDemandForecast_Interface_Year
            FROM MTDemandForecast_Interface MDF2
            WHERE MDF2.MtSOFileMaster_Id = @MtSOFileMaster_Id
		and MDF2.MTDemandForecast_Interface_Year=MDF.MTDemandForecast_Interface_Year
		and MDF2.MtParty_Id=MDF.MtParty_Id
                AND ISNULL(MDF2.MTDemandForecast_Interface_IsDeleted, 0) = 0
            GROUP BY MDF2.MTDemandForecast_Interface_Year,MDF2.MtParty_Id
            HAVING COUNT(*) > 1
        ) THEN 'Duplicate Year.'
  else ''
  END                                                           
 --+CASE 
 -- WHEN MTDemandForecast_Interface_Max_Demand_during_peakhours_MW LIKE '%[^0-9]%' THEN 'Max Demand should not contain alphabets.'
 -- else ''
 -- end 
	+
	case
 WHEN ISNULL(MTDemandForecast_Interface_Max_Demand_during_peakhours_MW, '') = '' THEN 'Max_Demand value cannot be empty.'
    WHEN ISNUMERIC(MTDemandForecast_Interface_Max_Demand_during_peakhours_MW) = 0 THEN 'Max Demand should contain only numeric values.'
 --WHEN CAST(MTDemandForecast_Interface_Max_Demand_during_peakhours_MW AS decimal) < 0 THEN 'Max Demand should contain only positive values.'
 WHEN CONVERT(decimal, MTDemandForecast_Interface_Max_Demand_during_peakhours_MW) < 0 
     THEN 'Max Demand should contain only positive values.'
else ''	 
    END                         
	
  
  +CASE WHEN EXISTS (SELECT  
          pr.MtPartyRegisteration_Id  
         FROM MtPartyRegisteration pr  
          WHERE cast(MDF.MtParty_Id as varchar(256))= cast(pr.MtPartyRegisteration_Id  as varchar(256)  )              
         AND ISNULL(pr.isDeleted, 0) = 0)  THEN ''  
       ELSE 'Party Id does not exist. '  
      END  
   
                   
FROM                      
 MTDemandForecast_Interface MDF                      
WHERE                      
 MDF.MtSOFileMaster_Id=@MtSOFileMaster_Id                
                                 


UPDATE  MDF                      
SET                      
MDF.MTDemandForecast_Interface_Message=left(MTDemandForecast_Interface_Message,len(MTDemandForecast_Interface_Message)-1)                  
FROM                      
 MTDemandForecast_Interface MDF                      
WHERE                      
 MDF.MtSOFileMaster_Id=@MtSOFileMaster_Id                      
 and ISNULL(MDF.MTDemandForecast_Interface_Message,'')<>''                      
 AND ISNULL(MDF.MTDemandForecast_Interface_IsDeleted,0)=0          
                      
UPDATE  MDF                      
SET                      
MDF.MTDemandForecast_Interface_IsValid=0                      
FROM                      
 MTDemandForecast_Interface MDF                      
WHERE                      
 MDF.MtSOFileMaster_Id=@MtSOFileMaster_Id                      
 and ISNULL(MDF.MTDemandForecast_Interface_Message,'')<>''                      
 AND ISNULL(MDF.MTDemandForecast_Interface_IsDeleted,0)=0                      
          
IF EXISTS(SELECT 1 FROM MTDemandForecast_Interface WHERE MTDemandForecast_Interface_IsValid=0 and MtSOFileMaster_Id=@MtSOFileMaster_Id)                  
 BEGIN                   
 ;WITH CTE AS(                  
 SELECT MTDemandForecast_Interface_RowNumber,MTDemandForecast_Interface_IsValid,MTDemandForecast_Interface_Id,                   
 ROW_NUMBER() OVER(order by MTDemandForecast_Interface_IsValid,MTDemandForecast_Interface_RowNumber ) AS MTDemandForecast_RowNumber_new                    
 FROM MTDemandForecast_Interface WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id--                  
 )                  
                  
 UPDATE M                    
 SET MTDemandForecast_Interface_RowNumber = MTDemandForecast_RowNumber_new                    
 FROM MTDemandForecast_Interface M INNER JOIN CTE c on c.MTDemandForecast_Interface_Id=m.MTDemandForecast_Interface_Id                  
 WHERE m.MtSOFileMaster_Id=@MtSOFileMaster_Id--MtSOFileMaster_Id=277                  
                  
                  
 END                  
                                 
DECLARE @vInvalidCount BIGINT=0;                      
                      
SELECT @vInvalidCount=COUNT(1)  FROM MTDemandForecast_Interface MDF                      
WHERE                      
 MDF.MtSOFileMaster_Id=@MtSOFileMaster_Id                      
 AND ISNULL(MDF.MTDemandForecast_Interface_IsDeleted,0)=0                      
 AND MTDemandForecast_Interface_IsValid=0           
           
 DECLARE @vTotalRecords BIGINT = 0;          
          
  SELECT @vTotalRecords = COUNT(1) FROM MTDemandForecast_Interface maii          
  WHERE maii.MtSOFileMaster_Id = @MtSOFileMaster_Id          
  AND ISNULL(maii.MTDemandForecast_Interface_IsDeleted,0) = 0;          
                      
                      
UPDATE MtSOFileMaster SET InvalidRecords= @vInvalidCount , TotalRecords = @vTotalRecords                     
WHERE MtSOFileMaster_Id=@MtSOFileMaster_Id         
 SELECT @vInvalidCount, @vTotalRecords;           
END 
