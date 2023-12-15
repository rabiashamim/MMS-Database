/****** Object:  Table [dbo].[BMCAvailableCapacityGUHourly]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BMCAvailableCapacityGUHourly(
	[BMCAvailableCapacityGUHourly_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BMCAvailableCapacityGUHourly_Date] [date] NULL,
	[BMCAvailableCapacityGUHourly_Hour] [int] NULL,
	[BMCAvailableCapacityGUHourly_CriticalHourCapacity] [decimal](25, 13) NULL,
	[BMCAvailableCapacityGUHourly_SoUnitId] [int] NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NULL,
	[MtGenerator_Id] [decimal](18, 0) NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
 CONSTRAINT [PK_BMCAvailableCapacityGUHourly] PRIMARY KEY CLUSTERED 
(
	[BMCAvailableCapacityGUHourly_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.BMCAvailableCapacityGUHourly  WITH CHECK ADD FOREIGN KEY([MtGenerationUnit_Id])
REFERENCES [dbo].[MtGenerationUnit] ([MtGenerationUnit_Id])
ALTER TABLE dbo.BMCAvailableCapacityGUHourly  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.BMCAvailableCapacityGUHourly  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
