/****** Object:  Table [dbo].[MTDeterminationofSecurityCover_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MTDeterminationofSecurityCover_Interface(
	[MTDeterminationofSecurityCover_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MTDeterminationofSecurityCover_Interface_RowNumber] [bigint] NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MTDeterminationofSecurityCover_Interface_ContractType] [nvarchar](max) NULL,
	[MTDeterminationofSecurityCover_Interface_Buyer_Id] [nvarchar](max) NULL,
	[MTDeterminationofSecurityCover_Interface_Seller_Id] [nvarchar](max) NULL,
	[MTDeterminationofSecurityCover_Interface_DSP] [varchar](250) NULL,
	[MTDeterminationofSecurityCover_Interface_LineVoltage] [varchar](15) NULL,
	[MTDeterminationofSecurityCover_Interface_Year] [nvarchar](max) NULL,
	[MTDeterminationofSecurityCover_Interface_Month] [nvarchar](max) NULL,
	[MTDeterminationofSecurityCover_Interface_GeneratorDispatchProfileforMonth_MWh] [nvarchar](max) NULL,
	[MTDeterminationofSecurityCover_Interface_LoadProfileBuyer] [nvarchar](max) NULL,
	[MTDeterminationofSecurityCover_Interface_FixedQtyContract] [nvarchar](max) NULL,
	[MTDeterminationofSecurityCover_Interface_MonthlyAvgMarginalPrice] [nvarchar](max) NULL,
	[MTDeterminationofSecurityCover_Interface_IsValid] [bit] NULL,
	[MTDeterminationofSecurityCover_Interface_Message] [nvarchar](max) NULL,
	[MTDeterminationofSecurityCover_Interface_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MTDeterminationofSecurityCover_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
