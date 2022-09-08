/****** Object:  Table [dbo].[MtCDPDetail]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtCDPDetail](
	[MtCDPDetail_Id] [decimal](18, 0) NOT NULL,
	[MtCDPDetail_CdpId] [varchar](20) NOT NULL,
	[MtCDPDetail_CdpCode] [varchar](20) NULL,
	[MtCDPDetail_LineVoltage] [varchar](20) NULL,
	[MtCDPDetail_EffectiveFrom] [datetime] NULL,
	[MtCDPDetail_EffectiveTo] [datetime] NULL,
	[MtCDPDetail_Primary_MtMeterDetail_Id] [decimal](18, 0) NULL,
	[MtCDPDetail_BackUp_MtMeterDetail_Id] [decimal](18, 0) NULL,
	[MtCDPDetail_Other_MtMeterDetail_Id] [decimal](18, 0) NULL,
	[MtCDPDetail_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtCDPDetail_CreatedOn] [datetime] NOT NULL,
	[MtCDPDetail_ModifiedBy] [decimal](18, 0) NULL,
	[MtCDPDetail_ModifiedOn] [datetime] NULL,
	[MtCDPDetail_CdpName] [varchar](200) NULL,
	[MtCDPDetail_ToCustomer] [varchar](200) NULL,
	[MtCDPDetail_FromCustomer] [varchar](200) NULL,
	[IsAssigned] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtCDPDetail_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtCDPDetail]  WITH CHECK ADD FOREIGN KEY([MtCDPDetail_Primary_MtMeterDetail_Id])
REFERENCES [dbo].[MtMeterDetail] ([MtMeterDetail_Id])
ALTER TABLE [dbo].[MtCDPDetail]  WITH CHECK ADD FOREIGN KEY([MtCDPDetail_BackUp_MtMeterDetail_Id])
REFERENCES [dbo].[MtMeterDetail] ([MtMeterDetail_Id])
ALTER TABLE [dbo].[MtCDPDetail]  WITH CHECK ADD FOREIGN KEY([MtCDPDetail_Other_MtMeterDetail_Id])
REFERENCES [dbo].[MtMeterDetail] ([MtMeterDetail_Id])
