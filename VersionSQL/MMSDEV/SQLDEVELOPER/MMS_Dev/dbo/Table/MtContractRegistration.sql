/****** Object:  Table [dbo].[MtContractRegistration]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractRegistration(
	[MtContractRegistration_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[SrContractType_Id] [int] NOT NULL,
	[MtContractRegistration_ApplicationNubmer] [varchar](50) NULL,
	[MtContractRegistration_ApplicationDate] [date] NULL,
	[MtContractRegistration_BuyerId] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_SellerId] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_BuyerCategoryId] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_SellerCategoryId] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_EffectiveFrom] [date] NOT NULL,
	[MtContractRegistration_EffectiveTo] [date] NULL,
	[MtContractRegistration_ContractDate] [date] NOT NULL,
	[MtContractRegistration_TransmissionLosses] [nvarchar](6) NULL,
	[MtContractRegistration_DistributionLosses] [nvarchar](6) NULL,
	[MtContractRegistration_AncillaryService] [varchar](6) NULL,
	[MtContractRegistration_Status] [varchar](4) NOT NULL,
	[MtContractRegistration_ApprovalStatus] [varchar](4) NOT NULL,
	[MtContractRegistration_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_CreatedOn] [datetime] NOT NULL,
	[MtContractRegistration_ModifiedBy] [decimal](18, 0) NULL,
	[MtContractRegistration_ModifiedOn] [datetime] NULL,
	[MtContractRegistration_IsDeleted] [bit] NOT NULL,
	[MtContractRegistration_MeterOwner] [varchar](6) NULL,
	[SrSubContractType] [int] NULL,
	[MtContractRegistration_ContractId] [decimal](18, 0) NULL,
 CONSTRAINT [PK__MtContra__A89087554EC16DA5] PRIMARY KEY CLUSTERED 
(
	[MtContractRegistration_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtContractRegistration ADD  DEFAULT ((0)) FOR [MtContractRegistration_IsDeleted]
ALTER TABLE dbo.MtContractRegistration  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__MtCon__2AD6269A] FOREIGN KEY([MtContractRegistration_BuyerId])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.MtContractRegistration CHECK CONSTRAINT [FK__MtContrac__MtCon__2AD6269A]
ALTER TABLE dbo.MtContractRegistration  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__MtCon__2BCA4AD3] FOREIGN KEY([MtContractRegistration_SellerId])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.MtContractRegistration CHECK CONSTRAINT [FK__MtContrac__MtCon__2BCA4AD3]
ALTER TABLE dbo.MtContractRegistration  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__MtCon__2CBE6F0C] FOREIGN KEY([MtContractRegistration_BuyerCategoryId])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
ALTER TABLE dbo.MtContractRegistration CHECK CONSTRAINT [FK__MtContrac__MtCon__2CBE6F0C]
ALTER TABLE dbo.MtContractRegistration  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__MtCon__2DB29345] FOREIGN KEY([MtContractRegistration_SellerCategoryId])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
ALTER TABLE dbo.MtContractRegistration CHECK CONSTRAINT [FK__MtContrac__MtCon__2DB29345]
ALTER TABLE dbo.MtContractRegistration  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__MtCon__2F9ADBB7] FOREIGN KEY([MtContractRegistration_Status])
REFERENCES [dbo].[LuStatus] ([LuStatus_Code])
ALTER TABLE dbo.MtContractRegistration CHECK CONSTRAINT [FK__MtContrac__MtCon__2F9ADBB7]
ALTER TABLE dbo.MtContractRegistration  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__MtCon__308EFFF0] FOREIGN KEY([MtContractRegistration_ApprovalStatus])
REFERENCES [dbo].[LuStatus] ([LuStatus_Code])
ALTER TABLE dbo.MtContractRegistration CHECK CONSTRAINT [FK__MtContrac__MtCon__308EFFF0]
ALTER TABLE dbo.MtContractRegistration  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__SrCon__28EDDE28] FOREIGN KEY([SrContractType_Id])
REFERENCES [dbo].[SrContractType] ([SrContractType_Id])
ALTER TABLE dbo.MtContractRegistration CHECK CONSTRAINT [FK__MtContrac__SrCon__28EDDE28]

CREATE TRIGGER [dbo].[audittrg_MtContractRegistration]
ON dbo.MtContractRegistration
AFTER UPDATE
AS
BEGIN

	INSERT INTO [dbo].[MtContractRegistration_audit] ([MtContractRegistration_Id]
	, [SrContractType_Id]
	, [MtContractRegistration_ApplicationNubmer]
	, [MtContractRegistration_ApplicationDate]
	, [MtContractRegistration_BuyerId]
	, [MtContractRegistration_SellerId]
	, [MtContractRegistration_BuyerCategoryId]
	, [MtContractRegistration_SellerCategoryId]
	, [MtContractRegistration_EffectiveFrom]
	, [MtContractRegistration_EffectiveTo]
	, [MtContractRegistration_ContractDate]
	, [MtContractRegistration_TransmissionLosses]
	, [MtContractRegistration_DistributionLosses]
	, [MtContractRegistration_AncillaryService]
	, [MtContractRegistration_Status]
	, [MtContractRegistration_ApprovalStatus]
	, [MtContractRegistration_CreatedBy]
	, [MtContractRegistration_CreatedOn]
	, [MtContractRegistration_ModifiedBy]
	, [MtContractRegistration_ModifiedOn]
	, [MtContractRegistration_IsDeleted]
	, [MtContractRegistration_MeterOwner]
	, [SrSubContractType]
	, [MtContractRegistration_ContractId]

	, [updated_at]
	, [operation])
		SELECT
			[MtContractRegistration_Id]
		   ,[SrContractType_Id]
		   ,[MtContractRegistration_ApplicationNubmer]
		   ,[MtContractRegistration_ApplicationDate]
		   ,[MtContractRegistration_BuyerId]
		   ,[MtContractRegistration_SellerId]
		   ,[MtContractRegistration_BuyerCategoryId]
		   ,[MtContractRegistration_SellerCategoryId]
		   ,[MtContractRegistration_EffectiveFrom]
		   ,[MtContractRegistration_EffectiveTo]
		   ,[MtContractRegistration_ContractDate]
		   ,[MtContractRegistration_TransmissionLosses]
		   ,[MtContractRegistration_DistributionLosses]
		   ,[MtContractRegistration_AncillaryService]
		   ,[MtContractRegistration_Status]
		   ,[MtContractRegistration_ApprovalStatus]
		   ,[MtContractRegistration_CreatedBy]
		   ,[MtContractRegistration_CreatedOn]
		   ,[MtContractRegistration_ModifiedBy]
		   ,[MtContractRegistration_ModifiedOn]
		   ,[MtContractRegistration_IsDeleted]
		   ,[MtContractRegistration_MeterOwner]
		   ,[SrSubContractType]
		   ,[MtContractRegistration_ContractId]

		   ,GETDATE()
		   ,'ALT'
		FROM inserted i
END
ALTER TABLE dbo.MtContractRegistration ENABLE TRIGGER [audittrg_MtContractRegistration]
