/****** Object:  Table [dbo].['Meter Master Data$']    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].['Meter Master Data$'](
	[CDP ID ] [nvarchar](max) NULL,
	[Meter ID] [bigint] NULL,
	[meterName] [nvarchar](max) NULL,
	[meterNo] [bigint] NULL,
	[Status] [nvarchar](max) NULL,
	[Meter Qualifier] [nvarchar](max) NULL,
	[MeterModelType] [nvarchar](max) NULL,
	[Lat] [nvarchar](max) NULL,
	[Long] [nvarchar](max) NULL,
	[Meter Type] [nvarchar](max) NULL,
	[effectiveFrom] [nvarchar](max) NULL,
	[effectiveTo] [nvarchar](max) NULL,
	[CreatedDateTime] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
