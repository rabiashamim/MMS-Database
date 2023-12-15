/****** Object:  Table [dbo].[MtSecurityCoverMP]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtSecurityCoverMP(
	[MtSecurityCoverMP_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtSecurityCoverMP_RowNumber] [bigint] NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[MtSecurityCoverMP_RequiredSecurityCover] [decimal](18, 0) NULL,
	[MtSecurityCoverMP_SubmittedSecurityCover] [decimal](18, 0) NULL,
	[MtSecurityCoverMP_CreatedBy] [int] NOT NULL,
	[MtSecurityCoverMP_CreatedOn] [datetime] NOT NULL,
	[MtSecurityCoverMP_ModifiedBy] [int] NULL,
	[MtSecurityCoverMP_ModifiedOn] [datetime] NULL,
	[MtSecurityCoverMP_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtSecurityCoverMP_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtSecurityCoverMP  WITH CHECK ADD FOREIGN KEY([MtPartyRegisteration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.MtSecurityCoverMP  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
ALTER TABLE dbo.MtSecurityCoverMP  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
ALTER TABLE dbo.MtSecurityCoverMP  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
