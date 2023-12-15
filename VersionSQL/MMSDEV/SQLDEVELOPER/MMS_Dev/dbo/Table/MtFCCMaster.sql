/****** Object:  Table [dbo].[MtFCCMaster]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCCMaster(
	[MtFCCMaster_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtPartyRegistration_Id] [decimal](18, 0) NOT NULL,
	[MtFCDMaster_Id] [decimal](18, 0) NOT NULL,
	[LuStatus_Code] [varchar](15) NULL,
	[MtFCCMaster_ApprovalCode] [varchar](15) NULL,
	[LuFirmCapacityType_Id] [decimal](18, 0) NULL,
	[MtFCCMaster_InitialFirmCapacity] [decimal](25, 13) NOT NULL,
	[MtFCCMaster_TotalCertificates] [decimal](18, 0) NULL,
	[MtFCCMaster_IssuanceDate] [datetime] NULL,
	[MtFCCMaster_ExpiryDate] [datetime] NULL,
	[MtFCCMaster_CreatedBy] [int] NOT NULL,
	[MtFCCMaster_CreatedOn] [date] NOT NULL,
	[MtFCCMaster_ModifiedBy] [int] NULL,
	[MtFCCMaster_ModifiedOn] [date] NULL,
	[MtFCCMaster_IsDeleted] [bit] NOT NULL,
	[MtFCCMaster_ExecutionTime] [datetime] NULL,
	[MtFCCMaster_RefernceId] [decimal](18, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCCMaster_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCCMaster ADD  CONSTRAINT [DF_MtFCCMaster_MtFCCMaster_IsDeleted]  DEFAULT ((0)) FOR [MtFCCMaster_IsDeleted]
ALTER TABLE dbo.MtFCCMaster  WITH CHECK ADD FOREIGN KEY([LuFirmCapacityType_Id])
REFERENCES [dbo].[LuFirmCapacityType] ([LuFirmCapacityType_Id])
ALTER TABLE dbo.MtFCCMaster  WITH CHECK ADD FOREIGN KEY([MtFCDMaster_Id])
REFERENCES [dbo].[MtFCDMaster] ([MtFCDMaster_Id])
ALTER TABLE dbo.MtFCCMaster  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.MtFCCMaster  WITH CHECK ADD FOREIGN KEY([MtPartyRegistration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
