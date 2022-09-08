/****** Object:  Table [dbo].[EventActionCheckListInfoLogs]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EventActionCheckListInfoLogs](
	[EventActionCheckListInfoLogs] [decimal](18, 0) NOT NULL,
	[EventActionCheckListInfo_Id] [decimal](18, 0) NOT NULL,
	[RuEventActionCheckList_Id] [decimal](18, 0) NULL,
	[MtRegisterationActivity_Id] [decimal](18, 0) NULL,
	[EventActionCheckListInfo_CreatedBy] [int] NOT NULL,
	[EventActionCheckListInfo_CreatedOn] [datetime] NOT NULL,
	[EventActionCheckListInfo_ModifiedBy] [int] NULL,
	[EventActionCheckListInfo_ModifiedOn] [datetime] NULL,
	[EventActionCheckListInfo_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[EventActionCheckListInfoLogs] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[EventActionCheckListInfoLogs]  WITH CHECK ADD FOREIGN KEY([EventActionCheckListInfo_Id])
REFERENCES [dbo].[EventActionCheckListInfo] ([EventActionCheckListInfo_Id])
