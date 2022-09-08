/****** Object:  Table [dbo].['Contracts Data$']    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].['Contracts Data$'](
	[Contract ID] [nvarchar](255) NULL,
	[Date] [datetime] NULL,
	[Hour] [float] NULL,
	[Seller] [nvarchar](255) NULL,
	[Buyer] [nvarchar](255) NULL,
	[Contract Type] [nvarchar](255) NULL,
	[Relevant CDPs] [nvarchar](255) NULL,
	[Percentage] [nvarchar](255) NULL,
	[Contracted Quantity] [float] NULL,
	[Contract Cap] [nvarchar](255) NULL,
	[Ancillary Services] [nvarchar](255) NULL
) ON [PRIMARY]
