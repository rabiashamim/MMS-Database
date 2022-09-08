/****** Object:  UserDefinedTableType [dbo].[GeneratorBlackStartUDT]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[GeneratorBlackStartUDT] AS TABLE(
	[Date] [date] NULL,
	[GeneratorUnitId] [decimal](18, 0) NULL,
	[CapabilityCharges] [decimal](18, 2) NULL,
	[Remarks] [varchar](max) NULL,
	[ValidationStatus] [varchar](max) NULL,
	[Reason] [varchar](max) NULL
)
