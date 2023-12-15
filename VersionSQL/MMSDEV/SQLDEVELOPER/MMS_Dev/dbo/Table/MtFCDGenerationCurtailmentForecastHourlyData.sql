/****** Object:  Table [dbo].[MtFCDGenerationCurtailmentForecastHourlyData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCDGenerationCurtailmentForecastHourlyData(
	[MtFCDGenerationCurtailmentForecastHourlyData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCDMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtFCDGenerationCurtailmentForecastHourlyData_year] [int] NOT NULL,
	[MtFCDGenerationCurtailmentForecastHourlyData_Month] [int] NOT NULL,
	[MtFCDGenerationCurtailmentForecastHourlyData_Day] [int] NOT NULL,
	[MtFCDGenerationCurtailmentForecastHourlyData_Hour] [int] NOT NULL,
	[MtFCDGenerationCurtailmentForecastHourlyData_Generation] [decimal](25, 13) NULL,
	[MtFCDGenerationCurtailmentForecastHourlyData_Curtailment] [decimal](25, 13) NULL,
	[MtFCDGenerationCurtailmentForecastHourlyData_SoForecast] [decimal](25, 13) NULL,
	[MtFCDGenerationCurtailmentForecastHourlyData_EnergyNonExistent] [decimal](25, 13) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCDGenerationCurtailmentForecastHourlyData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCDGenerationCurtailmentForecastHourlyData  WITH CHECK ADD FOREIGN KEY([MtFCDMaster_Id])
REFERENCES [dbo].[MtFCDMaster] ([MtFCDMaster_Id])
