/****** Object:  Table [dbo].['BVM Metering Data-Half Hourly$']    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].['BVM Metering Data-Half Hourly$'](
	[Date Time Stamp] [datetime] NULL,
	[CDP Name] [nvarchar](255) NULL,
	[CDP-ID] [nvarchar](255) NULL,
	[From Customer] [nvarchar](255) NULL,
	[To Customer] [nvarchar](255) NULL,
	[LineVoltage] [float] NULL,
	[Incremental Active Energy Import] [float] NULL,
	[Meter Type] [nvarchar](255) NULL,
	[Meter Name] [nvarchar](255) NULL,
	[Meter ID] [float] NULL,
	[Meter Qualifier] [nvarchar](255) NULL,
	[Metering Data Source] [nvarchar](255) NULL,
	[Data Status] [nvarchar](255) NULL,
	[Label] [nvarchar](255) NULL,
	[Creation Date & Time in NTDC SMS] [nvarchar](255) NULL,
	[Incremental Active Energy Export] [float] NULL,
	[Meter Type1] [nvarchar](255) NULL,
	[Meter Name1] [nvarchar](255) NULL,
	[Meter ID1] [float] NULL,
	[Meter Qualifier1] [nvarchar](255) NULL,
	[Metering Data Source1] [nvarchar](255) NULL,
	[Data Status1] [nvarchar](255) NULL,
	[Label1] [nvarchar](255) NULL,
	[Creation Date & Time in NTDC SMS1] [nvarchar](255) NULL
) ON [PRIMARY]
