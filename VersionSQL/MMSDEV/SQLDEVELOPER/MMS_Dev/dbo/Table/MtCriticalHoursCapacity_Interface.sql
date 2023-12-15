/****** Object:  Table [dbo].[MtCriticalHoursCapacity_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtCriticalHoursCapacity_Interface(
	[MtCriticalHoursCapacity_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtCriticalHoursCapacity_RowNumber] [bigint] NULL,
	[MtCriticalHoursCapacity_CriticalHour] [nvarchar](max) NULL,
	[MtCriticalHoursCapacity_Date] [nvarchar](max) NULL,
	[MtCriticalHoursCapacity_Hour] [nvarchar](max) NULL,
	[MtCriticalHoursCapacity_SOUnitId] [nvarchar](max) NULL,
	[MtCriticalHoursCapacity_Capacity] [nvarchar](max) NULL,
	[MtCriticalHoursCapacity_IsValid] [bit] NULL,
	[MtCriticalHoursCapacity_Message] [nvarchar](max) NULL,
	[MtCriticalHoursCapacity_IsDeleted] [bit] NULL,
	[MtCriticalHoursCapacity_CreatedBy] [int] NOT NULL,
	[MtCriticalHoursCapacity_CreatedOn] [datetime] NOT NULL,
	[MtCriticalHoursCapacity_ModifiedBy] [int] NULL,
	[MtCriticalHoursCapacity_ModifiedOn] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.MtCriticalHoursCapacity_Interface ADD  DEFAULT ((0)) FOR [MtCriticalHoursCapacity_IsDeleted]
ALTER TABLE dbo.MtCriticalHoursCapacity_Interface  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
