/****** Object:  Table [dbo].[RuGlobalSetting]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuGlobalSetting(
	[RuGlobalSetting_ID] [int] IDENTITY(1,1) NOT NULL,
	[RuGlobalSetting_Name] [varchar](255) NOT NULL,
	[RuGlobalSetting_Key] [varchar](255) NOT NULL,
	[RuGlobalSetting_value] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[RuGlobalSetting_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
