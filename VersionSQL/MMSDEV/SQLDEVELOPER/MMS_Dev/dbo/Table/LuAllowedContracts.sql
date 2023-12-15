/****** Object:  Table [dbo].[LuAllowedContracts]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.LuAllowedContracts(
	[LuAllowedContracts_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[LuAllowedContracts_SellerCode] [varchar](5) NOT NULL,
	[LuAllowedContracts_BuyerCode] [varchar](5) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LuAllowedContracts_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
