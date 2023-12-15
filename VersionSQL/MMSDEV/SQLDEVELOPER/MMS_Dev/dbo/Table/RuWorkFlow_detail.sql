/****** Object:  Table [dbo].[RuWorkFlow_detail]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuWorkFlow_detail(
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
	[RuWorkFlow_detail_isDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_RuWorkFlow_detail] PRIMARY KEY CLUSTERED 
(
	[RuWorkFlow_detail_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.RuWorkFlow_detail ADD  DEFAULT ((0)) FOR [RuWorkFlow_detail_isDeleted]
ALTER TABLE dbo.RuWorkFlow_detail  WITH CHECK ADD  CONSTRAINT [FK_RuWorkFlow_detail_Lu_Designation] FOREIGN KEY([Lu_Designation_Id])
REFERENCES [dbo].[Lu_Designation] ([Lu_Designation_Id])
ALTER TABLE dbo.RuWorkFlow_detail CHECK CONSTRAINT [FK_RuWorkFlow_detail_Lu_Designation]
ALTER TABLE dbo.RuWorkFlow_detail  WITH CHECK ADD  CONSTRAINT [FK_RuWorkFlow_detail_RuWorkFlow_header] FOREIGN KEY([RuWorkFlowHeader_id])
REFERENCES [dbo].[RuWorkFlow_header] ([RuWorkFlowHeader_id])
ALTER TABLE dbo.RuWorkFlow_detail CHECK CONSTRAINT [FK_RuWorkFlow_detail_RuWorkFlow_header]
