/****** Object:  Table [dbo].[MtTaxZone]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtTaxZone](
	[MtTaxZone_Id] [int] NOT NULL,
	[MtTaxZone_Name] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtTaxZone_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
