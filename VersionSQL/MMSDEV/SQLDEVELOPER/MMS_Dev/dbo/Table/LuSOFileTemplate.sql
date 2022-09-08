/****** Object:  Table [dbo].[LuSOFileTemplate]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LuSOFileTemplate](
	[LuSOFileTemplate_Id] [int] NOT NULL,
	[LuSOFileTemplate_Name] [varchar](50) NOT NULL,
	[LuSOFileTemplate_CreatedBy] [int] NOT NULL,
	[LuSOFileTemplate_CreatedOn] [datetime] NOT NULL,
	[LuSOFileTemplate_ModifiedBy] [int] NULL,
	[LuSOFileTemplate_ModifiedOn] [datetime] NULL,
	[LuSOFileTemplate_IsDeleted] [bit] NULL,
	[LuSOFileTemplate_Url] [varchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[LuSOFileTemplate_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
