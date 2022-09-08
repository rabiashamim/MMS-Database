/****** Object:  Table [dbo].[BMEInputsSOFilesVersions]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BMEInputsSOFilesVersions](
	[BMEInputsSOFilesVersions_Id] [int] IDENTITY(1,1) NOT NULL,
	[SettlementProcessId] [int] NULL,
	[SOFileTemplateId] [int] NULL,
	[Version] [int] NULL,
	[BMEInputsSOFilesVersions_CreatedBy] [int] NULL,
	[BMEInputsSOFilesVersions_CreatedOn] [datetime] NULL,
	[BMEInputsSOFilesVersions_ModifiedBy] [int] NULL,
	[BMEInputsSOFilesVersions_ModifiedOn] [datetime] NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NULL,
 CONSTRAINT [PK_BMEInputsSOFilesVersions] PRIMARY KEY CLUSTERED 
(
	[BMEInputsSOFilesVersions_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
