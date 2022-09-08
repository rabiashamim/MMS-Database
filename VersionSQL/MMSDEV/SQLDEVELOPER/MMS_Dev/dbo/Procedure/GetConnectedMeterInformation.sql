/****** Object:  Procedure [dbo].[GetConnectedMeterInformation]    Committed by VersionSQL https://www.versionsql.com ******/

  
  -- GetConnectedMeterInformation 1107                
CREATE PROCEDURE [dbo].[GetConnectedMeterInformation]                  
 @pPartyCategoryId DECIMAL(18,0)= NULL
,@pPageNumber INT  
,@pPageSize INT

,@pGeneratorName NVARCHAR(MAX) = NULL
,@pGenerationUnit NVARCHAR(MAX) = NULL
 

--,@pCDPName NVARCHAR(MAX) = '132kV Shorkot Line' 

,@pfilterOperator NVARCHAR(MAX) = NULL  
AS          
BEGIN                  
select * from 
(
Select                   
CM.MtConnectedMeter_Id,                  
CM.MtConnectedMeter_UnitId as GenerationUnitId,          
    
    
CDP.RuCDPDetail_EffectiveFromIPP as EffectiveFrom,              
CDP.RuCDPDetail_EffectiveToIPP as EffectiveTo,              

ROW_NUMBER() OVER(ORDER BY mtconnectedmeter_id) as mtConnectedMeterRowNumberId,
--G.MtGenerator_Name as GenerationUnit,                  
--GU.MtGenerationUnit_UnitName as GenerationUnit1,    
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
            
             
from [dbo].[MtConnectedMeter] CM                  
JOIN [dbo].[RuCDPDetail]  CDP ON CDP.RuCDPDetail_Id = CM.MtCDPDetail_Id                  

--LEFT JOIN [dbo].[MtGenerationUnit] GU ON GU.MtGenerationUnit_Id = CM.MtConnectedMeter_UnitId    
--left JOIN [dbo].[MtGenerator] G ON G.MtGenerator_Id =CM.MtConnectedMeter_UnitId


LEFT JOIN [dbo].[MtGenerationUnit] GU ON GU.MtGenerationUnit_Id = CM.MtConnectedMeter_UnitId    
LEFT JOIN [dbo].[MtGenerator] G ON G.MtGenerator_Id =CASE WHEN (Select MPC.SrCategory_Code from MtPartyCategory MPC where MPC.MtPartyCategory_Id=CM.MtPartyCategory_Id) = 'BPC' 
     then CM.MtConnectedMeter_UnitId
     ELSE GU.MtGenerator_Id
end

--JOIN [dbo].[MtGenerator] G ON G.MtGenerator_Id =GU.MtGenerator_Id


		--JOIN [dbo].[MtGenerator] G
  --      ON G.MtGenerator_Id =GU.MtGenerator_Id
		--CASE 
  --         WHEN (Select MPC.SrCategory_Code from MtPartyCategory MPC where MPC.MtPartyCategory_Id=CM.MtPartyCategory_Id) = 'BPC' then CM.MtConnectedMeter_UnitId
		--   ELSE GU.MtGenerator_Id
  --         end
                  
LEFT JOIN [dbo].[MtCongestedZone] CZ ON CZ.MtCongestedZone_Id =  CDP.RuCDPDetail_CongestedZoneID           
LEFT JOIN [dbo].[MtTaxZone] TZ ON TZ.MtTaxZone_Id = CDP.RuCDPDetail_TaxZoneID            
WHERE        
CM.MtPartyCategory_Id=@pPartyCategoryId           
and ISNULL(CM.MtConnectedMeter_isDeleted,0)=0     
) innerTable
where mtConnectedMeterRowNumberId > ((@pPageNumber - 1) * @pPageSize) 
 AND mtConnectedMeterRowNumberId <= (@pPageNumber * @pPageSize)
 --AND ISNULL(GeneratorName,0) = ISNULL(@pGeneratorName,ISNULL(GeneratorName,0))
 --AND ISNULL(GenerationUnit,0) = ISNULL(@pGenerationUnit,ISNULL(GenerationUnit,0))
 AND (@pGeneratorName IS NULL OR innerTable.GeneratorName LIKE ('%' + @pGeneratorName + '%'))
 AND (@pGenerationUnit IS NULL  OR innerTable.GenerationUnit LIKE ('%' + @pGenerationUnit + '%'))
 

        
--order by innerTable.GeneratorName asc'



SELECT COUNT(1) as TotalRows FROM MtConnectedMeter WHERE MtPartyCategory_Id=@pPartyCategoryId and MtConnectedMeter_isDeleted=0    
                  
                  
END   
