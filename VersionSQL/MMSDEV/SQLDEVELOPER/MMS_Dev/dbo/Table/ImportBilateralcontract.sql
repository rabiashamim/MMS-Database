/****** Object:  Table [dbo].[ImportBilateralcontract]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ImportBilateralcontract](
	[Date] [float] NULL,
	[Hour] [float] NULL,
	[Contract ID] [nvarchar](255) NULL,
	[Seller] [nvarchar](255) NULL,
	[Seller-Old] [nvarchar](255) NULL,
	[Buyer] [nvarchar](255) NULL,
	[Buyer-Old] [nvarchar](255) NULL,
	[Contract Type] [nvarchar](255) NULL,
	[Meter Owner (MP-ID)] [nvarchar](255) NULL,
	[Meter Owner (MP-ID)-Old] [nvarchar](255) NULL,
	[Relevant CDPs] [nvarchar](255) NULL,
	[Percentage] [nvarchar](255) NULL,
	[Contracted Quantity] [float] NULL,
	[Contract Cap] [nvarchar](255) NULL,
	[Ancillary Services] [nvarchar](255) NULL
) ON [PRIMARY]
