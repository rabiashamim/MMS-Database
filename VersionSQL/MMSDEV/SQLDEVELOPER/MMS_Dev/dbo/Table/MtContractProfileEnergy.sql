/****** Object:  Table [dbo].[MtContractProfileEnergy]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractProfileEnergy(
	[MtContractProfileEnergy_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
	[MtContractProfileEnergy_DateFrom] [date] NOT NULL,
	[MtContractProfileEnergy_DateTo] [date] NOT NULL,
	[MtContractProfileEnergy_Percentage] [decimal](18, 2) NULL,
	[MtContractProfileEnergy_ContractQuantity_KWH] [decimal](18, 2) NULL,
	[MtContractProfileEnergy_CapQuantity_KWH] [decimal](18, 2) NULL,
	[MtContractProfileEnergy_HourFrom] [int] NOT NULL,
	[MtContractProfileEnergy_HourTo] [int] NULL,
	[MtContractProfileEnergy_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtContractProfileEnergy_CreatedOn] [datetime] NOT NULL,
	[MtContractProfileEnergy_ModifiedBy] [decimal](18, 0) NULL,
	[MtContractProfileEnergy_ModifiedOn] [datetime] NULL,
	[MtContractProfileEnergy_IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractProfileEnergy_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtContractProfileEnergy ADD  DEFAULT ((0)) FOR [MtContractProfileEnergy_IsDeleted]
ALTER TABLE dbo.MtContractProfileEnergy  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__MtCon__4E1F62D7] FOREIGN KEY([MtContractRegistration_Id])
REFERENCES [dbo].[MtContractRegistration] ([MtContractRegistration_Id])
ALTER TABLE dbo.MtContractProfileEnergy CHECK CONSTRAINT [FK__MtContrac__MtCon__4E1F62D7]
CREATE  TRIGGER [dbo].[audittrg_MtContractProfileEnergy]
ON dbo.MtContractProfileEnergy
AFTER UPDATE
AS
BEGIN

INSERT INTO [dbo].[MtContractProfileEnergy_audit]
           ([MtContractProfileEnergy_Id]
           ,[MtContractRegistration_Id]
           ,[MtContractProfileEnergy_DateFrom]
           ,[MtContractProfileEnergy_DateTo]
           ,[MtContractProfileEnergy_Percentage]
           ,[MtContractProfileEnergy_ContractQuantity_KWH]
           ,[MtContractProfileEnergy_CapQuantity_KWH]
           ,[MtContractProfileEnergy_HourFrom]
           ,[MtContractProfileEnergy_HourTo]
           ,[MtContractProfileEnergy_CreatedBy]
           ,[MtContractProfileEnergy_CreatedOn]
           ,[MtContractProfileEnergy_ModifiedBy]
           ,[MtContractProfileEnergy_ModifiedOn]
           ,[MtContractProfileEnergy_IsDeleted]
           ,[updated_at]
           ,[operation])
		   SELECT
		   [MtContractProfileEnergy_Id]
           ,[MtContractRegistration_Id]
           ,[MtContractProfileEnergy_DateFrom]
           ,[MtContractProfileEnergy_DateTo]
           ,[MtContractProfileEnergy_Percentage]
           ,[MtContractProfileEnergy_ContractQuantity_KWH]
           ,[MtContractProfileEnergy_CapQuantity_KWH]
           ,[MtContractProfileEnergy_HourFrom]
           ,[MtContractProfileEnergy_HourTo]
           ,[MtContractProfileEnergy_CreatedBy]
           ,[MtContractProfileEnergy_CreatedOn]
           ,[MtContractProfileEnergy_ModifiedBy]
           ,[MtContractProfileEnergy_ModifiedOn]
           ,[MtContractProfileEnergy_IsDeleted]
           ,GETDATE()
           ,'ALT'
		  FROM inserted i

  
END



ALTER TABLE dbo.MtContractProfileEnergy ENABLE TRIGGER [audittrg_MtContractProfileEnergy]
