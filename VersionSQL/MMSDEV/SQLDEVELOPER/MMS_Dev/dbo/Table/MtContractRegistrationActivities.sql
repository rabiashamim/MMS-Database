/****** Object:  Table [dbo].[MtContractRegistrationActivities]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractRegistrationActivities(
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
PRIMARY KEY CLUSTERED 
(
	[MtContractRegistrationActivity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE  TRIGGER [dbo].[audittrg_MtContractRegistrationActivities]
ON dbo.MtContractRegistrationActivities
AFTER UPDATE
AS
BEGIN

INSERT INTO [dbo].[MtContractRegistrationActivities_audit]
           ([MtContractRegistrationActivity_Id]
           ,[MtContractRegistration_Id]
           ,[MtContractRegistrationActivities_Action]
           ,[MtContractRegistrationActivities_ApplicationNo]
           ,[MtContractRegistrationActivities_ApplicationDate]
           ,[MtContractRegistrationActivities_ActivityDateTime]
           ,[MtContractRegistrationActivities_Remarks]
           ,[MtContractRegistrationActivities_CreatedBy]
           ,[MtContractRegistrationActivities_CreatedOn]
           ,[MtContractRegistrationActivities_ModifiedBy]
           ,[MtContractRegistrationActivities_ModifiedOn]
           ,[MtContractRegistrationActivities_Deleted]
           ,[MtContractRegistrationActivities_ref_Id]
           ,[MtContractRegistrationActivities_Notes]
           ,[MtContractRegistrationActivities_FinalDecision]
           ,[MtContractRegistrationActivities_approval_date]
           ,[updated_at]
           ,[operation])
   SELECT  
   [MtContractRegistrationActivity_Id]
           ,[MtContractRegistration_Id]
           ,[MtContractRegistrationActivities_Action]
           ,[MtContractRegistrationActivities_ApplicationNo]
           ,[MtContractRegistrationActivities_ApplicationDate]
           ,[MtContractRegistrationActivities_ActivityDateTime]
           ,[MtContractRegistrationActivities_Remarks]
           ,[MtContractRegistrationActivities_CreatedBy]
           ,[MtContractRegistrationActivities_CreatedOn]
           ,[MtContractRegistrationActivities_ModifiedBy]
           ,[MtContractRegistrationActivities_ModifiedOn]
           ,[MtContractRegistrationActivities_Deleted]
           ,[MtContractRegistrationActivities_ref_Id]
           ,[MtContractRegistrationActivities_Notes]
           ,[MtContractRegistrationActivities_FinalDecision]
           ,[MtContractRegistrationActivities_approval_date]
		   ,GETDATE()
		   ,'ALT'

  FROM inserted i

END


ALTER TABLE dbo.MtContractRegistrationActivities ENABLE TRIGGER [audittrg_MtContractRegistrationActivities]
