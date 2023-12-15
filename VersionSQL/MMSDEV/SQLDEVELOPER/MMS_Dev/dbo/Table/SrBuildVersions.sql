/****** Object:  Table [dbo].[SrBuildVersions]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.SrBuildVersions(
	[SrBuildVersions_number] [varchar](32) NULL,
	[SrBuildVersions_CreatedBy] [varchar](32) NULL,
	[SrBuildVersions_CreatedOn] [datetime] NULL,
	[SrBuildVersions_ModifiedBy] [decimal](18, 0) NULL,
	[SrBuildVersions_ModifiedOn] [datetime] NULL,
	[build_version_description] [varchar](256) NULL
) ON [PRIMARY]
