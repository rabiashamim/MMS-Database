/****** Object:  Table [dbo].[RuWorkFlow_header_bk_3March2023]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuWorkFlow_header_bk_3March2023(
	[RuWorkFlowHeader_id] [int] IDENTITY(1,1) NOT NULL,
	[RuWorkFlowHeader_name] [varchar](256) NULL,
	[RuWorkFlowHeader_description] [varchar](256) NULL,
	[RuWorkFlowHeader_CreatedBy] [decimal](18, 0) NOT NULL,
	[RuWorkFlowHeader_CreatedOn] [datetime] NOT NULL,
	[RuWorkFlowHeader_ModifiedBy] [decimal](18, 0) NULL,
	[RuWorkFlowHeader_ModifiedOn] [datetime] NULL,
	[RuWorkFlowHeader_isDeleted] [bit] NOT NULL,
	[RuModulesProcess_Id] [int] NULL
) ON [PRIMARY]
