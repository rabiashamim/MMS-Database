/****** Object:  Table [dbo].[MtRegisterationActivities]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtRegisterationActivities](
	[MtRegisterationActivity_Id] [decimal](18, 0) NOT NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NULL,
	[MtRegisterationActivities_ACtion] [varchar](30) NULL,
	[MtRegisterationActivities_OrderNo] [varchar](30) NULL,
	[MtRegisterationActivities_DateTime] [datetime] NULL,
	[MtRegisterationActivities_Remarks] [varchar](max) NULL,
	[MtRegisterationActivities_CreatedBy] [int] NOT NULL,
	[MtRegisterationActivities_CreatedOn] [datetime] NOT NULL,
	[MtRegisterationActivities_ModifiedBy] [int] NULL,
	[MtRegisterationActivities_ModifiedOn] [datetime] NULL,
	[MtRegisterationActivities_Deleted] [bit] NULL,
	[MtRegisterationActivities_ApplicationNo] [varchar](30) NULL,
	[MtRegisterationActivities_ApplicationDate] [datetime] NULL,
	[MtRegisterationActivities_OrderDate] [datetime] NULL,
	[ref_Id] [decimal](18, 0) NULL,
	[MtRegisterationActivities_Notes] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtRegisterationActivity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
