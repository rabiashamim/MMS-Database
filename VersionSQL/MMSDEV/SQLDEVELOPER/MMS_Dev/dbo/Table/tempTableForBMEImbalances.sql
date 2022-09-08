/****** Object:  Table [dbo].[tempTableForBMEImbalances]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tempTableForBMEImbalances](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MPId] [varchar](10) NULL,
	[MPName] [varchar](100) NULL,
	[BMECharges] [decimal](18, 4) NULL,
	[AncillaryServicePayableCharges] [decimal](18, 4) NULL,
	[AncillaryServiceReceivableCharges] [decimal](18, 4) NULL,
	[MOFee] [decimal](18, 4) NULL,
	[OtherChargesPaybale] [decimal](18, 4) NULL,
	[AdjustmentfromESS] [decimal](18, 4) NULL,
	[NetAmountPayableReceivable] [decimal](18, 4) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
