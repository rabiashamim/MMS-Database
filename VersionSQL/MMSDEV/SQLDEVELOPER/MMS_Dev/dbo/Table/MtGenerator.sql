/****** Object:  Table [dbo].[MtGenerator]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtGenerator(
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtPartyCategory_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_MeterGeneratorId] [varchar](6) NULL,
	[MtGenerator_Code] [varchar](10) NULL,
	[MtGenerator_Name] [varchar](100) NULL,
	[MtGenerator_NetworkConnectionType] [varchar](30) NULL,
	[MtGenerator_IsDisabled] [bit] NULL,
	[MtGenerator_EffectiveFrom] [datetime] NULL,
	[MtGenerator_EffectiveTo] [datetime] NULL,
	[MtGenerator_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtGenerator_CreatedOn] [datetime] NOT NULL,
	[MtGenerator_ModifiedBy] [decimal](18, 0) NULL,
	[MtGenerator_ModifiedOn] [datetime] NULL,
	[MtGenerator_IsDeleted] [bit] NULL,
	[MtGenerator_Location] [varchar](max) NULL,
	[isDeleted] [bit] NOT NULL,
	[MtGenerator_TotalInstalledCapacity_bk] [int] NULL,
	[MtGenerator_TotalInstalledCapacity] [decimal](18, 4) NULL,
	[Lu_PowerPolicy_Id] [int] NULL,
	[Lu_CapUnitGenVari_Id] [int] NULL,
	[COD_Date] [datetime] NULL,
	[LuEnergyResourceType_Code] [varchar](4) NULL,
	[MtGenerator_NewInstalledCapacity] [decimal](18, 4) NULL,
	[MtGenerator_FOR] [decimal](18, 5) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtGenerator_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.MtGenerator ADD  DEFAULT ((0)) FOR [isDeleted]
ALTER TABLE dbo.MtGenerator ADD  CONSTRAINT [DF_MtGenerator_LuEnergyResourceType_Code]  DEFAULT ('DP') FOR [LuEnergyResourceType_Code]
ALTER TABLE dbo.MtGenerator  WITH CHECK ADD FOREIGN KEY([LuEnergyResourceType_Code])
REFERENCES [dbo].[LuEnergyResourceType] ([LuEnergyResourceType_Code])
ALTER TABLE dbo.MtGenerator  WITH CHECK ADD FOREIGN KEY([MtPartyCategory_Id])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
ALTER TABLE dbo.MtGenerator  WITH CHECK ADD  CONSTRAINT [FK_MtGenerator_CapUnitGenVari] FOREIGN KEY([Lu_CapUnitGenVari_Id])
REFERENCES [dbo].[Lu_CapUnitGenVari] ([Lu_CapUnitGenVari_Id])
ALTER TABLE dbo.MtGenerator CHECK CONSTRAINT [FK_MtGenerator_CapUnitGenVari]
ALTER TABLE dbo.MtGenerator  WITH CHECK ADD  CONSTRAINT [FK_MtGenerator_MtGenerator] FOREIGN KEY([MtGenerator_Id])
REFERENCES dbo.MtGenerator ([MtGenerator_Id])
ALTER TABLE dbo.MtGenerator CHECK CONSTRAINT [FK_MtGenerator_MtGenerator]
ALTER TABLE dbo.MtGenerator  WITH CHECK ADD  CONSTRAINT [FK_MtGenerator_PowerPolicy] FOREIGN KEY([Lu_PowerPolicy_Id])
REFERENCES [dbo].[Lu_PowerPolicy] ([Lu_PowerPolicy_Id])
ALTER TABLE dbo.MtGenerator CHECK CONSTRAINT [FK_MtGenerator_PowerPolicy]

CREATE TRIGGER [dbo].[audittrg_MtGenerator] ON dbo.MtGenerator
AFTER UPDATE
AS
BEGIN

SET NOCOUNT ON;

INSERT INTO [dbo].[MtGenerator_audit]
           ([MtGenerator_Id]
           ,[MtPartyCategory_Id]
           ,[MtGenerator_MeterGeneratorId]
           ,[MtGenerator_Code]
           ,[MtGenerator_Name]
           ,[MtGenerator_NetworkConnectionType]
           ,[MtGenerator_IsDisabled]
           ,[MtGenerator_EffectiveFrom]
           ,[MtGenerator_EffectiveTo]
           ,[MtGenerator_CreatedBy]
           ,[MtGenerator_CreatedOn]
           ,[MtGenerator_ModifiedBy]
           ,[MtGenerator_ModifiedOn]
           ,[MtGenerator_IsDeleted]
           ,[MtGenerator_Location]
           ,[isDeleted]
           ,[MtGenerator_TotalInstalledCapacity_bk]
           ,[MtGenerator_TotalInstalledCapacity]
           ,[Lu_PowerPolicy_Id]
           ,[Lu_CapUnitGenVari_Id]
           ,[updated_at]
           ,[operation])

		   SELECT 
		   [MtGenerator_Id]
           ,[MtPartyCategory_Id]
           ,[MtGenerator_MeterGeneratorId]
           ,[MtGenerator_Code]
           ,[MtGenerator_Name]
           ,[MtGenerator_NetworkConnectionType]
           ,[MtGenerator_IsDisabled]
           ,[MtGenerator_EffectiveFrom]
           ,[MtGenerator_EffectiveTo]
           ,[MtGenerator_CreatedBy]
           ,[MtGenerator_CreatedOn]
           ,[MtGenerator_ModifiedBy]
           ,[MtGenerator_ModifiedOn]
           ,[MtGenerator_IsDeleted]
           ,[MtGenerator_Location]
           ,[isDeleted]
           ,[MtGenerator_TotalInstalledCapacity_bk]
           ,[MtGenerator_TotalInstalledCapacity]
           ,[Lu_PowerPolicy_Id]
           ,[Lu_CapUnitGenVari_Id]
		   ,GETDATE()
           ,'ALT'
    FROM
        inserted i
     
END



ALTER TABLE dbo.MtGenerator ENABLE TRIGGER [audittrg_MtGenerator]
