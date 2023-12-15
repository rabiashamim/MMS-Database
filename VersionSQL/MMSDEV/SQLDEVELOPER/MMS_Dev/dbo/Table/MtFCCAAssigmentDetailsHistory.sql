/****** Object:  Table [dbo].[MtFCCAAssigmentDetailsHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCCAAssigmentDetailsHistory(
	[MtFCCAAssigmentDetailsHistory_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCCAAssigmentDetails_Id] [decimal](18, 0) NOT NULL,
	[MtFCCADetails_Id] [decimal](18, 0) NULL,
	[MtFCCAAssigmentDetails_FromCertificate] [varchar](100) NULL,
	[MtFCCAAssigmentDetails_ToCertificate] [varchar](100) NULL,
	[MtFCCAAssigmentDetails_CreatedBy] [int] NOT NULL,
	[MtFCCAAssigmentDetails_CreatedOn] [datetime] NOT NULL,
	[MtFCCAAssigmentDetails_ModifiedBy] [int] NULL,
	[MtFCCAAssigmentDetails_ModifiedOn] [datetime] NULL,
	[MtFCCAAssigmentDetails_IsDeleted] [bit] NOT NULL
) ON [PRIMARY]
