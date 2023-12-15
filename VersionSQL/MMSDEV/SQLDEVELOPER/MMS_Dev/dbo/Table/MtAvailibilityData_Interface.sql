/****** Object:  Table [dbo].[MtAvailibilityData_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtAvailibilityData_Interface(
	[MtAvailibilityData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtAvailibilityData_RowNumber] [bigint] NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [nvarchar](max) NULL,
	[MtAvailibilityData_Date] [nvarchar](max) NULL,
	[MtAvailibilityData_Hour] [nvarchar](max) NULL,
	[MtAvailibilityData_AvailableCapacityASC] [nvarchar](max) NULL,
	[MtAvailibilityData_ActualCapacity] [nvarchar](max) NULL,
	[MtAvailibilityData_IsValid] [nvarchar](max) NULL,
	[MtAvailibilityData_Message] [nvarchar](max) NULL,
	[MtAvailibilityData_CreatedBy] [int] NOT NULL,
	[MtAvailibilityData_CreatedOn] [datetime] NOT NULL,
	[MtAvailibilityData_ModifiedBy] [int] NULL,
	[MtAvailibilityData_ModifiedOn] [datetime] NULL,
	[MtAvailibilityData_IsDeleted] [bit] NULL,
	[MtAvailibilityData_GeneratingCapacity] [nvarchar](max) NULL,
	[MtAvailibilityData_SyncStatus] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtAvailibilityData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
