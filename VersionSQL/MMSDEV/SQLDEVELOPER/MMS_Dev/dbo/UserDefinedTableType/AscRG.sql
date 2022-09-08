/****** Object:  UserDefinedTableType [dbo].[AscRG]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[AscRG] AS TABLE(
	[Date] [date] NULL,
	[Hour] [varchar](5) NULL,
	[GeneratorUnitId] [decimal](18, 0) NULL,
	[GenerationUnitType] [varchar](50) NULL,
	[VariableCost] [decimal](18, 2) NULL,
	[ExpectedEnergy] [decimal](18, 2) NULL
)
