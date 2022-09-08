/****** Object:  Table [dbo].[SrCategory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SrCategory](
	[SrCategory_Code] [varchar](4) NOT NULL,
	[SrCategory_Name] [varchar](50) NOT NULL,
	[SrPartyType_Code] [varchar](4) NOT NULL,
	[SrCategory_CreatedBy] [decimal](18, 0) NOT NULL,
	[SrCategory_CreatedOn] [datetime] NOT NULL,
	[SrCategory_ModifiedBy] [decimal](18, 0) NULL,
	[SrCategory_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SrCategory_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
