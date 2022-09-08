/****** Object:  Table [dbo].['CDP Master Data$']    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].['CDP Master Data$'](
	[CDP ID ] [nvarchar](255) NULL,
	[CDP Name] [nvarchar](255) NULL,
	[CDP STATUS] [nvarchar](255) NULL,
	[Effective From] [nvarchar](255) NULL,
	[Effective To] [nvarchar](255) NULL,
	[Station] [nvarchar](255) NULL,
	[Line Voltage] [float] NULL,
	[From Customer] [nvarchar](255) NULL,
	[To Customer] [nvarchar](255) NULL,
	[Created Date & Time] [nvarchar](255) NULL
) ON [PRIMARY]
