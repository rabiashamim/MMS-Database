/****** Object:  UserDefinedTableType [dbo].[MtAscIG_UDT_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[MtAscIG_UDT_Interface] AS TABLE(
	[MtAscIG_Date] [nvarchar](max) NULL,
	[MtAscIG_Hour] [nvarchar](max) NULL,
	[MtGenerationUnit_Id] [nvarchar](max) NULL,
	[MtAscIG_VariableCost] [nvarchar](max) NULL,
	[EnergyProduceIfNoAncillaryServices] [nvarchar](max) NULL,
	[Reason] [varchar](max) NULL,
	[MtAscIG_IsValid] [bit] NULL,
	[MtAscIG_Message] [nvarchar](max) NULL
)
