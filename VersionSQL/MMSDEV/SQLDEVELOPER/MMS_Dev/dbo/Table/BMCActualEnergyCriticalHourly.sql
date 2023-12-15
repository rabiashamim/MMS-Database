/****** Object:  Table [dbo].[BMCActualEnergyCriticalHourly]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BMCActualEnergyCriticalHourly(
	[BMCActualEnergyCriticalHourly_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BMCActualEnergyCriticalHourly_Year] [int] NOT NULL,
	[BMCActualEnergyCriticalHourly_Month] [int] NOT NULL,
	[BMCActualEnergyCriticalHourly_Day] [int] NOT NULL,
	[BMCActualEnergyCriticalHourly_Hour] [int] NOT NULL,
	[BMCActualEnergyCriticalHourly_ActualEnergy] [decimal](25, 13) NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[BMCActualEnergyCriticalHourly_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.BMCActualEnergyCriticalHourly  WITH CHECK ADD FOREIGN KEY([MtPartyRegisteration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.BMCActualEnergyCriticalHourly  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
