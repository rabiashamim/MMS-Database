/****** Object:  Table [dbo].[MtMDIImportInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtMDIImportInfo](
	[MtMDIImportInfo_Id] [decimal](18, 0) NOT NULL,
	[MtMDIImportInfo_ImportInMMSDate] [datetime] NULL,
	[MtMDIImportInfo_BatchNo] [int] NULL,
	[Interface_LastRecordId] [decimal](18, 0) NULL,
	[Interface_LastRecordDate] [datetime] NULL,
	[MtMDIImportInfo_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtMDIImportInfo_CreatedOn] [datetime] NOT NULL,
	[MtMDIImportInfo_ModifiedBy] [decimal](18, 0) NULL,
	[MtMDIImportInfo_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtMDIImportInfo_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
