/****** Object:  Table [dbo].[RuWorkFlow_detail_bk_3March2023]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuWorkFlow_detail_bk_3March2023(
	[RuWorkFlow_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[RuWorkFlowHeader_id] [int] NOT NULL,
	[RuWorkFlow_detail_levelId] [int] NULL,
	[RuWorkFlow_detail_description] [varchar](256) NULL,
	[AspNetUsers_UserId] [int] NULL,
	[Lu_Designation_Id] [decimal](18, 0) NULL,
	[RuWorkFlow_detail_CreatedBy] [decimal](18, 0) NOT NULL,
	[RuWorkFlow_detail_CreatedOn] [datetime] NOT NULL,
	[RuWorkFlow_detail_ModifiedBy] [decimal](18, 0) NULL,
	[RuWorkFlow_detail_ModifiedOn] [datetime] NULL,
	[RuWorkFlow_detail_isDeleted] [bit] NOT NULL
) ON [PRIMARY]
