/****** Object:  Table [dbo].[RuWorkFlowCustomProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuWorkFlowCustomProcess(
	[RuWorkFlowCustomProcess_Id] [int] IDENTITY(1,1) NOT NULL,
	[RuModules_Id] [int] NOT NULL,
	[RuWorkFlowCustomProcess_ProcessId] [int] NOT NULL,
	[RuWorkFlowCustomProcess_ProcessName] [nvarchar](50) NOT NULL,
	[RuWorkFlowCustomProcess_CreatedOn] [datetime] NOT NULL,
	[RuWorkFlowCustomProcess_CreatedBy] [int] NOT NULL,
	[RuWorkFlowCustomProcess_ModifiedOn] [datetime] NULL,
	[RuWorkFlowCustomProcess_ModifiedBy] [int] NULL,
	[RuWorkFlowCustomProcess_IsDeleted] [bit] NULL,
 CONSTRAINT [PK__RuWorkFl__F38C29878BE83873] PRIMARY KEY CLUSTERED 
(
	[RuWorkFlowCustomProcess_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.RuWorkFlowCustomProcess ADD  CONSTRAINT [DF__RuWorkFlo__RuWor__255D4466]  DEFAULT ((0)) FOR [RuWorkFlowCustomProcess_IsDeleted]
ALTER TABLE dbo.RuWorkFlowCustomProcess  WITH CHECK ADD  CONSTRAINT [FK__RuWorkFlo__RuMod__2469202D] FOREIGN KEY([RuModules_Id])
REFERENCES [dbo].[RuModules] ([RuModules_Id])
ALTER TABLE dbo.RuWorkFlowCustomProcess CHECK CONSTRAINT [FK__RuWorkFlo__RuMod__2469202D]
