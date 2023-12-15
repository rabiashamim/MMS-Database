/****** Object:  Table [dbo].[MtContractPhysicalAssets_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractPhysicalAssets_audit(
	[MtContractPhysicalAssets_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractPhysicalAssets_Id] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtContractPhysicalAssetsـPercentInstallEnergyTransaction] [decimal](18, 5) NULL,
	[MtContractPhysicalAssetsـPercentInstallCapacityTransaction] [decimal](18, 5) NULL,
	[MtContractPhysicalAssetsـPercentAssignedASCBuyer] [decimal](18, 5) NULL,
	[MtContractPhysicalAssetsـPercentAssignedASCSeller] [decimal](18, 5) NULL,
	[MtContractPhysicalAssets_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtContractPhysicalAssets_CreatedOn] [datetime] NOT NULL,
	[MtContractPhysicalAssets_ModifiedBy] [decimal](18, 0) NULL,
	[MtContractPhysicalAssets_ModifiedOn] [datetime] NULL,
	[MtContractPhysicalAssets_IsDeleted] [bit] NOT NULL,
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractPhysicalAssets_audit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
