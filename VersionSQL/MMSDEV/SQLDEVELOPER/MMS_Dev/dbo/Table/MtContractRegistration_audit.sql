/****** Object:  Table [dbo].[MtContractRegistration_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractRegistration_audit(
	[MtContractRegistration_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
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
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractRegistration_audit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
