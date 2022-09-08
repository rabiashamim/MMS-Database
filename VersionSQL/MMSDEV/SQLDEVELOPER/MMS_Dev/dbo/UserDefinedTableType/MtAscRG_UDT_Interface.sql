/****** Object:  UserDefinedTableType [dbo].[MtAscRG_UDT_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[MtAscRG_UDT_Interface] AS TABLE(
	[MtAscRG_Date] [nvarchar](max) NULL,
	[MtAscRG_Hour] [nvarchar](max) NULL,
	[MtGenerationUnit_Id] [nvarchar](max) NULL,
	[MtAscRG_VariableCost] [nvarchar](max) NULL,
	[MtAscRG_ExpectedEnergy] [nvarchar](max) NULL,
	[GenerationUnitTypeARE] [varchar](max) NULL,
	[MtAscRG_IsValid] [bit] NULL,
	[MtAscRG_Message] [nvarchar](max) NULL
)
