﻿/****** Object:  Table [dbo].[RuCDPDetail]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RuCDPDetail](
	[RuCDPDetail_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RuCDPDetail_CdpId] [varchar](100) NOT NULL,
	[RuCDPDetail_CdpName] [varchar](50) NULL,
	[RuCDPDetail_CdpStatus] [varchar](10) NULL,
	[RuCDPDetail_ToCustomer] [varchar](200) NULL,
	[RuCDPDetail_FromCustomer] [varchar](200) NULL,
	[IsAssigned] [bit] NULL,
	[RuCDPDetail_LineVoltage] [varchar](20) NULL,
	[RuCDPDetail_Station] [varchar](200) NULL,
	[RuCDPDetail_EffectiveFrom] [datetime] NULL,
	[RuCDPDetail_EffectiveTo] [datetime] NULL,
	[RuCDPDetail_CreatedDateTime] [datetime] NULL,
	[RuCDPDetail_UpdatedDateTime] [datetime] NULL,
	[RuCDPDetail_CreatedBy] [decimal](18, 0) NOT NULL,
	[RuCDPDetail_CreatedOn] [datetime] NOT NULL,
	[RuCDPDetail_ModifiedBy] [decimal](18, 0) NULL,
	[RuCDPDetail_ModifiedOn] [datetime] NULL,
	[RuCDPDetail_ConnectedFromID] [int] NULL,
	[RuCDPDetail_ConnectedToID] [int] NULL,
	[RuCDPDetail_EffectiveFromIPP] [datetime] NULL,
	[RuCDPDetail_EffectiveToIPP] [datetime] NULL,
	[RuCDPDetail_IsEnergyImported] [bit] NULL,
	[RuCDPDetail_TaxZoneID] [int] NULL,
	[RuCDPDetail_CongestedZoneID] [int] NULL,
	[RuCDPDetail_ToCustomerCategory] [nvarchar](4) NULL,
	[RuCDPDetail_FromCustomerCategory] [nvarchar](4) NULL,
	[RuCDPDetail_ConnectedFromCategoryID] [decimal](18, 0) NULL,
	[RuCDPDetail_ConnectedToCategoryID] [decimal](18, 0) NULL,
	[IsBackfeedInclude] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RuCDPDetail_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[RuCDPDetail] ADD  DEFAULT ((1)) FOR [IsBackfeedInclude]
