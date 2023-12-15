/****** Object:  Table [dbo].[MTGenerationFirmCapacityHourlyData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MTGenerationFirmCapacityHourlyData(
	[MTGenerationFirmCapacityHourlyData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MTGenerationFirmCapacityHourlyData_year] [int] NOT NULL,
	[MTGenerationFirmCapacityHourlyData_Month] [int] NOT NULL,
	[MTGenerationFirmCapacityHourlyData_Day] [int] NOT NULL,
	[MTGenerationFirmCapacityHourlyData_Hour] [int] NOT NULL,
	[MTGenerationFirmCapacityHourlyData_Generation] [decimal](25, 13) NULL,
PRIMARY KEY CLUSTERED 
(
	[MTGenerationFirmCapacityHourlyData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MTGenerationFirmCapacityHourlyData  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.MTGenerationFirmCapacityHourlyData  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.MTGenerationFirmCapacityHourlyData  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.MTGenerationFirmCapacityHourlyData  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.MTGenerationFirmCapacityHourlyData  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.MTGenerationFirmCapacityHourlyData  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
