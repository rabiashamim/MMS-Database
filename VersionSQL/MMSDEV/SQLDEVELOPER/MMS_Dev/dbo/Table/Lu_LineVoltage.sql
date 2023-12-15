/****** Object:  Table [dbo].[Lu_LineVoltage]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.Lu_LineVoltage(
	[Lu_LineVoltage_Id] [int] NOT NULL,
	[Lu_LineVoltage_Name] [nvarchar](100) NULL,
	[Lu_LineVoltage_Unit] [nvarchar](50) NULL,
	[Lu_LineVoltage_Level] [int] NOT NULL,
 CONSTRAINT [PK_Lu_LineVoltage] PRIMARY KEY CLUSTERED 
(
	[Lu_LineVoltage_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
