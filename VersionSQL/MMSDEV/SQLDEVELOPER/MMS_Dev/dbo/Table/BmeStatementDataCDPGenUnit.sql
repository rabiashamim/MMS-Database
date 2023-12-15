/****** Object:  Table [dbo].[BmeStatementDataCDPGenUnit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BmeStatementDataCDPGenUnit(
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RuCDPDetail_CdpId] [varchar](100) NOT NULL,
	[BmeStatementDataـGenName] [varchar](100) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_SOUnitId] [int] NOT NULL,
	[SrTechnologyType_Code] [varchar](4) NOT NULL,
	[MtGenerationUnit_InstalledCapacity_KW] [decimal](18, 4) NOT NULL,
	[Lu_CapUnitGenVari_Id] [int] NOT NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
 CONSTRAINT [PK_BmeStatementDataCDPGenUnit] PRIMARY KEY CLUSTERED 
(
	[RuCDPDetail_CdpId] ASC,
	[MtGenerator_Id] ASC,
	[MtGenerationUnit_Id] ASC,
	[MtGenerationUnit_SOUnitId] ASC,
	[BmeStatementData_StatementProcessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.BmeStatementDataCDPGenUnit  WITH CHECK ADD FOREIGN KEY([BmeStatementData_StatementProcessId])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
ALTER TABLE dbo.BmeStatementDataCDPGenUnit  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.BmeStatementDataCDPGenUnit  WITH CHECK ADD FOREIGN KEY([MtGenerationUnit_Id])
REFERENCES [dbo].[MtGenerationUnit] ([MtGenerationUnit_Id])
ALTER TABLE dbo.BmeStatementDataCDPGenUnit  WITH CHECK ADD FOREIGN KEY([SrTechnologyType_Code])
REFERENCES [dbo].[SrTechnologyType] ([SrTechnologyType_Code])
