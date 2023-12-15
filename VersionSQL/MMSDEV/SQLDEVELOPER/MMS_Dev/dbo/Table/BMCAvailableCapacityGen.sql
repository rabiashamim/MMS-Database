/****** Object:  Table [dbo].[BMCAvailableCapacityGen]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BMCAvailableCapacityGen(
	[BMCAvailableCapacityGen_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BMCAvailableCapacityGen_AvailableCapacityAvg] [decimal](25, 13) NULL,
	[BMCAvailableCapacityGen_AvailableCapacityKE] [decimal](25, 13) NULL,
	[BMCAvailableCapacityGen_AvailableCapacityAfterKE] [decimal](25, 13) NULL,
	[MtGenerator_Id] [decimal](18, 0) NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
 CONSTRAINT [PK_BMCAvailableCapacityGen] PRIMARY KEY CLUSTERED 
(
	[BMCAvailableCapacityGen_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.BMCAvailableCapacityGen  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.BMCAvailableCapacityGen  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
