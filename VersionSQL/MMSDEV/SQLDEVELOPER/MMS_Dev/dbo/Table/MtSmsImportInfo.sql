/****** Object:  Table [dbo].[MtSmsImportInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtSmsImportInfo](
	[MtSmsImportInfo_Id] [decimal](18, 0) NOT NULL,
	[LuAccountingMonth_Id] [int] NOT NULL,
	[MtSmsImportInfo_Version] [int] NULL,
	[LuStatus_Code] [varchar](20) NULL,
	[MtSmsImportInfo_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtSmsImportInfo_CreatedOn] [datetime] NOT NULL,
	[MtSmsImportInfo_ModifiedBy] [decimal](18, 0) NULL,
	[MtSmsImportInfo_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtSmsImportInfo_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
