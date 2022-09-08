/****** Object:  Table [dbo].[SrBuildVersions]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SrBuildVersions](
	[SrBuildVersions_number] [varchar](32) NULL,
	[SrBuildVersions_CreatedBy] [varchar](32) NULL,
	[SrBuildVersions_CreatedOn] [datetime] NULL,
	[SrBuildVersions_ModifiedBy] [decimal](18, 0) NULL,
	[SrBuildVersions_ModifiedOn] [datetime] NULL
) ON [PRIMARY]
