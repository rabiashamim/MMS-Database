/****** Object:  UserDefinedTableType [dbo].[MtCriticalHoursCapacity_Interface_UDT]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE dbo.MtCriticalHoursCapacity_Interface_UDT AS TABLE(
	[CriticalHoursCapacity_CriticalHour] [nvarchar](max) NULL,
	[CriticalHoursCapacity_Date] [nvarchar](max) NULL,
	[CriticalHoursCapacity_Hour] [nvarchar](max) NULL,
	[CriticalHoursCapacity_SOUnitId] [nvarchar](max) NULL,
	[CriticalHoursCapacity_Capacity] [nvarchar](max) NULL
)
