/****** Object:  Table [dbo].[SrStatementDef]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SrStatementDef](
	[SrStatementDef_ID] [int] NOT NULL,
	[SrStatementDef_Name] [nvarchar](50) NULL,
	[SrStatementDef_Predecessor_ID] [decimal](18, 0) NULL,
	[SrStatementDef_CreatedBy] [decimal](18, 0) NULL,
	[SrStatementDef_CreatedOn] [datetime] NULL,
	[SrStatementDef_ModifiedBy] [decimal](18, 0) NULL,
	[SrStatementDef_ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_StatementDef] PRIMARY KEY CLUSTERED 
(
	[SrStatementDef_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
