/****** Object:  Table [dbo].[MtFCDHourlyData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCDHourlyData(
	[MtFCDHourlyData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCDMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtFCDHourlyData_Year] [int] NOT NULL,
	[MtFCDHourlyData_Month] [int] NOT NULL,
	[MtFCDHourlyData_Day] [int] NOT NULL,
	[MtFCDHourlyData_Hour] [int] NOT NULL,
	[MtFCDHourlyData_Generation] [decimal](25, 13) NULL,
	[MtFCDHourlyData_Curtailment] [decimal](25, 13) NULL,
	[MtFCDHourlyData_SOForecast] [decimal](25, 13) NULL,
	[MtFCDHourlyData_EnergyNonExistent] [decimal](25, 13) NULL,
	[MtFCDHourlyData_Calculation] [decimal](25, 13) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCDHourlyData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
