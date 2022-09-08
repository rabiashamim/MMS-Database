/****** Object:  Table [dbo].[Sheet11$]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Sheet11$](
	[CDP Serial] [float] NULL,
	[CDP No#] [float] NULL,
	[Date Time Stamp] [datetime] NULL,
	[CDP Station Name] [nvarchar](255) NULL,
	[CDP-ID] [nvarchar](255) NULL,
	[From Customer] [nvarchar](255) NULL,
	[To Customer] [nvarchar](255) NULL,
	[Line_Voltage] [float] NULL,
	[Meter Type] [nvarchar](255) NULL,
	[Meter Name] [nvarchar](255) NULL,
	[Meter ID] [nvarchar](255) NULL,
	[Meter Qualifier] [nvarchar](255) NULL,
	[Metering Data Source] [nvarchar](255) NULL,
	[Data Status] [nvarchar](255) NULL,
	[Creation Date & Time in NTDC SMS] [nvarchar](255) NULL,
	[Incremental Active Energy Import] [float] NULL,
	[Incremental Active Energy Export] [float] NULL
) ON [PRIMARY]
