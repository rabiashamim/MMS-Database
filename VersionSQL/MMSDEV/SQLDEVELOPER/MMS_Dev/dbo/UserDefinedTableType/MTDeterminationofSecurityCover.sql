/****** Object:  UserDefinedTableType [dbo].[MTDeterminationofSecurityCover]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE dbo.MTDeterminationofSecurityCover AS TABLE(
	[ContractType] [nvarchar](max) NULL,
	[BuyerId] [nvarchar](max) NULL,
	[SellerId] [nvarchar](max) NULL,
	[Year] [nvarchar](max) NULL,
	[Month] [nvarchar](max) NULL,
	[GeneratorDispatchProfileforMonth_MWh] [nvarchar](max) NULL,
	[LoadProfileBPC_MWh] [nvarchar](max) NULL,
	[FixedQtyContract] [nvarchar](max) NULL,
	[MonthlyAvgMarginalPrice_PKR/MWh] [nvarchar](max) NULL,
	[DSP] [nvarchar](max) NULL,
	[LineVoltage] [nvarchar](max) NULL
)
