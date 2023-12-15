/****** Object:  Procedure [dbo].[ContractReg_InsertUpdateDeleteDocuments]    Committed by VersionSQL https://www.versionsql.com ******/

          
CREATE procedure dbo.ContractReg_InsertUpdateDeleteDocuments    
--DECLARE
@pRuDocumentId int=null,          
@pMtContractRegistration_Id decimal(18,0)=null,          
@pMtDocuments_FlieName varchar(100)=null,          
@pMtDocuments_Description varchar(max)=null,          
@pMtDocuments_Size int=null,          
@pMtDocuments_Path varchar(max)=null,          
@puser_id decimal (18,0)=null,          
@pMtDocuments_FileTitle varchar(max)=null,          
@pMtDocumentId int =null,        
@action_flag int=null        
as          
--select @pMtDocuments_FlieName
declare @contractid varchar(max);  
  DECLARE @output VARCHAR(MAX);          
declare @vMax_document_id int           
select @vMax_document_id= IsNull(MAX( [MtDocuments_ID] ) + 1,1) from MtDocuments          

if isnull(@pMtDocumentId,0)=0   and @action_flag=1        
begin          
INSERT INTO  MtDocuments                                      
(MtDocuments_ID, RuDocument_ID, MtContractRegistration_Id, MtDocuments_FlieName, MtDocuments_Description, MtDocuments_Size, MtDocuments_Path, MtDocuments_CreatedBy, MtDocuments_CreatedOn, MtDocuments_FileTitle)          
select @vMax_document_id+1,@pRuDocumentId,@pMtContractRegistration_Id,@pMtDocuments_FlieName,@pMtDocuments_Description,@pMtDocuments_Size,@pMtDocuments_Path,          
@puser_id,getdate(),@pMtDocuments_FileTitle    
        
  SET @output='Documents Updated. Contract ID: ' + convert(varchar(max),@pMtContractRegistration_Id) + ',Document File Name:  ' +convert(varchar(max),isnull(@pMtDocuments_FileTitle,''))   
     
   EXEC [dbo].[SystemLogs]      
    @user=@puser_id,    
    @moduleName='Contract Registration',      
    @CrudOperationName='Create',      
    @logMessage=@output  
end          
if isnull(@pMtDocumentId,0)!=0  and @action_flag=2        
begin          
update MtDocuments           
set  [MtDocuments_FileTitle]=@pMtDocuments_FileTitle,          
[MtDocuments_Description] =@pMtDocuments_Description,          
[MtDocuments_ModifiedBy]=@puser_id,          
[MtDocuments_ModiifiedOn]=GETDATE()           
where [MtDocuments_ID]=@pMtDocumentId      
    
select @contractid=MtContractRegistration_Id from MtDocuments where MtDocuments_ID=@pMtDocumentId	

SET @output='Documents Updated. Contract ID: ' 
+ convert(varchar(max),@contractid) + ',Document File Name: ' +convert(varchar(max),isnull(@pMtDocuments_FileTitle,''))   
     
   EXEC [dbo].[SystemLogs]      
    @user=@puser_id,    
    @moduleName='Contract Registration',      
    @CrudOperationName='Update',      
    @logMessage=@output  
    
END          
        
    
    
if isnull(@pMtDocumentId,0)!=0  and @action_flag=3        
begin          
update MtDocuments           
set  MtDocuments_isDeleted=1 ,        
[MtDocuments_ModifiedBy]=@puser_id,          
[MtDocuments_ModiifiedOn]=GETDATE()           
where [MtDocuments_ID]=@pMtDocumentId 

select @contractid=MtContractRegistration_Id from MtDocuments where MtDocuments_ID=@pMtDocumentId	
SET @output='Documents Updated. Contract ID: ' 
+ convert(varchar(max),@contractid) + ',Document File Name: ' +convert(varchar(max),isnull(@pMtDocuments_FileTitle,''))   
     
   EXEC [dbo].[SystemLogs]      
    @user=@puser_id,    
    @moduleName='Contract Registration',      
    @CrudOperationName='Update',      
    @logMessage=@output  
  ----------------------------    
   
   
END 
