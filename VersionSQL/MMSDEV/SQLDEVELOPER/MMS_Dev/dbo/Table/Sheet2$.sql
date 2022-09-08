/****** Object:  Table [dbo].[Sheet2$]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Sheet2$](
	[Date] [datetime] NULL,
	[Hour] [float] NULL,
	[Contract ID] [float] NULL,
	[Seller] [float] NULL,
	[Buyer] [float] NULL,
	[Seller Category] [nvarchar](255) NULL,
	[Buyer Category] [nvarchar](255) NULL,
	[Contract Type] [nvarchar](255) NULL,
	[Meter Owner] [nvarchar](255) NULL,
	[CDP ID] [nvarchar](255) NULL,
	[Percentage] [nvarchar](255) NULL,
	[Contracted Quantity (kWh)] [float] NULL,
	[Cap Quantity (kWh)] [nvarchar](255) NULL,
	[Ancillary Services] [nvarchar](255) NULL,
	[Distrubution Loss] [nvarchar](255) NULL,
	[Transmission Loss] [nvarchar](255) NULL,
	[F17] [datetime] NULL
) ON [PRIMARY]
