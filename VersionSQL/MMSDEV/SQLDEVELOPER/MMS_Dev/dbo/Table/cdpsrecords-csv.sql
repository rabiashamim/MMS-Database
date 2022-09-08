/****** Object:  Table [dbo].[cdpsrecords-csv]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[cdpsrecords-csv](
	[MtCDPDetail_CdpId] [varchar](max) NULL,
	[MtCDPDetail_CdpCode] [varchar](max) NULL,
	[MtCDPDetail_CdpName] [varchar](max) NULL,
	[MtCDPDetail_EffectiveFrom] [varchar](max) NULL,
	[MtCDPDetail_EffectiveTo] [varchar](max) NULL,
	[MtCDPDetail_LineVoltage] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
