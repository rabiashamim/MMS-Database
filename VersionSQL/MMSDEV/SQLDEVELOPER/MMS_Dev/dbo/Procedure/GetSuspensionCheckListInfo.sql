/****** Object:  Procedure [dbo].[GetSuspensionCheckListInfo]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GetSuspensionCheckListInfo  74          
          
CREATE PROCEDURE dbo.GetSuspensionCheckListInfo             
 @pMtPartyRegisteration_Id DECIMAL(18,2)          
AS            
BEGIN            
  declare    @LuStatus_Code_Approval char(4)    
    
  select @LuStatus_Code_Approval=   LuStatus_Code_Approval from MtPartyRegisteration where MtPartyRegisteration_Id=@pMtPartyRegisteration_Id    
    
Declare @MtRegisterationActivity_Id decimal(18,0)        
         
SELECT  TOP 1        
   @MtRegisterationActivity_Id = MtRegisterationActivity_Id        
FROM           
 MtRegisterationActivities         
WHERE         
     MtPartyRegisteration_Id=@pMtPartyRegisteration_Id         
    and MtRegisterationActivities_ACtion='SDRF'  
ORDER BY MtRegisterationActivity_Id DESC        
         
Select             
   REA.RuEventActionCheckList_Id             
 , REA.RuEventActionCheckList_Description            
 , REA.RuEventActionCheckList_SubType             
 , CASE WHEN ISNULL(EAC.EventActionCheckListInfo_Id,0)=0 then 0 else 1 end as IsChecked            
From            
 RuEventActionCheckList REA            
 LEFT JOIN EventActionCheckListInfo EAC ON EAC.RuEventActionCheckList_Id =  REA.RuEventActionCheckList_Id            
          AND EAC.MtRegisterationActivity_Id = @MtRegisterationActivity_Id        
        
WHERE            
 REA.RuEventActionCheckList_SubType='Reason' AND REA.RuEventActionCheckList_IsDeleted=0          
           
            
          
Select             
   REA.RuEventActionCheckList_Id             
 , REA.RuEventActionCheckList_Description            
 , REA.RuEventActionCheckList_SubType             
 , CASE WHEN ISNULL(EAC.EventActionCheckListInfo_Id,0)=0 then 0 else 1 end as IsChecked            
From            
 RuEventActionCheckList REA            
 LEFT JOIN EventActionCheckListInfo EAC ON EAC.RuEventActionCheckList_Id =  REA.RuEventActionCheckList_Id            
   AND EAC.MtRegisterationActivity_Id = @MtRegisterationActivity_Id        
WHERE            
 REA.RuEventActionCheckList_SubType='Action' AND REA.RuEventActionCheckList_IsDeleted=0           
            
           
SELECT Top 1           
 MtRegisterationActivity_Id          
,MtPartyRegisteration_Id          
,MtRegisterationActivities_Remarks      
,MtRegisterationActivities_Notes      
,MtRegisterationActivities_ApplicationNo          
,MtRegisterationActivities_ApplicationDate          
,MtRegisterationActivities_OrderDate          
,MtRegisterationActivities_OrderNo          
          
FROM MtRegisterationActivities             
WHERE            
MtRegisterationActivities_ACtion = 'SDRF'          
AND MtPartyRegisteration_Id=@pMtPartyRegisteration_Id          
order by MtRegisterationActivity_Id desc          
       
 ---------------------------------------Withdraw Information-------------------------      
      
SELECT Top 1           
 MtRegisterationActivity_Id          
,MtPartyRegisteration_Id          
,MtRegisterationActivities_Remarks      
,MtRegisterationActivities_Notes      
,MtRegisterationActivities_ApplicationNo          
,MtRegisterationActivities_ApplicationDate          
,MtRegisterationActivities_OrderDate          
,MtRegisterationActivities_OrderNo          
          
FROM MtRegisterationActivities             
WHERE            
MtRegisterationActivities_ACtion = 'WSPF'          
AND ref_Id=@MtRegisterationActivity_Id          
order by MtRegisterationActivity_Id desc       
          
---------------------------------------Termination Information-------------------------      
SELECT Top 1           
 MtRegisterationActivity_Id          
,MtPartyRegisteration_Id          
,MtRegisterationActivities_Remarks       
,MtRegisterationActivities_Notes      
,MtRegisterationActivities_ApplicationNo          
,MtRegisterationActivities_ApplicationDate          
,MtRegisterationActivities_OrderDate          
,MtRegisterationActivities_OrderNo          
          
FROM MtRegisterationActivities             
WHERE            
MtRegisterationActivities_ACtion = 'TERM'          
AND ref_Id=@MtRegisterationActivity_Id          
order by MtRegisterationActivity_Id desc      
    
---------------------------------------Modification Information-------------------------      
SELECT Top 1           
 MtRegisterationActivity_Id          
,MtPartyRegisteration_Id          
,MtRegisterationActivities_Remarks       
,MtRegisterationActivities_Notes      
,MtRegisterationActivities_ApplicationNo          
,MtRegisterationActivities_ApplicationDate          
,MtRegisterationActivities_OrderDate          
,MtRegisterationActivities_OrderNo          
          
FROM MtRegisterationActivities             
WHERE            
MtRegisterationActivities_ACtion  IN('SMDR', 'SMPA')          
AND ref_Id=@MtRegisterationActivity_Id          
order by MtRegisterationActivity_Id desc       
      
      
END            
            
            
      
