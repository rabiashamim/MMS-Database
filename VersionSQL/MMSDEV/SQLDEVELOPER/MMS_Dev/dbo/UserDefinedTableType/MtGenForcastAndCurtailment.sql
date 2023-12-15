/****** Object:  UserDefinedTableType [dbo].[MtGenForcastAndCurtailment]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE dbo.MtGenForcastAndCurtailment AS TABLE(
	[GeneratorId] [nvarchar](max) NULL,
	[Date] [nvarchar](max) NULL,
	[Hour] [nvarchar](max) NULL,
	[Forecast] [nvarchar](max) NULL,
	[Curtailemnt] [nvarchar](max) NULL
)
