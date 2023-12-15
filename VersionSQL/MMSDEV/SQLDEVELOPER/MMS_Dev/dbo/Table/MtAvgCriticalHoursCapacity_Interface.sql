/****** Object:  Table [dbo].[MtAvgCriticalHoursCapacity_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtAvgCriticalHoursCapacity_Interface(
	[MtAvgCriticalHoursCapacity_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NULL,
	[MtAvgCriticalHoursCapacity_RowNumber] [bigint] NULL,
	[MtAvgCriticalHoursCapacity_SOUnitId] [nvarchar](max) NULL,
	[MtAvgCriticalHoursCapacity_AVGCapacity] [nvarchar](max) NULL,
	[MtAvgCriticalHoursCapacity_IsValid] [nvarchar](max) NULL,
	[MtAvgCriticalHoursCapacity_Message] [nvarchar](max) NULL,
	[MtAvgCriticalHoursCapacity_IsDeleted] [bit] NULL,
	[MtAvgCriticalHoursCapacity_CreatedBy] [int] NULL,
	[MtAvgCriticalHoursCapacity_CreatedOn] [datetime] NULL,
	[MtAvgCriticalHoursCapacity_ModifiedBy] [int] NULL,
	[MtAvgCriticalHoursCapacity_ModifiedOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
