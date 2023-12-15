/****** Object:  Table [dbo].[LuDataConfiguration]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.LuDataConfiguration(
	[LuDataConfiguration_Id] [int] IDENTITY(1,1) NOT NULL,
	[LuDataConfiguration_Name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LuDataConfiguration_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
