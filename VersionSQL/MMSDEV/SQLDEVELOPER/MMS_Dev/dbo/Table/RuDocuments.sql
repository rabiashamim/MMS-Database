/****** Object:  Table [dbo].[RuDocuments]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RuDocuments](
	[RuDocuments_Id] [decimal](18, 0) NOT NULL,
	[RuDocuments_Name] [varchar](max) NULL,
	[RuDocuments_FormName] [varchar](50) NULL,
	[RuDocuments_SubType] [varchar](50) NULL,
	[SrPartyType_Code] [varchar](4) NULL,
	[SrCategory_Code] [varchar](4) NULL,
	[RuDocuments_CreatedBy] [int] NOT NULL,
	[RuDocuments_CreatedOn] [datetime] NOT NULL,
	[RuDocuments_ModifiedBy] [int] NULL,
	[RuDocuments_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[RuDocuments_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[RuDocuments]  WITH CHECK ADD FOREIGN KEY([SrCategory_Code])
REFERENCES [dbo].[SrCategory] ([SrCategory_Code])
ALTER TABLE [dbo].[RuDocuments]  WITH CHECK ADD FOREIGN KEY([SrPartyType_Code])
REFERENCES [dbo].[SrPartyType] ([SrPartyType_Code])
