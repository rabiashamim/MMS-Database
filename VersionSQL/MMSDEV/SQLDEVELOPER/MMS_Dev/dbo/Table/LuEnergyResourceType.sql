/****** Object:  Table [dbo].[LuEnergyResourceType]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.LuEnergyResourceType(
	[LuEnergyResourceType_Code] [varchar](4) NOT NULL,
	[LuEnergyResourceType_Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_LuEnergyResourceType] PRIMARY KEY CLUSTERED 
(
	[LuEnergyResourceType_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
