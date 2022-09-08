/****** Object:  UserDefinedTableType [dbo].[MtAvailabilityData_UDT_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[MtAvailabilityData_UDT_Interface] AS TABLE(
	[MtAvailibilityData_Date] [nvarchar](max) NULL,
	[MtAvailibilityData_Hour] [nvarchar](max) NULL,
	[MtGenerationUnit_Id] [nvarchar](max) NULL,
	[MtAvailibilityData_ActualCapacity] [nvarchar](max) NULL,
	[MtAvailibilityData_AvailableCapacityASC] [nvarchar](max) NULL,
	[MtAvailibilityData_IsValid] [bit] NULL,
	[MtAvailibilityData_Message] [nvarchar](max) NULL
)
