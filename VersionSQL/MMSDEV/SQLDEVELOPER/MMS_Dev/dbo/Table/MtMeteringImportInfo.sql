/****** Object:  Table [dbo].[MtMeteringImportInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtMeteringImportInfo](
	[MtMeteringImportInfo_Id] [decimal](18, 0) NOT NULL,
	[MtMeteringImportInfo_ImportInMMSDate] [datetime] NULL,
	[MtMeteringImportInfo_BatchNo] [int] NULL,
	[Interface_LastRecordId] [decimal](18, 0) NULL,
	[Interface_LastRecordDate] [datetime] NULL,
	[MtMeteringImportInfo_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtMeteringImportInfo_CreatedOn] [datetime] NOT NULL,
	[MtMeteringImportInfo_ModifiedBy] [decimal](18, 0) NULL,
	[MtMeteringImportInfo_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtMeteringImportInfo_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
