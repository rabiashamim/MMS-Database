/****** Object:  Procedure [dbo].[FCD_GetProcessSteps]    Committed by VersionSQL https://www.versionsql.com ******/

  
--dbo.FCD_GetProcessSteps  7 
CREATE   PROCEDURE dbo.FCD_GetProcessSteps      
@pMtFCDMaster decimal(18,0)   =0  ,
@pSrFCDProcessDef_Id int=0
  
AS      
BEGIN      
  
  select 
  RuStep.[RuFCDStepDef_ID]  as RuStepDef_Id
, Concat('Step ' ,cast(cast([RuFCDStepDef_FCDStepNo] as int) as varchar(10)) ,' ', RuStep.[RuFCDStepDef_Name] )as RuStepDef_Name
,  RuStep.[RuFCDStepDef_FCDStepNo] as RuStepDef_FCDStepNo
,  MtStep.[MtFCDProcessSteps_Status] as RuStepDef_Status
,  MtStep.[MtFCDProcessSteps_Description] as FCDProcessSteps_Description
  from 
   [dbo].[RuFCDStepDef] RuStep
   left join
  [dbo].[MtFCDProcessSteps] MtStep on RuStep.RuFCDStepDef_ID=MtStep.RuFCDStepDef_ID
  and MtStep.MtFCDMaster_ID=@pMtFCDMaster  and MtStep.SrFCDProcessDef_Id=@pSrFCDProcessDef_Id
  where ISNULL(RuFCDStepDef_IsDeleted,0)=0
  and isnull(MtFCDProcessSteps_IsDeleted,0)=0
  and RuStep.SrFCDProcessDef_Id=@pSrFCDProcessDef_Id

END
