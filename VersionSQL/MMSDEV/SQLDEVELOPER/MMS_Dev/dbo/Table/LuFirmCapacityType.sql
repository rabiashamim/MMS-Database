/****** Object:  Table [dbo].[LuFirmCapacityType]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.LuFirmCapacityType(
	[LuFirmCapacityType_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[LuFirmCapacityType_Name] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LuFirmCapacityType_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
