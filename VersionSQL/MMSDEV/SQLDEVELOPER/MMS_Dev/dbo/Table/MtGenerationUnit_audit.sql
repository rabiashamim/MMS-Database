/****** Object:  Table [dbo].[MtGenerationUnit_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtGenerationUnit_audit(
	[MtGenerationUnit_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[SrTechnologyType_Code] [varchar](4) NULL,
	[SrFuelType_Code] [varchar](4) NULL,
	[MtGenerationUnit_UnitNumber] [varchar](10) NULL,
	[MtGenerationUnit_location] [varchar](50) NULL,
	[MtGenerationUnit_IsDisabled] [bit] NULL,
	[MtGenerationUnit_EffectiveFrom] [datetime] NULL,
	[MtGenerationUnit_EffectiveTo] [datetime] NULL,
	[MtGenerationUnit_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_CreatedOn] [datetime] NOT NULL,
	[MtGenerationUnit_ModifiedBy] [decimal](18, 0) NULL,
	[MtGenerationUnit_ModifiedOn] [datetime] NULL,
	[MtGenerationUnit_IsDeleted] [bit] NULL,
	[MtGenerationUnit_UnitName] [varchar](100) NULL,
	[MtGenerationUnit_SOUnitId] [int] NULL,
	[isDeleted] [bit] NOT NULL,
	[MtGenerationUnit_IsEnergyImported] [bit] NULL,
	[MtGenerationUnit_InstalledCapacity_KW_bk] [decimal](18, 4) NULL,
	[MtGenerationUnit_InstalledCapacity_KW] [decimal](18, 4) NULL,
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtGenerationUnit_audit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
