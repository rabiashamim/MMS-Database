/****** Object:  Table [dbo].[LuStatus]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LuStatus](
	[LuStatus_Code] [varchar](4) NOT NULL,
	[LuStatus_Name] [varchar](50) NOT NULL,
	[LuStatus_Category] [varchar](50) NOT NULL,
	[LuStatus_CreatedBy] [decimal](18, 0) NOT NULL,
	[LuStatus_CreatedOn] [datetime] NOT NULL,
	[LuStatus_ModifiedBy] [decimal](18, 0) NULL,
	[LuStatus_ModifiedOn] [datetime] NULL,
	[Descriptions] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[LuStatus_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
