/****** Object:  Procedure [dbo].[FCD_CreateProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE   Procedure dbo.FCD_CreateProcess @pMtFCDMaster_Type INT,
--  @pMtFCDMaster_YearFrom int,        
--  @pMtFCDMaster_YearTo int,        
@pLuAccountingMonth_Id INT,
@pGenerators NVARCHAR(MAX) = NULL,
@pUserId INT
AS
BEGIN

	/*  IF EXISTS(SELECT 1 from  [dbo].[MtFCDMaster] where [MtFCDMaster_Type]=@pMtFCDMaster_Type         
           -- and MtFCDMaster_YearFrom=@pMtFCDMaster_YearFrom and MtFCDMaster_YearTo=@pMtFCDMaster_YearTo        
            and ISNULL(MtFCDMaster_IsDeleted,0)=0        
            and @pMtFCDMaster_Type <> 3        
            )        
            BEGIN        
              RAISERROR ('Firm Capacity Process is already created for selected time period.', 16, -1);        
             RETURN;        
            END        
                
            Declare @MtFCDMaster_Id  table (MtFCDMaster_Id int)        
          */


	/*      
          @pMtFCDMaster_Type      
          1. All Generators without determined Firm Capacity      
          2. All Generators with expired Firm Capacity Certificates      
          3. Manual Selection of Generators      
          */


	/*------------------------------------------------------------------------------      
          -------------------Validations start--------------------------------------------      
          ------------------------------------------------------------------------------*/
	IF (@pMtFCDMaster_Type = 1)
	BEGIN
		IF NOT EXISTS (SELECT TOP 1
					1
				FROM MtGenerator G
				INNER JOIN MtPartyCategory C
					ON C.MtPartyCategory_Id = G.MtPartyCategory_Id
				INNER JOIN MtPartyRegisteration P
					ON P.MtPartyRegisteration_Id = C.MtPartyRegisteration_Id
				WHERE ISNULL(G.isDeleted, 0) = 0
				AND ISNULL(MtGenerator_IsDeleted, 0) = 0
				AND ISNULL(C.isDeleted, 0) = 0
				AND ISNULL(P.isDeleted, 0) = 0
				AND P.LuStatus_Code_Applicant = 'AACT'
				AND MtGenerator_Id NOT IN (SELECT DISTINCT
						MtGenerator_Id
					FROM MtFCDGenerators G
					INNER JOIN MtFCDMaster M
						ON M.MtFCDMaster_Id = G.MtFCDMaster_Id
					WHERE ISNULL(MtFCDGenerators_IsDeleted, 0) = 0
					AND ISNULL(MtFCDMaster_IsDeleted, 0) = 0
					AND MtFCDMaster_ApprovalStatus = 'Approved'))
		BEGIN
			RAISERROR ('No generator exists without Determined Firm Capacity.', 16, -1);
			RETURN;
		END
	END


	IF (@pMtFCDMaster_Type = 2)
	BEGIN
		IF NOT EXISTS (SELECT TOP 1
					1
				FROM MtFCCMaster
				WHERE ISNULL(MtFCCMaster_IsDeleted, 0) = 0
				AND MtFCCMaster_ExpiryDate < GETDATE())
		BEGIN
			RAISERROR ('No expired Firm Capacity certificates exsit for any generator.', 16, -1);
			RETURN;

		END
	END


	IF (@pMtFCDMaster_Type = 3)
	BEGIN
		SELECT DISTINCT
			G.MtGenerator_Id INTO #AlreadyInProcessGenerator
		FROM MtFCDMaster M
		JOIN MtFCDGenerators G
			ON M.MtFCDMaster_Id = G.MtFCDMaster_Id
		WHERE M.MtFCDMaster_ProcessStatus != 'Completed'
		AND M.MtFCDMaster_ApprovalStatus != 'Approved'
		AND M.MtFCDMaster_IsDeleted = 0
		AND G.MtFCDGenerators_IsDeleted = 0
		AND G.MtGenerator_Id IN (SELECT
				value
			FROM STRING_SPLIT(@pGenerators, ','))

		IF EXISTS (SELECT TOP 1
					1
				FROM #AlreadyInProcessGenerator)
		BEGIN

			DECLARE @Generators VARCHAR(200) = NULL
			SELECT
				@Generators = COALESCE(@Generators + ',', '') + CAST(MtGenerator_Id AS VARCHAR(10))
			FROM #AlreadyInProcessGenerator

			SET @Generators = 'Generator(s) (' + @Generators + ') already involved in another instance of the process. Either Approve or Remove that Draft instance to initiate new process for the desired generator(s)'
			RAISERROR (@Generators, 16, -1);

			RETURN;
		END

		/*----------------------------------validation on FCC --------------------------------------------      
	          On approval of "Firm Capacity Determination" of the generators, if "Firm Capacity Certificate Generation" of      
	          any of the involved generator is in not approved state then a message will come that "Firm Capacity Certificate       
	          Generation" process ID ___ dated ____ of the Generator XXX is in process, either Approve or Reject that      
	          Draft instance to complete this instance instance "Firm Capacity Determination" process. Stop that process here.       
	          ------------------------------------------------------------------------------------------------*/

		SELECT DISTINCT
			MtGenerator_Id INTO #AlreadyInFCCProcessGenerator
		FROM MtFCCMaster
		WHERE LuStatus_Code != 'Completed'
		AND MtFCCMaster_ApprovalCode != 'Approved'
		AND MtFCCMaster_IsDeleted = 0
		AND MtGenerator_Id IN (SELECT
				value
			FROM STRING_SPLIT(@pGenerators, ','))


		IF EXISTS (SELECT TOP 1
					1
				FROM #AlreadyInFCCProcessGenerator)
		BEGIN

			DECLARE @GeneratorsFCC VARCHAR(200) = NULL
			SELECT
				@GeneratorsFCC = COALESCE(@GeneratorsFCC + ',', '') + CAST(MtGenerator_Id AS VARCHAR(10))
			FROM #AlreadyInFCCProcessGenerator

			SET @GeneratorsFCC =
			'Firm Capacity Certificate Generation of the Generator(s) (' + @GeneratorsFCC + ') is/are in process, either Approve or Reject that Draft instance to complete this instance instance';
			RAISERROR (@GeneratorsFCC, 16, -1);

			RETURN;
		END
	END



	/*------------------------------------------------------------------------------      
          -------------------Insert in master--------------------------------------------      
          ------------------------------------------------------------------------------*/
	DECLARE @vMtFCDMaster_Id DECIMAL(18, 0)
	INSERT INTO [dbo].[MtFCDMaster] ([MtFCDMaster_Type]
	, SrFCDProcessDef_Id
	--           ,[MtFCDMaster_YearFrom]        
	--          ,[MtFCDMaster_YearTo]        
	, [LuAccountingMonth_Id]
	, [MtFCDMaster_Months]
	, [MtFCDMaster_Hours]
	, [MtFCDMaster_ProcessStatus]
	, [MtFCDMaster_ApprovalStatus]
	, [MtFCDMaster_CreatedBy]
	, [MtFCDMaster_CreatedOn])
		--  output inserted.MtFCDMaster_Id into @MtFCDMaster_Id        
		VALUES (@pMtFCDMaster_Type, 1, @pLuAccountingMonth_Id
		--           ,@pMtFCDMaster_YearFrom        
		--          ,@pMtFCDMaster_YearTo        
		, (SELECT RuGlobalSetting_value FROM RuGlobalSetting WHERE RuGlobalSetting_Key = 'FCD_Months'), (SELECT RuGlobalSetting_value FROM RuGlobalSetting WHERE RuGlobalSetting_Key = 'FCD_Hours'), 'New', 'Draft', @pUserId, GETDATE())
	SET @vMtFCDMaster_Id = @@identity;

	--*************************************  Generators Data        
	/*------------------------------------------------------------------------------      
          -------------------Insert In details--------------------------------------------      
          ------------------------------------------------------------------------------*/
	IF (@pMtFCDMaster_Type = 1)
	BEGIN

		INSERT INTO [dbo].[MtFCDGenerators] ([MtFCDMaster_Id]
		, [MtGenerator_Id]
		, [MtGenerator_TotalInstalledCapacity]
		, [LuEnergyResourceType_Code]
		, [GeneratorFOR]
		, [MtFCDGenerators_CreatedBy]
		, [MtFCDGenerators_CreatedOn])
			SELECT DISTINCT
				@vMtFCDMaster_Id
			   ,G.MtGenerator_Id
			   ,MtGenerator_TotalInstalledCapacity
			   ,LuEnergyResourceType_Code
			   ,MtGenerator_FOR
			   ,@pUserId
			   ,GETDATE()
			FROM MtGenerator G
			INNER JOIN MtPartyCategory C
				ON C.MtPartyCategory_Id = G.MtPartyCategory_Id
			INNER JOIN MtPartyRegisteration P
				ON P.MtPartyRegisteration_Id = C.MtPartyRegisteration_Id
			WHERE ISNULL(G.isDeleted, 0) = 0
			AND ISNULL(MtGenerator_IsDeleted, 0) = 0
			AND ISNULL(C.isDeleted, 0) = 0
			AND ISNULL(P.isDeleted, 0) = 0
			AND P.LuStatus_Code_Applicant = 'AACT'
			AND MtGenerator_Id NOT IN (SELECT DISTINCT
					FCDG.MtGenerator_Id
				FROM MtFCDGenerators FCDG
				INNER JOIN MtFCDMaster M
					ON M.MtFCDMaster_Id = FCDG.MtFCDMaster_Id
				WHERE ISNULL(FCDG.MtFCDGenerators_IsDeleted, 0) = 0
				AND ISNULL(M.MtFCDMaster_IsDeleted, 0) = 0
				AND M.MtFCDMaster_ApprovalStatus = 'Approved')
			/* Multiple "Firm Capacity Determination"  should not be started if any of the      
		          selected generator is involved in other instance(s) of same "Firm Capacity Determination" process with Not approved state at the same time.*/
			AND G.MtGenerator_Id NOT IN (SELECT
					FCDG.MtGenerator_Id
				FROM MtFCDMaster M
				JOIN MtFCDGenerators FCDG
					ON M.MtFCDMaster_Id = FCDG.MtFCDMaster_Id
				WHERE M.MtFCDMaster_ProcessStatus != 'Completed'
				AND M.MtFCDMaster_ApprovalStatus != 'Approved'
				AND M.MtFCDMaster_IsDeleted = 0
				AND FCDG.MtFCDGenerators_IsDeleted = 0)
	--and MtGenerator_Id  in (        
	--64,65,92,129        
	--)       

	END
	ELSE
	IF (@pMtFCDMaster_Type = 2)
	BEGIN
		INSERT INTO [dbo].[MtFCDGenerators] ([MtFCDMaster_Id]
		, [MtGenerator_Id]
		, [MtGenerator_TotalInstalledCapacity]
		, [LuEnergyResourceType_Code]
		, [GeneratorFOR]
		, [MtFCDGenerators_CreatedBy]
		, [MtFCDGenerators_CreatedOn])

			SELECT
				@vMtFCDMaster_Id
			   ,MtGenerator_Id
			   ,MtGenerator_TotalInstalledCapacity
			   ,LuEnergyResourceType_Code
			   ,MtGenerator_FOR
			   ,@pUserId
			   ,GETDATE()
			FROM MtGenerator
			WHERE MtGenerator_Id IN (SELECT DISTINCT
					MtGenerator_Id
				FROM MtFCCMaster
				WHERE ISNULL(MtFCCMaster_IsDeleted, 0) = 0
				AND MtFCCMaster_ExpiryDate < GETDATE())
			/* Multiple "Firm Capacity Determination"  should not be started if any of the      
		          selected generator is involved in other instance(s) of same "Firm Capacity Determination" process with Not approved state at the same time.*/
			AND MtGenerator_Id NOT IN (SELECT
					G.MtGenerator_Id
				FROM MtFCDMaster M
				JOIN MtFCDGenerators G
					ON M.MtFCDMaster_Id = G.MtFCDMaster_Id
				WHERE M.MtFCDMaster_ProcessStatus != 'Completed'
				AND M.MtFCDMaster_ApprovalStatus != 'Approved'
				AND M.MtFCDMaster_IsDeleted = 0
				AND G.MtFCDGenerators_IsDeleted = 0)

	END
	ELSE
	IF (@pMtFCDMaster_Type = 3)
	BEGIN



		INSERT INTO [dbo].[MtFCDGenerators] ([MtFCDMaster_Id]
		, [MtGenerator_Id]
		, [MtGenerator_TotalInstalledCapacity]
		, [LuEnergyResourceType_Code]
		, [GeneratorFOR]
		, [MtFCDGenerators_CreatedBy]
		, [MtFCDGenerators_CreatedOn])

			SELECT
				@vMtFCDMaster_Id
			   ,MtGenerator_Id
			   ,MtGenerator_TotalInstalledCapacity
			   ,LuEnergyResourceType_Code
			   ,MtGenerator_FOR
			   ,@pUserId
			   ,GETDATE()
			FROM MtGenerator
			WHERE MtGenerator_Id IN (SELECT
					value
				FROM STRING_SPLIT(@pGenerators, ','))

	END
	--ELSE         
	--BEGIN        
	--INSERT INTO [dbo].[MtFCDGenerators]        
	--           ([MtFCDMaster_Id]        
	--           ,[MtGenerator_Id]        
	--           ,[MtGenerator_TotalInstalledCapacity]        
	--           ,[LuEnergyResourceType_Code]        
	--           ,[MtFCDGenerators_CreatedBy]        
	--           ,[MtFCDGenerators_CreatedOn])        

	--select @vMtFCDMaster_Id,MtGenerator_Id, MtGenerator_TotalInstalledCapacity, LuEnergyResourceType_Code, @pUserId, GETDATE()        
	--from MtGenerator where ISNULL(isDeleted,0)=0 and ISNULL(MtGenerator_IsDeleted,0)=0 and         
	--(@pMtFCDMaster_Type=1 or        
	--(@pMtFCDMaster_Type=2 and LuEnergyResourceType_Code='DP') or        
	--(@pMtFCDMaster_Type=3 and LuEnergyResourceType_Code='NDP')        
	--)        
	--END        

	/***************************************************************************  
    Logs section  
    ****************************************************************************/

	DECLARE @output VARCHAR(MAX);
	SET @output = 'New process created: ' + CAST(@vMtFCDMaster_Id AS VARCHAR(10)) + ' Process ID with name ' +
	CASE
		WHEN @pMtFCDMaster_Type = 1 THEN 'All Generators without determined Firm Capacity'
		WHEN @pMtFCDMaster_Type = 2 THEN 'All Generators with expired Firm Capacity Certificates'
		WHEN @pMtFCDMaster_Type = 3 THEN 'Manual Selection of Generators'
		ELSE ''
	END + '. Period: ' + (SELECT
			LuAccountingMonth_MonthName
		FROM LuAccountingMonth
		WHERE LuAccountingMonth_Id = @pLuAccountingMonth_Id)
	+ '.';

	EXEC [dbo].[SystemLogs] @user = @pUserId
						   ,@moduleName = 'Firm Capacity Determination'
						   ,@CrudOperationName = 'Create'
						   ,@logMessage = @output

	SELECT
		'Data inserted successfully' AS response;
END
