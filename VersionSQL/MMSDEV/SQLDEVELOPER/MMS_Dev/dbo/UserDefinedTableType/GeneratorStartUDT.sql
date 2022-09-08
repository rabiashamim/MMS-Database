/****** Object:  UserDefinedTableType [dbo].[GeneratorStartUDT]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[GeneratorStartUDT] AS TABLE(
	[Date] [date] NULL,
	[GeneratorUnitId] [decimal](18, 0) NULL,
	[NoOfStarts] [decimal](18, 2) NULL,
	[UnitCost] [decimal](18, 2) NULL,
	[CostDetermined] [varchar](max) NULL,
	[ValidationStatus] [varchar](max) NULL,
	[Reason] [varchar](max) NULL
)
