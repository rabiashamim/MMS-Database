/****** Object:  Table [dbo].[MtPartyRegisteration_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtPartyRegisteration_audit(
	[MtPartyRegisteration_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
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
	[MtPartyRegisteration_IsKE] [bit] NULL,
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtPartyRegisteration_audit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
