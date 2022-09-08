/****** Object:  Table [dbo].[EventActionCheckListInfo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EventActionCheckListInfo](
	[EventActionCheckListInfo_Id] [decimal](18, 0) NOT NULL,
	[RuEventActionCheckList_Id] [decimal](18, 0) NOT NULL,
	[MtRegisterationActivity_Id] [decimal](18, 0) NOT NULL,
	[EventActionCheckListInfo_CreatedBy] [int] NOT NULL,
	[EventActionCheckListInfo_CreatedOn] [datetime] NOT NULL,
	[EventActionCheckListInfo_ModifiedBy] [int] NULL,
	[EventActionCheckListInfo_ModifiedOn] [datetime] NULL,
	[EventActionCheckListInfo_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[EventActionCheckListInfo_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[EventActionCheckListInfo]  WITH CHECK ADD FOREIGN KEY([MtRegisterationActivity_Id])
REFERENCES [dbo].[MtRegisterationActivities] ([MtRegisterationActivity_Id])
ALTER TABLE [dbo].[EventActionCheckListInfo]  WITH CHECK ADD FOREIGN KEY([RuEventActionCheckList_Id])
REFERENCES [dbo].[RuEventActionCheckList] ([RuEventActionCheckList_Id])
