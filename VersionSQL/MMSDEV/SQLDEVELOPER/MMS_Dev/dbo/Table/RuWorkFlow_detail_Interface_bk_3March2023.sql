/****** Object:  Table [dbo].[RuWorkFlow_detail_Interface_bk_3March2023]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuWorkFlow_detail_Interface_bk_3March2023(
	[RuWorkFlow_detail_id] [int] NULL,
	[RuWorkFlowHeader_id] [int] NULL,
	[RuProcess_ID] [decimal](18, 0) NULL,
	[RuWorkFlow_detail_levelId] [int] NULL,
	[RuWorkFlow_detail_description] [varchar](256) NULL,
	[AspNetUsers_UserId] [int] NULL,
	[Lu_Designation_Id] [decimal](18, 0) NULL,
	[RuWorkFlow_detail_CreatedBy] [decimal](18, 0) NOT NULL,
	[RuWorkFlow_detail_CreatedOn] [datetime] NOT NULL,
	[RuWorkFlow_detail_ModifiedBy] [decimal](18, 0) NULL,
	[RuWorkFlow_detail_ModifiedOn] [datetime] NULL,
	[RuWorkFlow_detail_gen_level] [int] NULL,
	[is_locked] [int] NULL,
	[is_deleted] [int] NULL
) ON [PRIMARY]
