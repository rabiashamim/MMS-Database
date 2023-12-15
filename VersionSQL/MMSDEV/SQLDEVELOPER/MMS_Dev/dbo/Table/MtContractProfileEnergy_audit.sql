/****** Object:  Table [dbo].[MtContractProfileEnergy_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractProfileEnergy_audit(
	[MtContractProfileEnergy_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractProfileEnergy_Id] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
	[MtContractProfileEnergy_DateFrom] [date] NOT NULL,
	[MtContractProfileEnergy_DateTo] [date] NOT NULL,
	[MtContractProfileEnergy_Percentage] [decimal](18, 2) NULL,
	[MtContractProfileEnergy_ContractQuantity_KWH] [decimal](18, 2) NULL,
	[MtContractProfileEnergy_CapQuantity_KWH] [decimal](18, 2) NULL,
	[MtContractProfileEnergy_HourFrom] [int] NOT NULL,
	[MtContractProfileEnergy_HourTo] [int] NULL,
	[MtContractProfileEnergy_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtContractProfileEnergy_CreatedOn] [datetime] NOT NULL,
	[MtContractProfileEnergy_ModifiedBy] [decimal](18, 0) NULL,
	[MtContractProfileEnergy_ModifiedOn] [datetime] NULL,
	[MtContractProfileEnergy_IsDeleted] [bit] NOT NULL,
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractProfileEnergy_audit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
