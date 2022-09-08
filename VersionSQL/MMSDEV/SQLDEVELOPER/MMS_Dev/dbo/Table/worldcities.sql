/****** Object:  Table [dbo].[worldcities]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[worldcities](
	[city] [nvarchar](max) NULL,
	[city_ascii] [nvarchar](max) NULL,
	[lat] [nvarchar](max) NULL,
	[lng] [nvarchar](max) NULL,
	[country] [nvarchar](max) NULL,
	[iso2] [nvarchar](max) NULL,
	[iso3] [nvarchar](max) NULL,
	[admin_name] [nvarchar](max) NULL,
	[capital] [nvarchar](max) NULL,
	[population] [nvarchar](max) NULL,
	[id] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
