/****** Object:  Table [dbo].[MtContractRegistrationActivities_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractRegistrationActivities_audit(
	[MtContractRegistrationActivity_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractRegistrationActivity_Id] [decimal](18, 0) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NULL,
	[MtContractRegistrationActivities_Action] [varchar](30) NULL,
	[MtContractRegistrationActivities_ApplicationNo] [varchar](30) NULL,
	[MtContractRegistrationActivities_ApplicationDate] [datetime] NULL,
	[MtContractRegistrationActivities_ActivityDateTime] [datetime] NULL,
	[MtContractRegistrationActivities_Remarks] [varchar](max) NULL,
	[MtContractRegistrationActivities_CreatedBy] [int] NOT NULL,
	[MtContractRegistrationActivities_CreatedOn] [datetime] NOT NULL,
	[MtContractRegistrationActivities_ModifiedBy] [int] NULL,
	[MtContractRegistrationActivities_ModifiedOn] [datetime] NULL,
	[MtContractRegistrationActivities_Deleted] [bit] NULL,
	[MtContractRegistrationActivities_ref_Id] [decimal](18, 0) NULL,
	[MtContractRegistrationActivities_Notes] [varchar](max) NULL,
	[MtContractRegistrationActivities_FinalDecision] [int] NULL,
	[MtContractRegistrationActivities_approval_date] [datetime] NULL,
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractRegistrationActivity_audit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
