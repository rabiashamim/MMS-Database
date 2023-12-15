/****** Object:  UserDefinedTableType [dbo].[MTDemandForecast]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE dbo.MTDemandForecast AS TABLE(
	[GeneratorId] [nvarchar](max) NULL,
	[Year] [nvarchar](max) NULL,
	[Max_Demand_during_Peakhours_MW] [nvarchar](max) NULL
)
