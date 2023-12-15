/****** Object:  Table [dbo].[MtTranmissionLossesImportInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtTranmissionLossesImportInfo(
	[MtTranmissionLossesImportInfo_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtTranmissionLossesImportInfo_ImportInMMSDate] [datetime] NULL,
	[MtTranmissionLossesImportInfo_BatchNo] [int] NULL,
	[Interface_LastRecordId] [decimal](18, 0) NULL,
	[Interface_LastRecordDate] [datetime] NULL,
	[MtTranmissionLossesImportInfo_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtTranmissionLossesImportInfo_CreatedOn] [datetime] NOT NULL,
	[MtTranmissionLossesImportInfo_ModifiedBy] [decimal](18, 0) NULL,
	[MtTranmissionLossesImportInfo_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtTranmissionLossesImportInfo_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
