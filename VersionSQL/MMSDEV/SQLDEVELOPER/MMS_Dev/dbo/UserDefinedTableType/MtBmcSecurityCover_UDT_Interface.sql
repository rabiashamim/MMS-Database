/****** Object:  UserDefinedTableType [dbo].[MtBmcSecurityCover_UDT_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE dbo.MtBmcSecurityCover_UDT_Interface AS TABLE(
	[MtPartyRegisteration_Id] [nvarchar](max) NULL,
	[MtBmcSecurityCover_RequiredSecurityCover] [nvarchar](max) NULL,
	[MtBmcSecurityCover_SubmittedSecurityCover] [nvarchar](max) NULL
)
