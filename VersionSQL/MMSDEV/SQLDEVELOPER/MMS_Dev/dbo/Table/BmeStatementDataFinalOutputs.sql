/****** Object:  Table [dbo].[BmeStatementDataFinalOutputs]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataFinalOutputs](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_PartyRegisteration_Id] [decimal](18, 0) NULL,
	[BmeStatementData_PartyName] [nvarchar](200) NULL,
	[BmeStatementData_PartyCategory_Code] [varchar](4) NULL,
	[BmeStatementData_PartyType_Code] [varchar](4) NULL,
	[BmeStatementData_ImbalanceCharges] [decimal](25, 13) NULL,
	[BmeStatementData_SettlementOfLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_AmountPayableReceivable] [decimal](25, 13) NULL,
	[AncillaryServicePayableCharges] [decimal](25, 13) NULL,
	[AncillaryServiceReceivableCharges] [decimal](25, 13) NULL,
	[MOFee] [decimal](25, 13) NULL,
	[OtherChargesPaybale] [decimal](25, 13) NULL,
	[AdjustmentfromESS] [decimal](25, 13) NULL,
	[NetAmountPayableReceivable] [decimal](25, 13) NULL
) ON [PRIMARY]
