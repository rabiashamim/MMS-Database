/****** Object:  Table [dbo].[ReportEnergyPurchasedByMpsData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.ReportEnergyPurchasedByMpsData(
	[ReportEnergyPurchasedByMpsData_MPId] [decimal](18, 0) NULL,
	[ReportEnergyPurchasedByMpsData_MPName] [nvarchar](200) NULL,
	[ReportEnergyPurchasedByMpsData_AggregatedStatementId] [decimal](18, 0) NULL,
	[ReportEnergyPurchasedByMpsData_Title] [nvarchar](max) NULL,
	[ReportEnergyPurchasedByMpsData_Energy] [decimal](25, 8) NULL,
	[ReportEnergyPurchasedByMpsData_AdjustedEnergy] [decimal](25, 8) NULL,
	[ReportEnergyPurchasedByMpsData_Total] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
