/****** Object:  Table [dbo].[RuCDPDetail_History]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RuCDPDetail_History](
	[RuCDPDetailHistory_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RuCDPDetail_Id] [decimal](18, 0) NULL,
	[RuCDPDetail_CdpId] [varchar](100) NULL,
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
	[RuCDPDetail_CreatedBy] [decimal](18, 0) NULL,
	[RuCDPDetail_CreatedOn] [datetime] NULL,
	[RuCDPDetail_ModifiedBy] [decimal](18, 0) NULL,
	[RuCDPDetail_ModifiedOn] [datetime] NULL,
	[RuCDPDetail_ConnectedFromID] [int] NULL,
	[RuCDPDetail_ConnectedToID] [int] NULL,
	[RuCDPDetail_EffectiveFromIPP] [datetime] NULL,
	[RuCDPDetail_EffectiveToIPP] [datetime] NULL,
	[RuCDPDetail_IsEnergyImported] [bit] NULL,
	[RuCDPDetail_TaxZoneID] [int] NULL,
	[RuCDPDetail_CongestedZoneID] [int] NULL,
	[IsBackfeedInclude] [bit] NOT NULL,
 CONSTRAINT [PK_RuCDPDetail_History] PRIMARY KEY CLUSTERED 
(
	[RuCDPDetailHistory_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[RuCDPDetail_History] ADD  DEFAULT ((1)) FOR [IsBackfeedInclude]
