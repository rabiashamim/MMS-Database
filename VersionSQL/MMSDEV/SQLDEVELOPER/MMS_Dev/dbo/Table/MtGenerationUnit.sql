/****** Object:  Table [dbo].[MtGenerationUnit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtGenerationUnit(
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[SrTechnologyType_Code] [varchar](4) NULL,
	[SrFuelType_Code] [varchar](4) NULL,
	[MtGenerationUnit_UnitNumber] [varchar](10) NULL,
	[MtGenerationUnit_location] [varchar](50) NULL,
	[MtGenerationUnit_IsDisabled] [bit] NULL,
	[MtGenerationUnit_EffectiveFrom] [datetime] NULL,
	[MtGenerationUnit_EffectiveTo] [datetime] NULL,
	[MtGenerationUnit_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_CreatedOn] [datetime] NOT NULL,
	[MtGenerationUnit_ModifiedBy] [decimal](18, 0) NULL,
	[MtGenerationUnit_ModifiedOn] [datetime] NULL,
	[MtGenerationUnit_IsDeleted] [bit] NULL,
	[MtGenerationUnit_UnitName] [varchar](100) NULL,
	[MtGenerationUnit_SOUnitId] [int] NULL,
	[isDeleted] [bit] NOT NULL,
	[MtGenerationUnit_IsEnergyImported] [bit] NULL,
	[MtGenerationUnit_InstalledCapacity_KW_bk] [decimal](18, 4) NULL,
	[MtGenerationUnit_InstalledCapacity_KW] [decimal](18, 4) NULL,
	[MtGeneratorUnit_NewInstalledCapacity] [decimal](18, 4) NULL,
	[Lu_CapUnitGenVari_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtGenerationUnit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtGenerationUnit ADD  DEFAULT ((0)) FOR [isDeleted]
ALTER TABLE dbo.MtGenerationUnit  WITH CHECK ADD FOREIGN KEY([Lu_CapUnitGenVari_Id])
REFERENCES [dbo].[Lu_CapUnitGenVari] ([Lu_CapUnitGenVari_Id])
ALTER TABLE dbo.MtGenerationUnit  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.MtGenerationUnit  WITH CHECK ADD FOREIGN KEY([SrFuelType_Code])
REFERENCES [dbo].[SrFuelType] ([SrFuelType_Code])
ALTER TABLE dbo.MtGenerationUnit  WITH CHECK ADD FOREIGN KEY([SrTechnologyType_Code])
REFERENCES [dbo].[SrTechnologyType] ([SrTechnologyType_Code])


CREATE TRIGGER [dbo].[audittrg_MtGenerationUnit]
ON dbo.MtGenerationUnit
AFTER UPDATE
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO [dbo].[MtGenerationUnit_audit] ([MtGenerationUnit_Id]
	, [MtGenerator_Id]
	, [SrTechnologyType_Code]
	, [SrFuelType_Code]
	, [MtGenerationUnit_UnitNumber]
	, [MtGenerationUnit_location]
	, [MtGenerationUnit_IsDisabled]
	, [MtGenerationUnit_EffectiveFrom]
	, [MtGenerationUnit_EffectiveTo]
	, [MtGenerationUnit_CreatedBy]
	, [MtGenerationUnit_CreatedOn]
	, [MtGenerationUnit_ModifiedBy]
	, [MtGenerationUnit_ModifiedOn]
	, [MtGenerationUnit_IsDeleted]
	, [MtGenerationUnit_UnitName]
	, [MtGenerationUnit_SOUnitId]
	, [isDeleted]
	, [MtGenerationUnit_IsEnergyImported]
	, [MtGenerationUnit_InstalledCapacity_KW_bk]
	, [MtGenerationUnit_InstalledCapacity_KW]
	, [updated_at]
	, [operation])
		SELECT
			[MtGenerationUnit_Id]
		   ,[MtGenerator_Id]
		   ,[SrTechnologyType_Code]
		   ,[SrFuelType_Code]
		   ,[MtGenerationUnit_UnitNumber]
		   ,[MtGenerationUnit_location]
		   ,[MtGenerationUnit_IsDisabled]
		   ,[MtGenerationUnit_EffectiveFrom]
		   ,[MtGenerationUnit_EffectiveTo]
		   ,[MtGenerationUnit_CreatedBy]
		   ,[MtGenerationUnit_CreatedOn]
		   ,[MtGenerationUnit_ModifiedBy]
		   ,[MtGenerationUnit_ModifiedOn]
		   ,[MtGenerationUnit_IsDeleted]
		   ,[MtGenerationUnit_UnitName]
		   ,[MtGenerationUnit_SOUnitId]
		   ,[isDeleted]
		   ,[MtGenerationUnit_IsEnergyImported]
		   ,[MtGenerationUnit_InstalledCapacity_KW_bk]
		   ,[MtGenerationUnit_InstalledCapacity_KW]
		   ,GETDATE()
		   ,'ALT'
		FROM INSERTED i

END
ALTER TABLE dbo.MtGenerationUnit ENABLE TRIGGER [audittrg_MtGenerationUnit]
