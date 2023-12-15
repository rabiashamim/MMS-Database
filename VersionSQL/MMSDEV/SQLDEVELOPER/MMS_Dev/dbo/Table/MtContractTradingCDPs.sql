/****** Object:  Table [dbo].[MtContractTradingCDPs]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtContractTradingCDPs(
	[MtContractTradingCDPs_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
	[RuCDPDetail_Id] [decimal](18, 0) NOT NULL,
	[MtContractTradingCDPs_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtContractTradingCDPs_CreatedOn] [datetime] NOT NULL,
	[MtContractTradingCDPs_ModifiedBy] [decimal](18, 0) NULL,
	[MtContractTradingCDPs_ModifiedOn] [datetime] NULL,
	[MtContractTradingCDPs_IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtContractTradingCDPs_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtContractTradingCDPs  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__MtCon__495AADBA] FOREIGN KEY([MtContractRegistration_Id])
REFERENCES [dbo].[MtContractRegistration] ([MtContractRegistration_Id])
ALTER TABLE dbo.MtContractTradingCDPs CHECK CONSTRAINT [FK__MtContrac__MtCon__495AADBA]
ALTER TABLE dbo.MtContractTradingCDPs  WITH CHECK ADD  CONSTRAINT [FK__MtContrac__RuCDP__4A4ED1F3] FOREIGN KEY([RuCDPDetail_Id])
REFERENCES [dbo].[RuCDPDetail] ([RuCDPDetail_Id])
ALTER TABLE dbo.MtContractTradingCDPs CHECK CONSTRAINT [FK__MtContrac__RuCDP__4A4ED1F3]
CREATE  TRIGGER [dbo].[audittrg_MtContractTradingCDPs]
ON dbo.MtContractTradingCDPs
AFTER DELETE
AS
BEGIN

INSERT INTO [dbo].[MtContractTradingCDPs_audit]
           ([MtContractTradingCDPs_Id]
           ,[MtContractRegistration_Id]
           ,[RuCDPDetail_Id]
           ,[MtContractTradingCDPs_CreatedBy]
           ,[MtContractTradingCDPs_CreatedOn]
           ,[MtContractTradingCDPs_ModifiedBy]
           ,[MtContractTradingCDPs_ModifiedOn]
           ,[MtContractTradingCDPs_IsDeleted]
           ,[updated_at]
           ,[operation])
   SELECT 
           [MtContractTradingCDPs_Id]
           ,[MtContractRegistration_Id]
           ,[RuCDPDetail_Id]
           ,[MtContractTradingCDPs_CreatedBy]
           ,[MtContractTradingCDPs_CreatedOn]
           ,[MtContractTradingCDPs_ModifiedBy]
           ,[MtContractTradingCDPs_ModifiedOn]
           ,[MtContractTradingCDPs_IsDeleted]
           ,GETDATE()
           ,'DEL'
	FROM deleted  i
END



ALTER TABLE dbo.MtContractTradingCDPs ENABLE TRIGGER [audittrg_MtContractTradingCDPs]
