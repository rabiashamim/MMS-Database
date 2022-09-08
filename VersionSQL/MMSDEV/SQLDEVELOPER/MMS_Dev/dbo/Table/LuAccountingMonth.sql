/****** Object:  Table [dbo].[LuAccountingMonth]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LuAccountingMonth](
	[LuAccountingMonth_Id] [int] NOT NULL,
	[LuAccountingMonth_Month] [varchar](20) NULL,
	[LuAccountingMonth_MonthName] [varchar](20) NOT NULL,
	[LuAccountingMonth_Year] [int] NOT NULL,
	[LuAccountingMonth_CreatedBy] [int] NOT NULL,
	[LuAccountingMonth_CreatedOn] [datetime] NOT NULL,
	[LuAccountingMonth_ModifiedBy] [int] NULL,
	[LuAccountingMonth_ModifiedOn] [datetime] NULL,
	[LuAccountingMonth_IsDeleted] [bit] NULL,
	[LuAccountingMonth_FromDate] [date] NULL,
	[LuAccountingMonth_ToDate] [date] NULL,
	[LuAccountingMonth_PeriodType] [varchar](100) NULL,
	[LuStatus_Code] [varchar](10) NULL,
	[LuAccountingMonth_Description] [varchar](max) NULL,
	[LuAccountingMonth_MonthShort] [varchar](20) NULL,
	[PeriodTypeID] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[LuAccountingMonth_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[LuAccountingMonth] ADD  DEFAULT (NULL) FOR [LuAccountingMonth_FromDate]
ALTER TABLE [dbo].[LuAccountingMonth] ADD  DEFAULT (NULL) FOR [LuAccountingMonth_ToDate]
ALTER TABLE [dbo].[LuAccountingMonth] ADD  DEFAULT (NULL) FOR [LuAccountingMonth_PeriodType]
ALTER TABLE [dbo].[LuAccountingMonth] ADD  DEFAULT (NULL) FOR [LuStatus_Code]
