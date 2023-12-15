/****** Object:  Table [dbo].[RuWorkFlow_header]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuWorkFlow_header(
	[RuWorkFlowHeader_id] [int] IDENTITY(1,1) NOT NULL,
	[RuWorkFlowHeader_name] [varchar](256) NULL,
	[RuWorkFlowHeader_description] [varchar](256) NULL,
	[RuWorkFlowHeader_CreatedBy] [decimal](18, 0) NOT NULL,
	[RuWorkFlowHeader_CreatedOn] [datetime] NOT NULL,
	[RuWorkFlowHeader_ModifiedBy] [decimal](18, 0) NULL,
	[RuWorkFlowHeader_ModifiedOn] [datetime] NULL,
	[RuWorkFlowHeader_isDeleted] [bit] NOT NULL,
	[RuModulesProcess_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RuWorkFlowHeader_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.RuWorkFlow_header ADD  DEFAULT ((0)) FOR [RuWorkFlowHeader_isDeleted]
