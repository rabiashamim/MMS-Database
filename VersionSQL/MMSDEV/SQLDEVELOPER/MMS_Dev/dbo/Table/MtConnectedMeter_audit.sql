/****** Object:  Table [dbo].[MtConnectedMeter_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtConnectedMeter_audit(
	[MtConnectedMeter_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
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
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtConnectedMeter_audit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
