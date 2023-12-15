/****** Object:  Table [dbo].[MtContractPhysicalAssets]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractPhysicalAssets(
	[MtContractPhysicalAssets_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtContractPhysicalAssetsـPercentInstallEnergyTransaction] [decimal](18, 5) NULL,
	[MtContractPhysicalAssetsـPercentInstallCapacityTransaction] [decimal](18, 5) NULL,
	[MtContractPhysicalAssetsـPercentAssignedASCBuyer] [decimal](18, 5) NULL,
	[MtContractPhysicalAssetsـPercentAssignedASCSeller] [decimal](18, 5) NULL,
	[MtContractPhysicalAssets_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtContractPhysicalAssets_CreatedOn] [datetime] NOT NULL,
	[MtContractPhysicalAssets_ModifiedBy] [decimal](18, 0) NULL,
	[MtContractPhysicalAssets_ModifiedOn] [datetime] NULL,
	[MtContractPhysicalAssets_IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractPhysicalAssets_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtContractPhysicalAssets  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__MtCon__43A1D464] FOREIGN KEY([MtContractRegistration_Id])
REFERENCES [dbo].[MtContractRegistration] ([MtContractRegistration_Id])
ALTER TABLE dbo.MtContractPhysicalAssets CHECK CONSTRAINT [FK__MtContrac__MtCon__43A1D464]
ALTER TABLE dbo.MtContractPhysicalAssets  WITH CHECK ADD FOREIGN KEY([MtGenerationUnit_Id])
REFERENCES [dbo].[MtGenerationUnit] ([MtGenerationUnit_Id])

CREATE TRIGGER [dbo].[audittrg_MtContractPhysicalAssets]
ON dbo.MtContractPhysicalAssets
AFTER UPDATE
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO [dbo].[MtContractPhysicalAssets_audit] ([MtContractPhysicalAssets_Id]
	, [MtContractRegistration_Id]
	, [MtGenerationUnit_Id]
	, [MtContractPhysicalAssetsـPercentInstallEnergyTransaction]
	, [MtContractPhysicalAssetsـPercentInstallCapacityTransaction]
	, [MtContractPhysicalAssetsـPercentAssignedASCBuyer]
	, [MtContractPhysicalAssetsـPercentAssignedASCSeller]
	, [MtContractPhysicalAssets_CreatedBy]
	, [MtContractPhysicalAssets_CreatedOn]
	, [MtContractPhysicalAssets_ModifiedBy]
	, [MtContractPhysicalAssets_ModifiedOn]
	, [MtContractPhysicalAssets_IsDeleted]
	, [updated_at]
	, [operation])
		SELECT
			[MtContractPhysicalAssets_Id]
		   ,[MtContractRegistration_Id]
		   ,[MtGenerationUnit_Id]
		   ,[MtContractPhysicalAssetsـPercentInstallEnergyTransaction]
		   ,[MtContractPhysicalAssetsـPercentInstallCapacityTransaction]
		   ,[MtContractPhysicalAssetsـPercentAssignedASCBuyer]
		   ,[MtContractPhysicalAssetsـPercentAssignedASCSeller]
		   ,[MtContractPhysicalAssets_CreatedBy]
		   ,[MtContractPhysicalAssets_CreatedOn]
		   ,[MtContractPhysicalAssets_ModifiedBy]
		   ,[MtContractPhysicalAssets_ModifiedOn]
		   ,[MtContractPhysicalAssets_IsDeleted]
		   ,GETDATE()
		   ,'ALT'
		FROM INSERTED i

END

------------------------------------------------------
ALTER TABLE dbo.MtContractPhysicalAssets ENABLE TRIGGER [audittrg_MtContractPhysicalAssets]
