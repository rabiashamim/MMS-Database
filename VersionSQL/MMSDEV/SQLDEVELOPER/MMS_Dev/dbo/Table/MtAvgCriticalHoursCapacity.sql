/****** Object:  Table [dbo].[MtAvgCriticalHoursCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtAvgCriticalHoursCapacity(
	[MtAvgCriticalHoursCapacity_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NULL,
	[MtAvgCriticalHoursCapacity_RowNumber] [bigint] NULL,
	[MtAvgCriticalHoursCapacity_SOUnitId] [decimal](18, 0) NULL,
	[MtAvgCriticalHoursCapacity_AVGCapacity] [decimal](25, 13) NULL,
	[MtAvgCriticalHoursCapacity_IsValid] [bit] NULL,
	[MtAvgCriticalHoursCapacity_Message] [nvarchar](1) NULL,
	[MtAvgCriticalHoursCapacity_IsDeleted] [bit] NULL,
	[MtAvgCriticalHoursCapacity_CreatedBy] [int] NULL,
	[MtAvgCriticalHoursCapacity_CreatedOn] [datetime] NULL,
	[MtAvgCriticalHoursCapacity_ModifiedBy] [int] NULL,
	[MtAvgCriticalHoursCapacity_ModifiedOn] [datetime] NULL
) ON [PRIMARY]
