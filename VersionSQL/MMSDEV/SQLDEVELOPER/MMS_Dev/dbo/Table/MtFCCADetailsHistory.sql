/****** Object:  Table [dbo].[MtFCCADetailsHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCCADetailsHistory(
	[MtFCCADetailsHistory_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCCADetails_Id] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
	[MtPartyRegistration_BuyerId] [decimal](18, 0) NOT NULL,
	[MtFCCAGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtFCCADetails_AllocationFactor] [decimal](5, 3) NULL,
	[MtFCCADetails_AssociatedCapacity] [decimal](38, 13) NULL,
	[MtFCCADetails_CreatedBy] [int] NOT NULL,
	[MtFCCADetails_CreatedOn] [datetime] NOT NULL,
	[MtFCCADetails_ModifiedBy] [int] NULL,
	[MtFCCADetails_ModifiedOn] [datetime] NULL,
	[MtFCCADetails_IsDeleted] [bit] NOT NULL,
	[MtFCCADetailsHistory_CreatedDate] [datetime] NULL,
	[MtFCCADetailsHistory_CertificateStatus] [varchar](20) NULL,
	[MtFCCADetails_FromCanceledCertificate] [varchar](100) NULL,
	[MtFCCADetails_ToCanceledCertificate] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCCADetailsHistory_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCCADetailsHistory ADD  DEFAULT ((0)) FOR [MtFCCADetails_IsDeleted]
