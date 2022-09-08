/****** Object:  Table [dbo].[InterfaceRuCDPDetail]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[InterfaceRuCDPDetail](
	[InterfaceRuCDPDetail_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[InterfaceRuCDPDetail_CdpId] [varchar](100) NOT NULL,
	[InterfaceRuCDPDetail_CdpName] [varchar](100) NULL,
	[InterfaceRuCDPDetail_CdpStatus] [varchar](10) NULL,
	[InterfaceRuCDPDetail_ToCustomer] [varchar](200) NULL,
	[InterfaceRuCDPDetail_FromCustomer] [varchar](200) NULL,
	[InterfaceRuCDPDetail_LineVoltage] [varchar](20) NULL,
	[InterfaceRuCDPDetail_Station] [varchar](200) NULL,
	[InterfaceRuCDPDetail_EffectiveFrom] [datetime] NULL,
	[InterfaceRuCDPDetail_EffectiveTo] [datetime] NULL,
	[InterfaceRuCDPDetail_CreatedDateTime] [datetime] NULL,
	[InterfaceRuCDPDetail_UpdatedDateTime] [datetime] NULL,
	[InterfaceRuCDPDetail_CreatedOn] [datetime] NOT NULL,
	[InterfaceRuCDPDetail_ModifiedOn] [datetime] NULL,
	[InterfaceRuCDPDetail_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[InterfaceRuCDPDetail_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
