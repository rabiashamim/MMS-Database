/****** Object:  Table [dbo].[RuEventActionCheckList]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RuEventActionCheckList](
	[RuEventActionCheckList_Id] [decimal](18, 0) NOT NULL,
	[RuEventActionCheckList_Description] [varchar](200) NULL,
	[RuEventActionCheckList_FormName] [varchar](50) NULL,
	[RuEventActionCheckList_SubType] [varchar](50) NULL,
	[RuEventActionCheckList_CreatedBy] [int] NOT NULL,
	[RuEventActionCheckList_CreatedOn] [datetime] NOT NULL,
	[RuEventActionCheckList_ModifiedBy] [int] NULL,
	[RuEventActionCheckList_ModifiedOn] [datetime] NULL,
	[RuEventActionCheckList_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[RuEventActionCheckList_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
