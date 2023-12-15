/****** Object:  UserDefinedTableType [dbo].[MtBmcSecurityCover_UDT]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE dbo.MtBmcSecurityCover_UDT AS TABLE(
	[MtPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[MtBmcSecurityCover_RequiredSecurityCover] [decimal](38, 13) NOT NULL,
	[MtBmcSecurityCover_SubmittedSecurityCover] [decimal](38, 13) NOT NULL
)
