/****** Object:  Table [dbo].[BMCAvailableCapacityGU]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BMCAvailableCapacityGU(
	[BMCAvailableCapacityGU_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BMCAvailableCapacityGU_AvgCapacitySO] [decimal](25, 13) NULL,
	[BMCAvailableCapacityGU_AvgCapacityCal] [decimal](25, 13) NULL,
	[BMCAvailableCapacityGU_SoUnitId] [int] NULL,
	[MtGenerator_Id] [decimal](18, 0) NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
 CONSTRAINT [PK_BMCAvailableCapacityGU] PRIMARY KEY CLUSTERED 
(
	[BMCAvailableCapacityGU_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.BMCAvailableCapacityGU  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.BMCAvailableCapacityGU  WITH CHECK ADD FOREIGN KEY([MtGenerationUnit_Id])
REFERENCES [dbo].[MtGenerationUnit] ([MtGenerationUnit_Id])
ALTER TABLE dbo.BMCAvailableCapacityGU  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
