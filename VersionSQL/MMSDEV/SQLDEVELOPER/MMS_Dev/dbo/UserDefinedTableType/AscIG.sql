/****** Object:  UserDefinedTableType [dbo].[AscIG]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[AscIG] AS TABLE(
	[Date] [date] NULL,
	[Hour] [varchar](5) NULL,
	[GeneratorUnitId] [decimal](18, 0) NULL,
	[VariableCost] [decimal](18, 2) NULL,
	[ExpectedEnergy] [decimal](18, 2) NULL,
	[Reason] [varchar](max) NULL
)
