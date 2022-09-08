/****** Object:  UserDefinedTableType [dbo].[MtMarginalPrice_UDT]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[MtMarginalPrice_UDT] AS TABLE(
	[MtMarginalPrice_Date] [date] NULL,
	[MtMarginalPrice_Hour] [varchar](5) NULL,
	[MtMarginalPrice_Price] [decimal](18, 2) NULL
)
