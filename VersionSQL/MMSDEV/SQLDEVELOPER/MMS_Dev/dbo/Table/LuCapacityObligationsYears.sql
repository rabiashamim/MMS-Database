/****** Object:  Table [dbo].[LuCapacityObligationsYears]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.LuCapacityObligationsYears(
	[LuCapacityObligationsYears_Name] [int] NOT NULL,
	[LuCapacityObligationsYears_Discription] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[LuCapacityObligationsYears_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
