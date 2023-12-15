/****** Object:  Table [dbo].[MtSecurityCoverMP_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtSecurityCoverMP_Interface(
	[MtSecurityCoverMP_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtSecurityCoverMP_RowNumber] [bigint] NOT NULL,
	[MtPartyRegisteration_Id] [nvarchar](max) NULL,
	[MtSecurityCoverMP_RequiredSecurityCover] [nvarchar](max) NULL,
	[MtSecurityCoverMP_SubmittedSecurityCover] [nvarchar](max) NULL,
	[MtSecurityCoverMP_IsValid] [bit] NULL,
	[MtSecurityCoverMP_Message] [nvarchar](max) NULL,
	[MtSecurityCoverMP_CreatedBy] [int] NOT NULL,
	[MtSecurityCoverMP_CreatedOn] [datetime] NOT NULL,
	[MtSecurityCoverMP_ModifiedBy] [int] NULL,
	[MtSecurityCoverMP_ModifiedOn] [datetime] NULL,
	[MtSecurityCoverMP_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtSecurityCoverMP_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.MtSecurityCoverMP_Interface ADD  DEFAULT ((0)) FOR [MtSecurityCoverMP_IsDeleted]
