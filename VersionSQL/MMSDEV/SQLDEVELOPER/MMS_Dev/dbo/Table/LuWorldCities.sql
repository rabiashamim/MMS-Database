/****** Object:  Table [dbo].[LuWorldCities]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LuWorldCities](
	[LuWorld] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[LuWorld_CountryCode] [varchar](4) NULL,
	[LuWorld_Country] [varchar](200) NULL,
	[LuWorld_State] [varchar](200) NULL,
	[LuWorld_City] [varchar](200) NULL,
	[LuWorld_CreatedBy] [int] NULL,
	[LuWorld_CreatedOn] [datetime] NULL,
	[LuWorld_ModifiedBy] [int] NULL,
	[LuWorld_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[LuWorld] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
