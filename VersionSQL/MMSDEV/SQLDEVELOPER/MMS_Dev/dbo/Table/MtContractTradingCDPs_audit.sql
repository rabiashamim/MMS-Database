/****** Object:  Table [dbo].[MtContractTradingCDPs_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractTradingCDPs_audit(
	[MtContractTradingCDPs_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractTradingCDPs_Id] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
	[RuCDPDetail_Id] [decimal](18, 0) NOT NULL,
	[MtContractTradingCDPs_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtContractTradingCDPs_CreatedOn] [datetime] NOT NULL,
	[MtContractTradingCDPs_ModifiedBy] [decimal](18, 0) NULL,
	[MtContractTradingCDPs_ModifiedOn] [datetime] NULL,
	[MtContractTradingCDPs_IsDeleted] [bit] NOT NULL,
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractTradingCDPs_audit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
