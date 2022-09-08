/****** Object:  Procedure [dbo].[CreateNewSettlementStatement]    Committed by VersionSQL https://www.versionsql.com ******/

--[dbo].[CreateNewSettlementStatement]  @pProcessId= 1, @pSettlementPeriodId= 0, @pCurrentSettlementPeriodId=3, @pUserId=1, @pStatus='Draft', @pApprovalStatus='Draft'

CREATE PROCEDURE [dbo].[CreateNewSettlementStatement]    
@pProcessId decimal(18,0)   =null ,
@pSettlementPeriodId decimal(18,0)=null, --For ESS Only
@pCurrentSettlementPeriodId decimal(18,0)=null,
@pUserId decimal(18,0)=null,
@pStatus as Varchar(50)=null,	--Draft
@pApprovalStatus as Varchar(50)=null	--Draft

AS    
BEGIN  


  --set @pProcessId=1 --  PSS-BME

 --------------------------		Check if Predecessor exists for Statement and Process
  DECLARE @vStatementPredecessor as decimal(18,0)
  DECLARE @vProcessPredecessor as decimal(18,0)
  DECLARE @vStatementId as decimal(18,0)
 DECLARE @vProcessTypeId Decimal(18,0)--Check if Statement=ESS for Current Settlement Period
 Declare @vSrProcessDef_PreviousProcessPredecessorID as decimal(18,0)-- ASC-FSS is dependent on ASC-PSS


 IF(@pProcessId=12)
BEGIN
DECLARE @vTempHoldPeriodID decimal(18,0) --temp
SET @vTempHoldPeriodID=@pSettlementPeriodId 
SET @pSettlementPeriodId=@pCurrentSettlementPeriodId
SET @pCurrentSettlementPeriodId=@vTempHoldPeriodID
END

  select @vProcessTypeId=SDF.SrStatementDef_ID , @vStatementPredecessor= SDF.SrStatementDef_Predecessor_ID,@vProcessPredecessor= SPD.SrProcessDef_PredecessorID, @vSrProcessDef_PreviousProcessPredecessorID=SPD.SrProcessDef_PreviousProcessPredecessorID from SrStatementDef SDF
  inner join SrProcessDef SPD on SDF.SrStatementDef_ID=SPD.SrStatementDef_ID
  and SPD.SrProcessDef_ID=@pProcessId
   Print '@vSrProcessDef_PreviousProcessPredecessorID'
  Print @vSrProcessDef_PreviousProcessPredecessorID
	--***************	Statement Predecessor Missing *********************
	----------------------------	Statement Predecessor Check starts -------------
  if(@vStatementPredecessor is not null)
	BEGIN
Declare @ApprovalStatus as varchar(50);
 DECLARE @vStatementPredecessorProcessesCount as int=null
 DECLARE @vTotalStatementPredecessorProcessesCount as int=null

		select SPD.SrProcessDef_ID as SrProcessDef_ID  into #StatementPredecessorProcesses from SrProcessDef SPD where SPD.SrStatementDef_ID=@vStatementPredecessor

		SELECT @vTotalStatementPredecessorProcessesCount=count(1) from #StatementPredecessorProcesses

		select @vStatementPredecessorProcessesCount=count(1), 
		@ApprovalStatus= MSP.MtStatementProcess_ApprovalStatus from MtStatementProcess MSP where  MSP.LuAccountingMonth_Id_Current=@pCurrentSettlementPeriodId and MSP.SrProcessDef_ID in (select SrProcessDef_ID from #StatementPredecessorProcesses) and ISNULL(MtStatementProcess_IsDeleted,0)=0


		if(@vStatementPredecessorProcessesCount<>@vTotalStatementPredecessorProcessesCount)
		BEGIN
				Print 'Some Predecessor Processes are missing'
--						   Select 'Some Predecessor Processes are missing. Please complete that before proceeding next' as response
							select Concat('Some Processes of ',SrStatementDef_Name,' are missing for selected Settlement Period. Please complete that before preceding next') as response from SrStatementDef where SrStatementDef_ID=@vStatementPredecessor
						   return;    
		END
END
	----------------------------	Statement Predecessor Check ends -------------

	-----------------	Process Predecessor Check Starts
  if(@vProcessPredecessor is not null)
	BEGIN
		Declare @vProcessPredecessorCheck as int 
		Declare @vProcessApprovalStatus as varchar(50);
		
		Select @vProcessPredecessorCheck=count(1) from MtStatementProcess where LuAccountingMonth_Id_Current=@pCurrentSettlementPeriodId and SrProcessDef_ID= @vProcessPredecessor and ISNULL(MtStatementProcess_IsDeleted,0)=0

		Select @vProcessApprovalStatus=MtStatementProcess_ApprovalStatus  from MtStatementProcess where LuAccountingMonth_Id_Current=@pCurrentSettlementPeriodId and SrProcessDef_ID= @vProcessPredecessor and ISNULL(MtStatementProcess_IsDeleted,0)=0

		
				if(@vProcessPredecessorCheck=0)
				BEGIN

					select  CONCAT('Please create ',SPD.SrProcessDef_Name,' - ',SSD.SrStatementDef_Name,' Process First Before creating current process.') as response from SrStatementDef SSD inner join SrProcessDef SPD on SPD.SrStatementDef_ID=SSD.SrStatementDef_ID where SPD.SrProcessDef_ID=@vProcessPredecessor

						PRINT 'Please create Predecessors Processes First'
--						   Select '2' as response
						   return;    
					
				END
				if(@vProcessApprovalStatus <>'Approved')
				BEGIN

				select  CONCAT('Please approve ',SPD.SrProcessDef_Name,' - ',SSD.SrStatementDef_Name,' Process First Before creating current process.') as response from SrStatementDef SSD inner join SrProcessDef SPD on SPD.SrStatementDef_ID=SSD.SrStatementDef_ID where SPD.SrProcessDef_ID=@vProcessPredecessor
				 return; 
				END
	END
	-----------------	Process Predecessor Check Ends

	-----------------	Previous Process Predecessor Check Starts
  if(@vSrProcessDef_PreviousProcessPredecessorID is not null)
	BEGIN
		Declare @vSrProcessDef_PreviousProcessPredecessorIDCheck as int ;
		Declare @vPreviousProcessPredecessorApprovalStatus as varchar(50);
		
		Select @vSrProcessDef_PreviousProcessPredecessorIDCheck=count(1) from MtStatementProcess where LuAccountingMonth_Id_Current=@pCurrentSettlementPeriodId and SrProcessDef_ID= @vSrProcessDef_PreviousProcessPredecessorID and ISNULL(MtStatementProcess_IsDeleted,0)=0

		Select @vPreviousProcessPredecessorApprovalStatus= MtStatementProcess_ApprovalStatus from MtStatementProcess where LuAccountingMonth_Id_Current=@pCurrentSettlementPeriodId and SrProcessDef_ID= @vSrProcessDef_PreviousProcessPredecessorID and ISNULL(MtStatementProcess_IsDeleted,0)=0

		

		Print '@vSrProcessDef_PreviousProcessPredecessorIDCheck';
		Print @vSrProcessDef_PreviousProcessPredecessorIDCheck;
				if(@vSrProcessDef_PreviousProcessPredecessorIDCheck=0)
				BEGIN
				Print 'In IF Statement' 
					select  CONCAT('Please create ',SPD.SrProcessDef_Name,' - ',SSD.SrStatementDef_Name,' Process First Before creating current process.') as response from SrStatementDef SSD inner join SrProcessDef SPD on SPD.SrStatementDef_ID=SSD.SrStatementDef_ID where SPD.SrProcessDef_ID=@vSrProcessDef_PreviousProcessPredecessorID

						PRINT 'Please create Predecessors Processes First'
--						   Select '2' as response
Print 'Before return'
						   return;    
					
				END

				if(@vPreviousProcessPredecessorApprovalStatus <>'Submitted')
				BEGIN

				select  CONCAT('Please submit ',SPD.SrProcessDef_Name,' - ',SSD.SrStatementDef_Name,' Process First Before creating current process.') as response from SrStatementDef SSD inner join SrProcessDef SPD on SPD.SrStatementDef_ID=SSD.SrStatementDef_ID where SPD.SrProcessDef_ID=@vProcessPredecessor

				END
	END
	-----------------Previous	Process Predecessor Check Ends

	-----------------Check if same statement is already created for same settlement Period starts
if(@pProcessId <>7 and @pProcessId <>8 and @pProcessId <>9 and @pProcessId <>12 )--Multiple ESS reports can be generated
BEGIN
		Declare @vProcessAlreadyExistsCheck as int 
		Select @vProcessAlreadyExistsCheck=count(1) from MtStatementProcess where LuAccountingMonth_Id_Current=@pCurrentSettlementPeriodId and SrProcessDef_ID=@pProcessId  and ISNULL(MtStatementProcess_IsDeleted,0)=0
				if(@vProcessAlreadyExistsCheck <> 0)
				BEGIN
						PRINT 'Settlement Statement for this month is already created'
						   Select '3' as response
						   return;    
					
				END
END

	-----------------Check if same statement is already created for same settlement Period ends    

	----------------------	In case of ESS of previous month, check if BME-FSS and ASC-FSS exist for previous month also
if(@pProcessId =7 or @pProcessId=8 or @pProcessId =9  )--Multiple ESS reports can be generated
BEGIN
Declare @vFSSAlreadyExists as int;
select @vFSSAlreadyExists= count(1) from MtStatementProcess where  LuAccountingMonth_Id_Current=@pSettlementPeriodId and  SrProcessDef_ID in (4,5)  and ISNULL(MtStatementProcess_IsDeleted,0)=0;
				if(@vFSSAlreadyExists <> 2)
				BEGIN
						PRINT 'Please Generate BME-FSS and ASC-FSS of previous month before preceding next.'
						   Select 'Please Generate BME-FSS and ASC-FSS of previous month before preceding next.' as response
						   return;    
					
				END

END
	----------------------	In case of ESS of previous month, check if BME-FSS and ASC-FSS exist for previous month also ENDS


	------------------ Insert data to MtStatementProcess
	 Declare @vMtStatementProcess_ID Decimal(18,0);
 SELECT @vMtStatementProcess_ID=MAX( ISNUll(MtStatementProcess_ID,0))+1 FROM MtStatementProcess        


 if(@pProcessId in (7,8,9))
 BEGIN
INSERT INTO [dbo].[MtStatementProcess]
           ([MtStatementProcess_ID]
           ,[SrProcessDef_ID]
           ,[LuAccountingMonth_Id]
		   ,[LuAccountingMonth_Id_Current]
           
           ,[MtStatementProcess_ExecutionStartDate]
           ,[MtStatementProcess_ExecutionFinishDate]
           ,[MtStatementProcess_Status]
           ,[MtStatementProcess_ApprovalStatus]
           ,[MtStatementProcess_CreatedBy]
           ,[MtStatementProcess_CreatedOn]
           ,[MtStatementProcess_IsDeleted])
     VALUES
           (ISNULL(@vMtStatementProcess_ID,1) 
           ,@pProcessId
           ,@pCurrentSettlementPeriodId
           ,case WHEN @vProcessTypeId=3 THEN @pSettlementPeriodId
			   else null END
           ,DATEADD(HOUR,5,GetUTCDATE()) 
           ,null  
           ,@pStatus
           ,@pApprovalStatus
           ,@pUserId
           ,DATEADD(HOUR,5,GetUTCDATE())  
           ,0)
END
ELSE
BEGIN
INSERT INTO [dbo].[MtStatementProcess]
           ([MtStatementProcess_ID]
           ,[SrProcessDef_ID]
		   ,[LuAccountingMonth_Id_Current]
           ,[LuAccountingMonth_Id]           
           ,[MtStatementProcess_ExecutionStartDate]
           ,[MtStatementProcess_ExecutionFinishDate]
           ,[MtStatementProcess_Status]
           ,[MtStatementProcess_ApprovalStatus]
           ,[MtStatementProcess_CreatedBy]
           ,[MtStatementProcess_CreatedOn]
           ,[MtStatementProcess_IsDeleted])
     VALUES
           (ISNULL(@vMtStatementProcess_ID ,1)
           ,@pProcessId
           ,@pCurrentSettlementPeriodId
           ,case WHEN @vProcessTypeId=3 THEN @pSettlementPeriodId
			   else null END
           ,DATEADD(HOUR,5,GetUTCDATE()) 
           ,null  
           ,@pStatus
           ,@pApprovalStatus
           ,@pUserId
           ,DATEADD(HOUR,5,GetUTCDATE())  
           ,0)

END

CREATE TABLE #tempBmeVersions(
SOFileTemplateId int,
Version int
)

if(@pProcessId in (2,5,7))
BEGIN
Declare @vBmeId as Decimal(18,0)=null
		select @vBmeId=[dbo].[GetBMEtatementProcessIdFromASC](@vMtStatementProcess_ID)

		--print 'Asc Id'+ cast(@vMtStatementProcess_ID as NVARCHAR(MAX))
		--print 'BME Id'+cast (@vBmeId as NVARCHAR(MAX))
		insert into #tempBmeVersions(SOFileTemplateId,Version)
		select SOFileTemplateId,Version from BMEInputsSOFilesVersions where SettlementProcessId=@vBmeId		

END
--ELSE
--BEGIN 
--		select 0 as SOFileTemplateId, 0 as Version into #tempBmeVersions 		

--END


		   		   ------------------- PSS/FSS Save latest version of SO file template for BME Input Grid Started -----------------------
				INSERT INTO BMEInputsSOFilesVersions 
				SELECT SP.MtStatementProcess_ID, PID.LuSOFileTemplate_Id,				
--				MAX(FM.MtSOFileMaster_Version) AS MaxVersion 
				case when @pProcessId in (2,5,7) and MIN(PID.LuSOFileTemplate_Id)=MIN(bme.SOFileTemplateId)  then Max(bme.Version) 
				else MAX(FM.MtSOFileMaster_Version) end AS MaxVersion 
				,1, GETDATE(),1,GETDATE(),null
				from RuProcessInputDef PID

				JOIN MtStatementProcess SP ON SP.SrProcessDef_ID = PID.SrProcessDef_ID AND SP.MtStatementProcess_ID = @vMtStatementProcess_ID 

				LEFT JOIN MtSOFileMaster FM ON FM.LuAccountingMonth_Id = SP.LuAccountingMonth_Id_Current AND FM.LuSOFileTemplate_Id = PID.LuSOFileTemplate_Id AND FM.LuStatus_Code = 'APPR' AND ISNULL(FM.MtSOFileMaster_IsDeleted,0)=0 AND FM.MtSOFileMaster_IsUseForSettlement=1 

				LEFT JOIN  #tempBmeVersions bme on bme.SOFileTemplateId=PID.LuSOFileTemplate_Id

				WHERE PID.LuSOFileTemplate_Id IS NOT NULL AND PID.SrProcessDef_ID = @pProcessId 
				and PID.LuSOFileTemplate_Id NOT IN (select SOFileTemplateId FROM BMEInputsSOFilesVersions where SettlementProcessId= @vMtStatementProcess_ID )
				GROUP BY 
				PID.LuSOFileTemplate_Id, PID.RuProcessInputDef_ID, SP.MtStatementProcess_ID, SP.LuAccountingMonth_Id_Current
				ORDER BY 
				PID.LuSOFileTemplate_Id


		   Print 'Record Inserted Successfully'
						   Select '1' as response
						   return;    



END 
