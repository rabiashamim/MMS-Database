/****** Object:  Table [dbo].[MtFCDGenerators]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCDGenerators(
	[MtFCDGenerators_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCDMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_TotalInstalledCapacity] [decimal](18, 4) NULL,
	[LuEnergyResourceType_Code] [varchar](4) NULL,
	[MtFCDGenerators_EAFactor] [decimal](18, 5) NULL,
	[MtFCDGenerators_TotalGeneration] [decimal](25, 13) NULL,
	[MtFCDGenerators_EnergyGeneratedDuringCurtailment] [decimal](25, 13) NULL,
	[MtFCDGenerators_SoForecastDuringCurtailment] [decimal](25, 13) NULL,
	[MtFCDGenerators_CountNonExistenceHours] [int] NULL,
	[MtFCDGenerators_EnergyEstimated] [decimal](25, 13) NULL,
	[MtFCDGenerators_InitialFirmCapacity] [decimal](25, 13) NULL,
	[MtFCDGenerators_CreatedBy] [int] NOT NULL,
	[MtFCDGenerators_CreatedOn] [date] NOT NULL,
	[MtFCDGenerators_ModifiedBy] [int] NULL,
	[MtFCDGenerators_ModifiedOn] [date] NULL,
	[MtFCDGenerators_IsDeleted] [bit] NOT NULL,
	[ADCValue] [decimal](38, 13) NULL,
	[GeneratorFOR] [decimal](18, 5) NULL,
 CONSTRAINT [PK__MtFCDGen__A623B36369ECE2C1] PRIMARY KEY CLUSTERED 
(
	[MtFCDGenerators_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCDGenerators ADD  CONSTRAINT [DF__MtFCDGene__MtFCD__05AF8EE3]  DEFAULT ((0)) FOR [MtFCDGenerators_IsDeleted]
ALTER TABLE dbo.MtFCDGenerators  WITH CHECK ADD  CONSTRAINT [FK__MtFCDGene__MtFCD__607E0A34] FOREIGN KEY([MtFCDMaster_Id])
REFERENCES [dbo].[MtFCDMaster] ([MtFCDMaster_Id])
ALTER TABLE dbo.MtFCDGenerators CHECK CONSTRAINT [FK__MtFCDGene__MtFCD__607E0A34]
ALTER TABLE dbo.MtFCDGenerators  WITH CHECK ADD  CONSTRAINT [FK__MtFCDGene__MtGen__0797D755] FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.MtFCDGenerators CHECK CONSTRAINT [FK__MtFCDGene__MtGen__0797D755]
ALTER TABLE dbo.MtFCDGenerators  WITH CHECK ADD  CONSTRAINT [FK__MtFCDGene__MtGen__09801FC7] FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.MtFCDGenerators CHECK CONSTRAINT [FK__MtFCDGene__MtGen__09801FC7]
