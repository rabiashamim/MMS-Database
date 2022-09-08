/****** Object:  Table [dbo].[MtPartyRegisteration]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtPartyRegisteration](
	[MtPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[MtPartyRegisteration_Name] [varchar](250) NULL,
	[MtPartyRegisteration_Remarks] [varchar](max) NULL,
	[MtPartyRegisteration_IsPowerPool] [bit] NULL,
	[SrPartyType_Code] [varchar](4) NULL,
	[MtPartyRegisteration_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtPartyRegisteration_CreatedOn] [datetime] NOT NULL,
	[MtPartyRegisteration_ModifiedBy] [decimal](18, 0) NULL,
	[MtPartyRegisteration_ModifiedOn] [datetime] NULL,
	[LuStatus_Code_Approval] [varchar](4) NULL,
	[LuStatus_Code_Applicant] [varchar](4) NULL,
	[MtPartyRegisteration_MPId] [varchar](50) NULL,
	[isDeleted] [bit] NULL,
	[MtPartyRegisteration_IsKE] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MtPartyRegisteration] ADD  DEFAULT ((0)) FOR [isDeleted]
ALTER TABLE [dbo].[MtPartyRegisteration]  WITH CHECK ADD FOREIGN KEY([LuStatus_Code_Approval])
REFERENCES [dbo].[LuStatus] ([LuStatus_Code])
ALTER TABLE [dbo].[MtPartyRegisteration]  WITH CHECK ADD FOREIGN KEY([LuStatus_Code_Applicant])
REFERENCES [dbo].[LuStatus] ([LuStatus_Code])
ALTER TABLE [dbo].[MtPartyRegisteration]  WITH CHECK ADD FOREIGN KEY([SrPartyType_Code])
REFERENCES [dbo].[SrPartyType] ([SrPartyType_Code])
