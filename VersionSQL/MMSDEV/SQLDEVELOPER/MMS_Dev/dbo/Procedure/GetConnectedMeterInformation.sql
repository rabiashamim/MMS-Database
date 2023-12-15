/****** Object:  Procedure [dbo].[GetConnectedMeterInformation]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- GetConnectedMeterInformation 42,1,10                      
CREATE   Procedure dbo.GetConnectedMeterInformation                        
@pPartyCategoryId DECIMAL(18,0)= NULL      
,@pPageNumber INT        
,@pPageSize INT      
    
,@pGeneratorName NVARCHAR(MAX) = NULL      
,@pGenerationUnit NVARCHAR(MAX) = NULL    
    
     
    
,@pSOUnitId NVARCHAR(MAX) = NULL      
,@pCDPID NVARCHAR(MAX) = NULL      
,@pCDPName NVARCHAR(MAX) = NULL      
    
     
    
,@pOrderBy NVARCHAR(MAX) = NULL    
    
     
    
       
    
--,@pCDPName NVARCHAR(MAX) = '132kV Shorkot Line'       
    
,@pfilterOperator NVARCHAR(MAX) = NULL        
AS                
BEGIN                    
  
 /* commented by aliimran on 22 august 2023, Factory information is not showing as expected. Unit is showing instead of generator. logic is update bellow the comments 
Select                         
CM.MtConnectedMeter_Id,                        
CM.MtConnectedMeter_UnitId as GenerationUnitId,                
    
    
CDP.RuCDPDetail_EffectiveFromIPP as EffectiveFrom,                    
CDP.RuCDPDetail_EffectiveToIPP as EffectiveTo,                    
    
ROW_NUMBER() OVER(ORDER BY mtconnectedmeter_id) as mtConnectedMeterRowNumberId,      
G.MtGenerator_Name as GeneratorName,      
GU.MtGenerationUnit_SOUnitid as SOUnitId,      
(select        
case when MPC.SrCategory_Code='BPC' or MPC.SrCategory_Code='EBPC' Then G.MtGenerator_Name        
ELSE GU.MtGenerationUnit_UnitName END        
from MtPartyCategory MPC where MPC.MtPartyCategory_Id=CM.MtPartyCategory_Id) as GenerationUnit,        
    
    
CDP.RuCDPDetail_CdpId as CDPID,                        
CDP.RuCDPDetail_CdpName as CDPName,                        
CDP.RuCDPDetail_FromCustomer as FromCustomer,                        
CDP.RuCDPDetail_ToCustomer as ToCustomer,                        
(select top 1 MtPartyRegisteration_Name from MtPartyRegisteration WHERE  MtPartyRegisteration_id =CDP.RuCDPDetail_ConnectedToID) as ConnectedToName,                        
(select top 1 MtPartyRegisteration_Name from MtPartyRegisteration WHERE  MtPartyRegisteration_id =CDP.RuCDPDetail_ConnectedFromID) as ConnectedFromName ,                                   
    
CDP.RuCDPDetail_ConnectedToID as ConnectedTo,                        
CDP.RuCDPDetail_ConnectedFromID as ConnectedFrom,                        
ISNULL(CM.IsAssigned,1) AS IsAssigned                        
    
,TZ.MtTaxZone_Id                   
,TZ.MtTaxZone_Name                  
,CZ.MtCongestedZone_Id                  
,CZ.MtCongestedZone_Name                  
    
             into #innerTable      
from [dbo].[MtConnectedMeter] CM                      
JOIN [dbo].[RuCDPDetail]  CDP ON CDP.RuCDPDetail_Id = CM.MtCDPDetail_Id                      
LEFT JOIN [dbo].[MtGenerationUnit] GU ON GU.MtGenerationUnit_Id = CM.MtConnectedMeter_UnitId        
LEFT JOIN [dbo].[MtGenerator] G ON G.MtGenerator_Id =GU.MtGenerator_Id--CM.MtConnectedMeter_UnitId  /*RS20230420*/      
    
LEFT JOIN [dbo].[MtCongestedZone] CZ ON CZ.MtCongestedZone_Id =  CDP.RuCDPDetail_CongestedZoneID                 
LEFT JOIN [dbo].[MtTaxZone] TZ ON TZ.MtTaxZone_Id = CDP.RuCDPDetail_TaxZoneID                  
WHERE              
CM.MtPartyCategory_Id=@pPartyCategoryId                 
and ISNULL(CM.MtConnectedMeter_isDeleted,0)=0    
    
    */
   
 Select                         
CM.MtConnectedMeter_Id,                        
CM.MtConnectedMeter_UnitId as GenerationUnitId,                
    
    
CDP.RuCDPDetail_EffectiveFromIPP as EffectiveFrom,                    
CDP.RuCDPDetail_EffectiveToIPP as EffectiveTo,                    
    
ROW_NUMBER() OVER(ORDER BY mtconnectedmeter_id) as mtConnectedMeterRowNumberId,      
G.MtGenerator_Name as GeneratorName,      
GU.MtGenerationUnit_SOUnitid as SOUnitId,      
(select        
case when MPC.SrCategory_Code='BPC' or MPC.SrCategory_Code='EBPC' Then G.MtGenerator_Name        
ELSE GU.MtGenerationUnit_UnitName END        
from MtPartyCategory MPC where MPC.MtPartyCategory_Id=CM.MtPartyCategory_Id) as GenerationUnit,        
    
    
CDP.RuCDPDetail_CdpId as CDPID,                        
CDP.RuCDPDetail_CdpName as CDPName,                        
CDP.RuCDPDetail_FromCustomer as FromCustomer,                        
CDP.RuCDPDetail_ToCustomer as ToCustomer,                        
(select top 1 MtPartyRegisteration_Name from MtPartyRegisteration WHERE  MtPartyRegisteration_id =CDP.RuCDPDetail_ConnectedToID) as ConnectedToName,                        
(select top 1 MtPartyRegisteration_Name from MtPartyRegisteration WHERE  MtPartyRegisteration_id =CDP.RuCDPDetail_ConnectedFromID) as ConnectedFromName ,                                   
    
CDP.RuCDPDetail_ConnectedToID as ConnectedTo,                        
CDP.RuCDPDetail_ConnectedFromID as ConnectedFrom,                        
ISNULL(CM.IsAssigned,1) AS IsAssigned                        
    
,TZ.MtTaxZone_Id                   
,TZ.MtTaxZone_Name                  
,CZ.MtCongestedZone_Id                  
,CZ.MtCongestedZone_Name                  
    
           into #innerTable      
from [dbo].[MtConnectedMeter] CM                      
JOIN [dbo].[RuCDPDetail]  CDP ON CDP.RuCDPDetail_Id = CM.MtCDPDetail_Id                      
LEFT JOIN [dbo].[MtGenerationUnit] GU ON GU.MtGenerationUnit_Id = CM.MtConnectedMeter_UnitId        
LEFT JOIN [dbo].[MtGenerator] G ON G.MtGenerator_Id =GU.MtGenerator_Id--CM.MtConnectedMeter_UnitId  /*RS20230420*/      
    
LEFT JOIN [dbo].[MtCongestedZone] CZ ON CZ.MtCongestedZone_Id =  CDP.RuCDPDetail_CongestedZoneID                 
LEFT JOIN [dbo].[MtTaxZone] TZ ON TZ.MtTaxZone_Id = CDP.RuCDPDetail_TaxZoneID                  
WHERE              
CM.MtPartyCategory_Id=@pPartyCategoryId                 
and ISNULL(CM.MtConnectedMeter_isDeleted,0)=0  
 AND CM.MtPartyCategory_Id NOT IN (SELECT
		MtPartyCategory_Id
	FROM MtPartyCategory MPC
	WHERE MPC.SrCategory_Code in ('BPC','EBPC')
	AND ISNULL(MPC.isDeleted, 0) = 0
	AND MPC.MtPartyCategory_Id = @pPartyCategoryId)
UNION
SELECT
	CM.MtConnectedMeter_Id
   ,CM.MtConnectedMeter_UnitId AS GenerationUnitId
   ,CDP.RuCDPDetail_EffectiveFromIPP AS EffectiveFrom
   ,CDP.RuCDPDetail_EffectiveToIPP AS EffectiveTo
   ,ROW_NUMBER() OVER (ORDER BY MtConnectedMeter_Id) AS mtConnectedMeterRowNumberId
   ,G.MtGenerator_Name AS GeneratorName
   ,GU.MtGenerationUnit_SOUnitId AS SOUnitId
   ,(SELECT
			CASE
				WHEN MPC.SrCategory_Code = 'BPC' OR
					MPC.SrCategory_Code = 'EBPC' THEN G.MtGenerator_Name
				ELSE GU.MtGenerationUnit_UnitName
			END
		FROM MtPartyCategory MPC
		WHERE MPC.MtPartyCategory_Id = CM.MtPartyCategory_Id)
	AS GenerationUnit
   ,CDP.RuCDPDetail_CdpId AS CDPID
   ,CDP.RuCDPDetail_CdpName AS CDPName
   ,CDP.RuCDPDetail_FromCustomer AS FromCustomer
   ,CDP.RuCDPDetail_ToCustomer AS ToCustomer
   ,(SELECT TOP 1
			MtPartyRegisteration_Name
		FROM MtPartyRegisteration
		WHERE MtPartyRegisteration_Id = CDP.RuCDPDetail_ConnectedToID)
	AS ConnectedToName
   ,(SELECT TOP 1
			MtPartyRegisteration_Name
		FROM MtPartyRegisteration
		WHERE MtPartyRegisteration_Id = CDP.RuCDPDetail_ConnectedFromID)
	AS ConnectedFromName
   ,CDP.RuCDPDetail_ConnectedToID AS ConnectedTo
   ,CDP.RuCDPDetail_ConnectedFromID AS ConnectedFrom
   ,ISNULL(CM.IsAssigned, 1) AS IsAssigned
   ,TZ.MtTaxZone_Id
   ,TZ.MtTaxZone_Name
   ,CZ.MtCongestedZone_Id
   ,CZ.MtCongestedZone_Name

FROM [dbo].[MtConnectedMeter] CM

JOIN [dbo].[RuCDPDetail] CDP
	ON CDP.RuCDPDetail_Id = CM.MtCDPDetail_Id
LEFT JOIN [dbo].[MtGenerationUnit] GU
	ON GU.MtGenerationUnit_Id = CM.MtConnectedMeter_UnitId
LEFT JOIN [dbo].[MtGenerator] G
	ON G.MtGenerator_Id = CM.MtConnectedMeter_UnitId 
LEFT JOIN [dbo].[MtCongestedZone] CZ
	ON CZ.MtCongestedZone_Id = CDP.RuCDPDetail_CongestedZoneID
LEFT JOIN [dbo].[MtTaxZone] TZ
	ON TZ.MtTaxZone_Id = CDP.RuCDPDetail_TaxZoneID
WHERE CM.MtPartyCategory_Id = @pPartyCategoryId                 
AND ISNULL(CM.MtConnectedMeter_isDeleted, 0) = 0
AND CM.MtPartyCategory_Id IN (SELECT
		MtPartyCategory_Id
	FROM MtPartyCategory MPC
	WHERE MPC.SrCategory_Code in ('BPC','EBPC')
	AND ISNULL(MPC.isDeleted, 0) = 0
	AND MPC.MtPartyCategory_Id = @pPartyCategoryId); 
	


select * INTO #RESULT from       
#innerTable    
where mtConnectedMeterRowNumberId > ((@pPageNumber - 1) * @pPageSize)       
AND mtConnectedMeterRowNumberId <= (@pPageNumber * @pPageSize)      
AND (@pGeneratorName IS NULL OR GeneratorName LIKE ('%' + @pGeneratorName + '%'))      
AND (@pGenerationUnit IS NULL  OR GenerationUnit LIKE ('%' + @pGenerationUnit + '%'))    
AND (@pSOUnitId IS NULL  OR SOUnitId LIKE ('%' + @pSOUnitId + '%'))      
AND (@pCDPID IS NULL  OR CDPID LIKE ('%' + @pCDPID + '%'))      
AND (@pCDPName IS NULL  OR CDPName LIKE ('%' + @pCDPName + '%'))      
    
     
    
--order by innerTable.GeneratorName asc'      
    
DECLARE @QUERY NVARCHAR(MAX)    
    
IF(@pOrderBy is NULL)    
BEGIN    
SET @QUERY='SELECT * FROM #RESULT'    
END    
ELSE    
BEGIN    
SET @QUERY='SELECT * FROM #RESULT ORDER BY '+ @pOrderBy    
END     
    
EXEC (@QUERY)     
    
SELECT COUNT(1) as TotalRows FROM       
#innerTable      
WHERE  (@pGeneratorName IS NULL OR GeneratorName LIKE ('%' + @pGeneratorName + '%'))      
AND (@pGenerationUnit IS NULL  OR GenerationUnit LIKE ('%' + @pGenerationUnit + '%'))      
AND (@pSOUnitId IS NULL  OR SOUnitId LIKE ('%' + @pSOUnitId + '%'))      
AND (@pCDPID IS NULL  OR CDPID LIKE ('%' + @pCDPID + '%'))      
AND (@pCDPName IS NULL  OR CDPName LIKE ('%' + @pCDPName + '%'))                      
END 
