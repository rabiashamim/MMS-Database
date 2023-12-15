/****** Object:  Table [dbo].[MTDemandForecast_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MTDemandForecast_Interface(
	[MTDemandForecast_Interface_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MTDemandForecast_Interface_RowNumber] [bigint] NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtParty_Id] [nvarchar](max) NULL,
	[MTDemandForecast_Interface_Year] [nvarchar](max) NULL,
	[MTDemandForecast_Interface_Max_Demand_during_peakhours_MW] [nvarchar](max) NULL,
	[MTDemandForecast_Interface_IsValid] [bit] NULL,
	[MTDemandForecast_Interface_Message] [nvarchar](max) NULL,
	[MTDemandForecast_Interface_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MTDemandForecast_Interface_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
