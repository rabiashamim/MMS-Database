/****** Object:  Table [dbo].[MtAvailibilityData]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtAvailibilityData](
	[MtAvailibilityData_Id] [decimal](18, 0) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtAvailibilityData_Date] [date] NOT NULL,
	[MtAvailibilityData_Hour] [varchar](5) NOT NULL,
	[MtAvailibilityData_AvailableCapacityASC] [decimal](20, 4) NOT NULL,
	[MtAvailibilityData_ActualCapacity] [decimal](20, 4) NOT NULL,
	[MtAvailibilityData_CreatedBy] [int] NOT NULL,
	[MtAvailibilityData_CreatedOn] [datetime] NOT NULL,
	[MtAvailibilityData_ModifiedBy] [int] NULL,
	[MtAvailibilityData_ModifiedOn] [datetime] NULL,
	[MtAvailibilityData_IsDeleted] [bit] NULL,
	[MtAvailibilityData_RowNumber] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtAvailibilityData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtAvailibilityData]  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
