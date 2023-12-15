/****** Object:  Table [dbo].[MtContractProfileCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractProfileCapacity(
	[MtContractProfileCapacity_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
	[MtContractProfileCapacity_DateFrom] [date] NOT NULL,
	[MtContractProfileCapacity_DateTo] [date] NOT NULL,
	[MtContractProfileCapacity_Percentage] [decimal](18, 2) NULL,
	[MtContractProfileCapacity_ContractQuantity_MW] [decimal](18, 2) NULL,
	[MtContractProfileCapacity_CapQuantity_MW] [decimal](18, 2) NULL,
	[MtContractProfileCapacity_IsGuaranteed] [bit] NOT NULL,
	[MtContractProfileCapacity_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtContractProfileCapacity_CreatedOn] [datetime] NOT NULL,
	[MtContractProfileCapacity_ModifiedBy] [decimal](18, 0) NULL,
	[MtContractProfileCapacity_ModifiedOn] [datetime] NULL,
	[MtContractProfileCapacity_IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractProfileCapacity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtContractProfileCapacity ADD  DEFAULT ((0)) FOR [MtContractProfileCapacity_IsDeleted]
ALTER TABLE dbo.MtContractProfileCapacity  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__MtCon__3B0C8E63] FOREIGN KEY([MtContractRegistration_Id])
REFERENCES [dbo].[MtContractRegistration] ([MtContractRegistration_Id])
ALTER TABLE dbo.MtContractProfileCapacity CHECK CONSTRAINT [FK__MtContrac__MtCon__3B0C8E63]
CREATE  TRIGGER [dbo].[audittrg_MtContractProfileCapacity]
ON dbo.MtContractProfileCapacity
AFTER UPDATE
AS
BEGIN

INSERT INTO [dbo].[MtContractProfileCapacity_audit]
           ([MtContractProfileCapacity_Id]
           ,[MtContractRegistration_Id]
           ,[MtContractProfileCapacity_DateFrom]
           ,[MtContractProfileCapacity_DateTo]
           ,[MtContractProfileCapacity_Percentage]
           ,[MtContractProfileCapacity_ContractQuantity_MW]
           ,[MtContractProfileCapacity_CapQuantity_MW]
           ,[MtContractProfileCapacity_IsGuaranteed]
           ,[MtContractProfileCapacity_CreatedBy]
           ,[MtContractProfileCapacity_CreatedOn]
           ,[MtContractProfileCapacity_ModifiedBy]
           ,[MtContractProfileCapacity_ModifiedOn]
           ,[MtContractProfileCapacity_IsDeleted]
           ,[updated_at]
           ,[operation])
     SELECT [MtContractProfileCapacity_Id]
           ,[MtContractRegistration_Id]
           ,[MtContractProfileCapacity_DateFrom]
           ,[MtContractProfileCapacity_DateTo]
           ,[MtContractProfileCapacity_Percentage]
           ,[MtContractProfileCapacity_ContractQuantity_MW]
           ,[MtContractProfileCapacity_CapQuantity_MW]
           ,[MtContractProfileCapacity_IsGuaranteed]
           ,[MtContractProfileCapacity_CreatedBy]
           ,[MtContractProfileCapacity_CreatedOn]
           ,[MtContractProfileCapacity_ModifiedBy]
           ,[MtContractProfileCapacity_ModifiedOn]
           ,[MtContractProfileCapacity_IsDeleted]
           ,GETDATE()
           ,'ALT' FROM inserted i
END



ALTER TABLE dbo.MtContractProfileCapacity ENABLE TRIGGER [audittrg_MtContractProfileCapacity]
