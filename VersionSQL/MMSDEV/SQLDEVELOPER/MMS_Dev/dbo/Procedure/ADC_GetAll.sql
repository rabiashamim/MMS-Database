/****** Object:  Procedure [dbo].[ADC_GetAll]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  ALI IMRAN
-- CREATE date: 7 march 2023
-- ALTER date: 
-- Description: 
-- ============================================= 
CREATE   PROCEDURE dbo.ADC_GetAll
@pADC_Id DECIMAL(18,0)=null
AS
BEGIN
SELECT ADC.[MtAnnualDependableCapacityADC_Id] AS ADC_Id
      ,ADC.[MtGenerator_Id] AS Generator_Id
	  ,G.MtGenerator_Name AS Generator_Name
	  ,G.COD_Date
      ,ADC.[MtAnnualDependableCapacityADC_Date] AS ADC_Date
      ,ADC.[MtAnnualDependableCapacityADC_Value] AS ADC_Value
      ,ADC.[MtAnnualDependableCapacityADC_CreatedOn] AS Created_Date
    
  FROM [dbo].[MtAnnualDependableCapacityADC] ADC
  JOIN MtGenerator G ON G.MtGenerator_Id=ADC.MtGenerator_Id
  WHERE MtAnnualDependableCapacityADC_IsDeleted=0
  AND ISNULL(G.isDeleted,0)=0
  AND @pADC_Id IS NULL OR ADC.[MtAnnualDependableCapacityADC_Id]=@pADC_Id
END
