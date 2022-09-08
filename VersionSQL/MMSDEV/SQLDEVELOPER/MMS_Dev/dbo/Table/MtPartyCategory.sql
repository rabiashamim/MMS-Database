/****** Object:  Table [dbo].[MtPartyCategory]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtPartyCategory](
	[MtPartyCategory_Id] [decimal](18, 0) NOT NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[LuStatus_Code] [varchar](4) NULL,
	[SrCategory_Code] [varchar](4) NULL,
	[MtPartyCategory_ApplicationId] [varchar](250) NULL,
	[MtPartyCategory_ApplicationDate] [datetime] NULL,
	[MtPartyCategory_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtPartyCategory_CreatedOn] [datetime] NOT NULL,
	[MtPartyCategory_ModifiedBy] [decimal](18, 0) NULL,
	[MtPartyCategory_ModifiedOn] [datetime] NULL,
	[isDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtPartyCategory_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtPartyCategory] ADD  CONSTRAINT [partyCategorySoftDelete]  DEFAULT ((0)) FOR [isDeleted]
ALTER TABLE [dbo].[MtPartyCategory]  WITH CHECK ADD FOREIGN KEY([LuStatus_Code])
REFERENCES [dbo].[LuStatus] ([LuStatus_Code])
ALTER TABLE [dbo].[MtPartyCategory]  WITH CHECK ADD FOREIGN KEY([SrCategory_Code])
REFERENCES [dbo].[SrCategory] ([SrCategory_Code])
