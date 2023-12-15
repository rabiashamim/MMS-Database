/****** Object:  Table [dbo].[MtFCCAGeneratorDetailsHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCCAGeneratorDetailsHistory(
	[MtFCCAGeneratorDetailsHistory_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCCAGeneratorDetails_Id] [decimal](18, 0) NOT NULL,
	[MtFCCAGenerator_Id] [decimal](18, 0) NULL,
	[MtFCCAGeneratorDetails_FromCertificate] [varchar](100) NULL,
	[MtFCCAGeneratorDetails_ToCertificate] [varchar](100) NULL,
	[MtFCCAGeneratorDetails_RangeCapacity] [decimal](25, 13) NULL,
	[MtFCCAGeneratorDetails_RangeTotalCertificates] [decimal](18, 0) NULL,
	[MtFCCAGeneratorDetails_IsCancelled] [bit] NULL,
	[MtFCCAGeneratorDetails_CancelledDate] [datetime] NULL,
	[MtFCCAGeneratorDetails_CreatedOn] [datetime] NULL,
	[MtFCCAGeneratorDetails_CreatedBy] [int] NOT NULL,
	[MtFCCAGeneratorDetails_ModifiedOn] [datetime] NULL,
	[MtFCCAGeneratorDetails_ModifiedBy] [int] NULL,
	[MtFCCAGeneratorDetails_Isdeleted] [bit] NULL
) ON [PRIMARY]
