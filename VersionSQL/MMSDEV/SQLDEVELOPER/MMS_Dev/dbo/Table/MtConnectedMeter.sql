/****** Object:  Table [dbo].[MtConnectedMeter]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtConnectedMeter(
	[MtConnectedMeter_Id] [decimal](18, 0) NOT NULL,
	[MtPartyCategory_Id] [decimal](18, 0) NOT NULL,
	[MtCDPDetail_Id] [decimal](18, 0) NOT NULL,
	[MtPartyCategory_Id_TaxZone] [decimal](18, 0) NULL,
	[MtPartyCategory_Id_FromCustomer] [decimal](18, 0) NULL,
	[MtPartyCategory_Id_ToCustomer] [decimal](18, 0) NULL,
	[MtConnectedMeter_CongestionZone] [varchar](50) NULL,
	[MtConnectedMeter_FactorDetails] [varchar](50) NULL,
	[MtConnectedMeter_EffectiveFrom] [datetime] NULL,
	[MtConnectedMeter_EffectiveTo] [datetime] NULL,
	[MtConnectedMeter_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtConnectedMeter_CreatedOn] [datetime] NOT NULL,
	[MtConnectedMeter_ModifiedBy] [decimal](18, 0) NULL,
	[MtConnectedMeter_ModifiedOn] [datetime] NULL,
	[MtConnectedMeter_ConnectedFrom] [decimal](18, 0) NULL,
	[MtConnectedMeter_ConnectedTo] [decimal](18, 0) NULL,
	[MtConnectedMeter_UnitId] [decimal](18, 0) NULL,
	[IsAssigned] [bit] NULL,
	[CongestedZone_Id] [int] NULL,
	[TaxZone_Id] [int] NULL,
	[MtConnectedMeter_isDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtConnectedMeter_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtConnectedMeter ADD  DEFAULT ((0)) FOR [MtConnectedMeter_isDeleted]
ALTER TABLE dbo.MtConnectedMeter  WITH NOCHECK ADD FOREIGN KEY([MtPartyCategory_Id])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
ALTER TABLE dbo.MtConnectedMeter  WITH CHECK ADD FOREIGN KEY([MtPartyCategory_Id_TaxZone])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
ALTER TABLE dbo.MtConnectedMeter  WITH CHECK ADD FOREIGN KEY([MtPartyCategory_Id_FromCustomer])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
ALTER TABLE dbo.MtConnectedMeter  WITH CHECK ADD FOREIGN KEY([MtPartyCategory_Id_ToCustomer])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
CREATE TRIGGER [dbo].[audittrg_MtConnectedMeter]
ON dbo.MtConnectedMeter
AFTER UPDATE
AS
BEGIN

	SET NOCOUNT ON;
	INSERT INTO MtConnectedMeter_audit (MtConnectedMeter_Id, MtPartyCategory_Id, MtCDPDetail_Id, MtPartyCategory_Id_TaxZone, MtPartyCategory_Id_FromCustomer, MtPartyCategory_Id_ToCustomer, MtConnectedMeter_CongestionZone, MtConnectedMeter_FactorDetails, MtConnectedMeter_EffectiveFrom, MtConnectedMeter_EffectiveTo, MtConnectedMeter_CreatedBy, MtConnectedMeter_CreatedOn, MtConnectedMeter_ModifiedBy, MtConnectedMeter_ModifiedOn, MtConnectedMeter_ConnectedFrom, MtConnectedMeter_ConnectedTo, MtConnectedMeter_UnitId, IsAssigned, CongestedZone_Id, TaxZone_Id, MtConnectedMeter_isDeleted, updated_at, operation)
		SELECT
			MtConnectedMeter_Id
		   ,MtPartyCategory_Id
		   ,MtCDPDetail_Id
		   ,MtPartyCategory_Id_TaxZone
		   ,MtPartyCategory_Id_FromCustomer
		   ,MtPartyCategory_Id_ToCustomer
		   ,MtConnectedMeter_CongestionZone
		   ,MtConnectedMeter_FactorDetails
		   ,MtConnectedMeter_EffectiveFrom
		   ,MtConnectedMeter_EffectiveTo
		   ,MtConnectedMeter_CreatedBy
		   ,MtConnectedMeter_CreatedOn
		   ,MtConnectedMeter_ModifiedBy
		   ,MtConnectedMeter_ModifiedOn
		   ,MtConnectedMeter_ConnectedFrom
		   ,MtConnectedMeter_ConnectedTo
		   ,MtConnectedMeter_UnitId
		   ,IsAssigned
		   ,CongestedZone_Id
		   ,TaxZone_Id
		   ,MtConnectedMeter_isDeleted
		   ,GETDATE()
		   ,'ALT'
		FROM DELETED d;
END
ALTER TABLE dbo.MtConnectedMeter ENABLE TRIGGER [audittrg_MtConnectedMeter]
