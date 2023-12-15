/****** Object:  Table [dbo].[MtContractCertificates]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractCertificates(
	[MtContractCertificates_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NULL,
	[GeneratorParty_Id] [decimal](18, 0) NULL,
	[MtContractCertificates_FromCertificate] [varchar](20) NULL,
	[MtContractCertificates_ToCertificate] [varchar](20) NULL,
	[MtContractCertificates_IsDisabled] [bit] NULL,
	[MtContractCertificates_DisabledDate] [datetime] NULL,
	[MtContractCertificates_CreatedBy] [int] NOT NULL,
	[MtContractCertificates_CreatedOn] [date] NOT NULL,
	[MtContractCertificates_ModifiedBy] [int] NULL,
	[MtContractCertificates_ModifiedOn] [date] NULL,
	[MtContractCertificates_IsDeleted] [bit] NOT NULL,
	[MtContractCertificates_AssociatedCapacity] [decimal](38, 13) NULL,
	[MtContractCertificates_Generator_Id] [decimal](18, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractCertificates_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtContractCertificates ADD  DEFAULT ((0)) FOR [MtContractCertificates_IsDisabled]
ALTER TABLE dbo.MtContractCertificates ADD  DEFAULT (getdate()) FOR [MtContractCertificates_CreatedOn]
ALTER TABLE dbo.MtContractCertificates ADD  DEFAULT ((0)) FOR [MtContractCertificates_IsDeleted]
ALTER TABLE dbo.MtContractCertificates  WITH CHECK ADD FOREIGN KEY([GeneratorParty_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.MtContractCertificates  WITH CHECK ADD FOREIGN KEY([MtContractRegistration_Id])
REFERENCES [dbo].[MtContractRegistration] ([MtContractRegistration_Id])
ALTER TABLE dbo.MtContractCertificates  WITH CHECK ADD FOREIGN KEY([MtContractCertificates_Generator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
