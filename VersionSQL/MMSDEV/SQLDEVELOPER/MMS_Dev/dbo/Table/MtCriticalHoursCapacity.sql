/****** Object:  Table [dbo].[MtCriticalHoursCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtCriticalHoursCapacity(
	[MtCriticalHoursCapacity_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtCriticalHoursCapacity_RowNumber] [bigint] NULL,
	[MtCriticalHoursCapacity_CriticalHour] [int] NOT NULL,
	[MtCriticalHoursCapacity_Date] [date] NOT NULL,
	[MtCriticalHoursCapacity_Hour] [int] NOT NULL,
	[MtCriticalHoursCapacity_SOUnitId] [decimal](18, 0) NOT NULL,
	[MtCriticalHoursCapacity_Capacity] [decimal](20, 4) NOT NULL,
	[MtCriticalHoursCapacity_IsDeleted] [bit] NULL,
	[MtCriticalHoursCapacity_CreatedBy] [int] NOT NULL,
	[MtCriticalHoursCapacity_CreatedOn] [datetime] NOT NULL,
	[MtCriticalHoursCapacity_ModifiedBy] [int] NULL,
	[MtCriticalHoursCapacity_ModifiedOn] [datetime] NULL
) ON [PRIMARY]

ALTER TABLE dbo.MtCriticalHoursCapacity ADD  DEFAULT ((0)) FOR [MtCriticalHoursCapacity_IsDeleted]
ALTER TABLE dbo.MtCriticalHoursCapacity  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
