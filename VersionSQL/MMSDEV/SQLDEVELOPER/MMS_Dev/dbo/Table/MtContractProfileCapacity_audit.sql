/****** Object:  Table [dbo].[MtContractProfileCapacity_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractProfileCapacity_audit(
	[MtContractProfileCapacity_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractProfileCapacity_Id] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
	[MtContractProfileCapacity_DateFrom] [date] NOT NULL,
	[MtContractProfileCapacity_DateTo] [date] NOT NULL,
	[MtContractProfileCapacity_Percentage] [decimal](18, 2) NULL,
	[MtContractProfileCapacity_ContractQuantity_MW] [decimal](18, 2) NULL,
	[MtContractProfileCapacity_CapQuantity_MW] [decimal](18, 2) NULL,
	[MtContractProfileCapacity_IsGuaranteed] [bit] NOT NULL,
	[MtContractProfileCapacity_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtContractProfileCapacity_CreatedOn] [datetime] NOT NULL,
	[MtContractProfileCapacity_ModifiedBy] [decimal](18, 0) NULL,
	[MtContractProfileCapacity_ModifiedOn] [datetime] NULL,
	[MtContractProfileCapacity_IsDeleted] [bit] NOT NULL,
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractProfileCapacity_audit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
