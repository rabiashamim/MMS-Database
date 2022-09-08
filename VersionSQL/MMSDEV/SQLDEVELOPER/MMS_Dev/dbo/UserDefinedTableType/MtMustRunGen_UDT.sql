/****** Object:  UserDefinedTableType [dbo].[MtMustRunGen_UDT]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[MtMustRunGen_UDT] AS TABLE(
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtMustRunGen_Date] [date] NOT NULL,
	[MtMustRunGen_Hour] [varchar](5) NOT NULL,
	[MtMustRunGen_EnergyProduced] [decimal](20, 4) NULL,
	[MtMustRunGen_VariableCost] [decimal](20, 4) NULL
)
