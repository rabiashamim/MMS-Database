/****** Object:  Table [dbo].[Sr_LookupConfig]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Sr_LookupConfig](
	[SrLookup_Id] [int] IDENTITY(1,1) NOT NULL,
	[SrLookup_TableName] [varchar](50) NOT NULL,
	[SrLookup_Controller] [varchar](50) NULL,
	[SrLookup_Action] [varchar](50) NULL,
	[SrLookup_CreatedBy] [decimal](18, 0) NULL,
	[SrLookup_CreatedOn] [datetime] NULL,
	[SrLookup_ModifiedBy] [decimal](18, 0) NULL,
	[SrLookup_ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_Sr_LookupConfig] PRIMARY KEY CLUSTERED 
(
	[SrLookup_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
