/****** Object:  Procedure [dbo].[SaveSuspensionData]    Committed by VersionSQL https://www.versionsql.com ******/

        
CREATE PROCEDURE [dbo].[SaveSuspensionData]        
        
@pPartyRegisterationId DECIMAL(18,0),        
@pOrderId varchar(20)=null,        
@pOrderApprovedDate DATETIme =null,        
@pApplicationNo varchar(20)=null,        
@pApplicationDate DATETIme =null,        
@pOrderDateSuspension DATETIme =null,        
@pEventReasonCheckListCheckedValue varchar(100)=null,        
@pEventActionCheckListCheckedValue VARCHAR(100)=null,        
@pRemarks varchar(max)=null,        
@pNotes Varchar(max)=null,        
@pCase VARCHAR(30)=null,        
@pMtRegisterationActivity_Id DECIMAL(18,0)=NULL  ,      
@pMtRegisterationActivity_Id_Suspension DECIMAL(18,0)=NULL,     
@pMtRegisterationActivity_Id_Termination DECIMAL(18,0)=NULL    
,@pUserId int=null        
AS        
BEGIN        
        
---------------------------------------------------------------------------        
-----------------------------Suspension Drafted----------------------------        
---------------------------------------------------------------------------        
       
if (@pCase = 'Suspension Drafted')        
BEGIN        

DECLARE @vConnectedMPsCount1 int=0
select @vConnectedMPsCount1=count(1) from MtPartyRegisteration where MtPartyRegisteration_MPId=@pPartyRegisterationId and ISNULL(isDeleted,0)=0
and LuStatus_Code_Applicant not in ('ATER','DER')

if @vConnectedMPsCount1>0
BEGIN
select 'Please Reassign connected parties before terminating this party.' as errorMessage;
return ;
END

        
             IF @pMtRegisterationActivity_Id is NULL OR   @pMtRegisterationActivity_Id =0      
             BEGIN        
         
                      SELECT @pMtRegisterationActivity_Id= MAX(MtRegisterationActivity_Id)+1 FROM MtRegisterationActivities        
                              
                      INSERT INTO         
                       MtRegisterationActivities        
                          (        
                                        MtRegisterationActivity_Id        
                                       ,MtPartyRegisteration_Id        
                                       ,MtRegisterationActivities_ACtion        
                                       ,MtRegisterationActivities_ApplicationNo        
                                       ,MtRegisterationActivities_ApplicationDate        
                                       ,MtRegisterationActivities_Remarks
									   ,MtRegisterationActivities_Notes
                                       ,MtRegisterationActivities_CreatedBy        
                                       ,MtRegisterationActivities_Deleted    
            ,MtRegisterationActivities_OrderDate  
            ,MtRegisterationActivities_CreatedOn        
                                       )        
                      VALUES        
                                   (        
                                   @pMtRegisterationActivity_Id        
                                   ,@pPartyRegisterationId        
                                   ,'SDRF'        
                                   ,@pApplicationNo        
                                   , NULLIF(@pApplicationDate,'')        
                                   ,@pRemarks
								   ,@pNotes
                                   ,@pUserId        
                                   ,0     
           ,NULLIF(@pOrderApprovedDate,'')  
                                   ,GETUTCDATE()        
                                   )        
                        
      Update       
                   MtPartyRegisteration       
                  SET       
                   LuStatus_Code_Approval = 'SDRF'       
                  WHERE       
                  MtPartyRegisteration_Id = @pPartyRegisterationId      
        
   END        
---------------------------------------------------------------------------        
   IF @pMtRegisterationActivity_Id> 0        
   BEGIN        
     UPDATE MtRegisterationActivities        
     SET        
                       
                                        MtRegisterationActivities_ApplicationNo = ISNULL(@pApplicationNo ,MtRegisterationActivities_ApplicationNo)
                                       ,MtRegisterationActivities_ApplicationDate =ISNULL( @pApplicationDate ,MtRegisterationActivities_ApplicationDate)
                                       ,MtRegisterationActivities_Remarks =ISNULL(@pRemarks,MtRegisterationActivities_Remarks)
									   ,MtRegisterationActivities_Notes = ISNULL(@pNotes,MtRegisterationActivities_Notes)
                                       ,MtRegisterationActivities_ModifiedBy= @pUserId        
                                       ,MtRegisterationActivities_ModifiedOn = GETUTCDATE()  
									   ,MtRegisterationActivities_OrderDate=ISNULL(@pOrderApprovedDate  ,MtRegisterationActivities_OrderDate)
     WHERE         
      MtRegisterationActivity_Id = @pMtRegisterationActivity_Id        
      
    Update       
                   MtPartyRegisteration       
                  SET       
                   LuStatus_Code_Approval = 'SDRF'       
                  WHERE       
                  MtPartyRegisteration_Id = @pPartyRegisterationId      
      
   END        
        
--------------------------------------------------------------------------         
        
END    
    




---------------------------------------------------------------------------        
-----------------------------Withdraw Suspension Drafted----------------------------        
---------------------------------------------------------------------------        
       
if (@pCase = 'WithdrawSuspensionDraft')        
BEGIN        
     
             IF @pMtRegisterationActivity_Id is NULL OR   @pMtRegisterationActivity_Id =0      
             BEGIN        
            print('hit 1')
                      SELECT @pMtRegisterationActivity_Id= MAX(MtRegisterationActivity_Id)+1 FROM MtRegisterationActivities        
                              
                      INSERT INTO         
                       MtRegisterationActivities        
                          (        
                                        MtRegisterationActivity_Id        
                                       ,MtPartyRegisteration_Id        
                                       ,MtRegisterationActivities_ACtion        
                                       ,MtRegisterationActivities_ApplicationNo        
                                       ,MtRegisterationActivities_ApplicationDate        
                                       ,MtRegisterationActivities_Remarks
									   ,MtRegisterationActivities_Notes
                                       ,MtRegisterationActivities_CreatedBy        
                                       ,MtRegisterationActivities_Deleted    
            ,MtRegisterationActivities_OrderDate  
            ,MtRegisterationActivities_CreatedOn        
                                       )        
                      VALUES        
                                   (        
                                   @pMtRegisterationActivity_Id        
                                   ,@pPartyRegisterationId        
                                   ,'WSDR'        
                                   ,@pApplicationNo        
                                   , NULLIF(@pApplicationDate,'')        
                                   ,@pRemarks
								   ,@pNotes
                                   ,@pUserId        
                                   ,0     
           ,NULLIF(@pOrderApprovedDate,'')  
                                   ,GETUTCDATE()        
                                   )        
                        
      Update       
                   MtPartyRegisteration       
                  SET       
                   LuStatus_Code_Approval = 'WSDR'       
                  WHERE       
                  MtPartyRegisteration_Id = @pPartyRegisterationId      
        
   END        
---------------------------------------------------------------------------        
   IF @pMtRegisterationActivity_Id> 0        
   BEGIN        
      print('hite 2')
     UPDATE MtRegisterationActivities        
     SET        
                       
                                        MtRegisterationActivities_ApplicationNo = ISNULL(@pApplicationNo ,MtRegisterationActivities_ApplicationNo)
                                       ,MtRegisterationActivities_ApplicationDate =ISNULL( @pApplicationDate ,MtRegisterationActivities_ApplicationDate)
                                       ,MtRegisterationActivities_Remarks =ISNULL(@pRemarks,MtRegisterationActivities_Remarks)
									   ,MtRegisterationActivities_Notes = ISNULL(@pNotes,MtRegisterationActivities_Notes)
                                       ,MtRegisterationActivities_ModifiedBy= @pUserId        
                                       ,MtRegisterationActivities_ModifiedOn = GETUTCDATE()  
									   ,MtRegisterationActivities_OrderDate=ISNULL(@pOrderApprovedDate  ,MtRegisterationActivities_OrderDate)
     WHERE         
      MtRegisterationActivity_Id = @pMtRegisterationActivity_Id        
      
    Update       
                   MtPartyRegisteration       
                  SET       
                   LuStatus_Code_Approval = 'WSDR'       
                  WHERE       
                  MtPartyRegisteration_Id = @pPartyRegisterationId      
      
   END        
        
--------------------------------------------------------------------------         
        
END    


---------------------------------------------------------------------------        
-----------------------------Termination Drafted----------------------------        
---------------------------------------------------------------------------        
       
if (@pCase = 'TerminationDraft')        
BEGIN        
DECLARE @vConnectedMPsCount int=0
select @vConnectedMPsCount=count(1) from MtPartyRegisteration where MtPartyRegisteration_MPId=@pPartyRegisterationId and ISNULL(isDeleted,0)=0
and LuStatus_Code_Applicant not in ('ATER','DER')

if @vConnectedMPsCount>0
BEGIN
select 'Please Reassign connected parties before terminating this party.' as errorMessage;
return ;
END
        
             IF @pMtRegisterationActivity_Id is NULL OR   @pMtRegisterationActivity_Id =0      
             BEGIN        
         
                      SELECT @pMtRegisterationActivity_Id= MAX(MtRegisterationActivity_Id)+1 FROM MtRegisterationActivities        
                              
                      INSERT INTO         
                       MtRegisterationActivities        
                          (        
                                        MtRegisterationActivity_Id        
                                       ,MtPartyRegisteration_Id        
                                       ,MtRegisterationActivities_ACtion        
                                       ,MtRegisterationActivities_ApplicationNo        
                                       ,MtRegisterationActivities_ApplicationDate        
                                       ,MtRegisterationActivities_Remarks
									   ,MtRegisterationActivities_Notes
                                       ,MtRegisterationActivities_CreatedBy        
                                       ,MtRegisterationActivities_Deleted    
            ,MtRegisterationActivities_OrderDate  
            ,MtRegisterationActivities_CreatedOn        
                                       )        
                      VALUES        
                                   (        
                                   @pMtRegisterationActivity_Id        
                                   ,@pPartyRegisterationId        
                                   ,'TEDR'        
                                   ,@pApplicationNo        
                                   , NULLIF(@pApplicationDate,'')        
                                   ,@pRemarks
								   ,@pNotes
                                   ,@pUserId        
                                   ,0     
           ,NULLIF(@pOrderApprovedDate,'')  
                                   ,GETUTCDATE()        
                                   )        
                        
      Update       
                   MtPartyRegisteration       
                  SET       
                   LuStatus_Code_Approval = 'TEDR'       
                  WHERE       
                  MtPartyRegisteration_Id = @pPartyRegisterationId      
        
   END        
---------------------------------------------------------------------------        
   IF @pMtRegisterationActivity_Id> 0        
   BEGIN        
     UPDATE MtRegisterationActivities        
     SET        
                       
                                        MtRegisterationActivities_ApplicationNo = ISNULL(@pApplicationNo ,MtRegisterationActivities_ApplicationNo)
                                       ,MtRegisterationActivities_ApplicationDate =ISNULL( @pApplicationDate ,MtRegisterationActivities_ApplicationDate)
                                       ,MtRegisterationActivities_Remarks =ISNULL(@pRemarks,MtRegisterationActivities_Remarks)
									   ,MtRegisterationActivities_Notes = ISNULL(@pNotes,MtRegisterationActivities_Notes)
                                       ,MtRegisterationActivities_ModifiedBy= @pUserId        
                                       ,MtRegisterationActivities_ModifiedOn = GETUTCDATE()  
									   ,MtRegisterationActivities_OrderDate=ISNULL(@pOrderApprovedDate  ,MtRegisterationActivities_OrderDate)
     WHERE         
      MtRegisterationActivity_Id = @pMtRegisterationActivity_Id        
      
    Update       
                   MtPartyRegisteration       
                  SET       
                   LuStatus_Code_Approval = 'TEDR'       
                  WHERE       
                  MtPartyRegisteration_Id = @pPartyRegisterationId      
      
   END        
        
--------------------------------------------------------------------------         
        
END    








    
---------------------------------------------------------------------------      
-------------Insert INTO Event Action CheckList --------------------------        
---------------------------------------------------------------------------      
    
---------------------------------------------------------------------------      
---------Start----Deleted Check Info EventActionCheckListInfo-------------       
---------------------------------------------------------------------------   

if (@pEventActionCheckListCheckedValue != '')
   BEGIN

SELECT Distinct        
 RuEventActionCheckList_Id          
INTO         
 #tempDeletedChecks        
FROM         
 EventActionCheckListInfo         
WHERE        
 MtRegisterationActivity_Id = @pMtRegisterationActivity_Id        
 AND RuEventActionCheckList_Id NOT IN (SELECT value FROM  STRING_SPLIT(@pEventActionCheckListCheckedValue, ',') )        
        
DELETE         
FROM         
 EventActionCheckListInfo        
WHERE         
 RuEventActionCheckList_Id in (SELECT RuEventActionCheckList_Id FROM #tempDeletedChecks)        
---------------------------------------------------------------------------          
---------END----Deleted Check Info EventActionCheckListInfo------------------    
---------------------------------------------------------------------------      
    
    
---------------------------------------------------------------------------      
---------Start----ADD Check Info EventActionCheckListInfo------------------      
---------------------------------------------------------------------------      
   
SELECT         
 value         
INTO         
 #tempAddChecks        
FROM          
 STRING_SPLIT(@pEventActionCheckListCheckedValue, ',')        
WHERE        
 value not in        
     (        
     SELECT         
      RuEventActionCheckList_Id         
     FROM        
      EventActionCheckListInfo         
     WHERE        
      MtRegisterationActivity_Id = @pMtRegisterationActivity_Id         
     )        
        
		
DECLARE @vEventActionCheckListInfo_Id DECIMAL(18,0);        
        
SELECT @vEventActionCheckListInfo_Id=ISNUll(MAX(EventActionCheckListInfo_Id),0) FROM EventActionCheckListInfo        
            
INSERT INTO EventActionCheckListInfo         
(        
 EventActionCheckListInfo_Id        
,RuEventActionCheckList_Id        
,MtRegisterationActivity_Id        
,EventActionCheckListInfo_CreatedBy        
,EventActionCheckListInfo_CreatedOn        
,EventActionCheckListInfo_IsDeleted        
)        
SELECT         
  @vEventActionCheckListInfo_Id+ROW_NUMBER() OVER(order by value) AS num_row        
 ,value        
 ,@pMtRegisterationActivity_Id        
 ,@pUserId        
 ,GETUTCDATE()        
 ,0        
 FROM         
    #tempAddChecks        
 END   
---------------------------------------------------------------------------             
---------END ----ADD Check Info EventActionCheckListInfo------------------      
---------------------------------------------------------------------------     
    
       
---------------------------------------------------------------------------        
-----------------------------Suspension WithDraw---------------------------        
---------------------------------------------------------------------------        
        
if (@pCase = 'SuspensionWithdraw')        
BEGIN        
    
     
   IF @pMtRegisterationActivity_Id_Suspension is NULL OR   @pMtRegisterationActivity_Id_Suspension =0      
   BEGIN    
      SELECT @pMtRegisterationActivity_Id_Suspension= MAX(MtRegisterationActivity_Id)+1 FROM MtRegisterationActivities        
                              
                      INSERT INTO         
                       MtRegisterationActivities        
                          (        
                                        MtRegisterationActivity_Id        
                                       ,MtPartyRegisteration_Id        
                                       ,MtRegisterationActivities_ACtion        
                                       ,MtRegisterationActivities_ApplicationNo        
                                       ,MtRegisterationActivities_ApplicationDate        
                                       ,MtRegisterationActivities_Remarks
									   ,MtRegisterationActivities_Notes
                                       ,MtRegisterationActivities_CreatedBy        
                                       ,MtRegisterationActivities_Deleted        
            ,MtRegisterationActivities_CreatedOn      
            ,ref_Id    
   ,MtRegisterationActivities_OrderDate  
                                       )        
                      VALUES        
                                   (        
                                   @pMtRegisterationActivity_Id_Suspension        
                                   ,@pPartyRegisterationId        
                                   ,'WSPF'   --Withdraw Suspension Pending For Approval     
                                   ,@pApplicationNo        
                                   ,@pApplicationDate        
                                   ,@pRemarks   
								   ,@pNotes
                                   ,@pUserId        
                                   ,0        
                                   ,GETUTCDATE()        
           ,@pMtRegisterationActivity_Id    
     ,@pOrderApprovedDate  
                                   )        
   END    
    
   IF @pMtRegisterationActivity_Id_Suspension>0    
   BEGIN    
       UPDATE     
        MtRegisterationActivities        
         SET        
                                        MtRegisterationActivities_ApplicationNo = @pApplicationNo        
                                       ,MtRegisterationActivities_ApplicationDate = @pApplicationDate        
                                       ,MtRegisterationActivities_Remarks = @pRemarks
									   ,MtRegisterationActivities_Notes = @pNotes
                                       ,MtRegisterationActivities_ModifiedBy= @pUserId        
                                       ,MtRegisterationActivities_ModifiedOn = GETUTCDATE()      
            ,MtRegisterationActivities_OrderDate=@pOrderApprovedDate  
         WHERE         
          MtRegisterationActivity_Id = @pMtRegisterationActivity_Id_Suspension        
      
           
    
   END    
        
END        
        
     
---------------------------------------------------------------------------        
-----------------------------Termination Information---------------------------        
---------------------------------------------------------------------------        
        
 if (@pCase = 'Termination')        
BEGIN        
    
     
   IF @pMtRegisterationActivity_Id_Termination is NULL OR   @pMtRegisterationActivity_Id_Termination =0      
   BEGIN    
      SELECT @pMtRegisterationActivity_Id_Termination= MAX(MtRegisterationActivity_Id)+1 FROM MtRegisterationActivities        
                              
                      INSERT INTO         
                       MtRegisterationActivities        
                          (        
                                        MtRegisterationActivity_Id        
                                       ,MtPartyRegisteration_Id        
                                       ,MtRegisterationActivities_ACtion        
                                       ,MtRegisterationActivities_ApplicationNo        
                                       ,MtRegisterationActivities_ApplicationDate        
                                       ,MtRegisterationActivities_Remarks  
									   ,MtRegisterationActivities_Notes
                                       ,MtRegisterationActivities_CreatedBy                                               ,MtRegisterationActivities_Deleted        
            ,MtRegisterationActivities_CreatedOn      
            ,ref_Id    
   ,MtRegisterationActivities_OrderDate  
                                       )        
                      VALUES        
                                   (        
                                   @pMtRegisterationActivity_Id_Termination        
                                   ,@pPartyRegisterationId        
                                   ,'TERM'   --Terminated    
                                   ,@pApplicationNo        
                                   ,@pApplicationDate        
                                   ,@pRemarks 
								   ,@pNotes
                                   ,@pUserId        
                                   ,0        
                                   ,GETUTCDATE()      
           ,@pMtRegisterationActivity_Id    
     ,@pOrderApprovedDate  
                                   )        
   END    
    
   IF @pMtRegisterationActivity_Id_Termination>0    
   BEGIN    
       UPDATE     
        MtRegisterationActivities        
         SET        
                                        MtRegisterationActivities_ApplicationNo = @pApplicationNo        
                                       ,MtRegisterationActivities_ApplicationDate = @pApplicationDate        
                                       ,MtRegisterationActivities_Remarks = @pRemarks 
									   ,MtRegisterationActivities_Notes = @pNotes
                                       ,MtRegisterationActivities_ModifiedBy= @pUserId        
                                       ,MtRegisterationActivities_ModifiedOn = GETUTCDATE()     
            ,MtRegisterationActivities_OrderDate= @pOrderApprovedDate  
         WHERE         
          MtRegisterationActivity_Id = @pMtRegisterationActivity_Id_Termination        
      
           
    
   END    
        
END        
     
        
---------------------------------------------------------------------------        
-----------------------------Termination Approved---------------------------        
---------------------------------------------------------------------------        
        
        
        
END
