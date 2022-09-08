/****** Object:  Table [dbo].[SrPartyType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SrPartyType](
	[SrPartyType_Code] [varchar](4) NOT NULL,
	[SrPartyType_Name] [varchar](50) NOT NULL,
	[SrPartyType_CreatedBy] [decimal](18, 0) NOT NULL,
	[SrPartyType_CreatedOn] [datetime] NOT NULL,
	[SrPartyType_ModifiedBy] [decimal](18, 0) NULL,
	[SrPartyType_ModifiedOn] [datetime] NULL,
	[orderingIndex] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SrPartyType_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
