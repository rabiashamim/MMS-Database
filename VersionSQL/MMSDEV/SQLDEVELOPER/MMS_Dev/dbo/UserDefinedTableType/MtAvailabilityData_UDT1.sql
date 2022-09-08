/****** Object:  UserDefinedTableType [dbo].[MtAvailabilityData_UDT1]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[MtAvailabilityData_UDT1] AS TABLE(
	[MtAvailibilityData_Date] [date] NULL,
	[MtAvailibilityData_Hour] [varchar](5) NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NULL,
	[MtAvailibilityData_ActualCapacity] [decimal](18, 0) NULL,
	[MtAvailibilityData_AvailableCapacityASC] [decimal](18, 0) NULL
)
