/****** Object:  Table [dbo].[COCMPWise]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.COCMPWise(
	[COCMPWise_ID] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[YearName] [varchar](9) NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NULL,
	[CapacityCredited] [decimal](38, 13) NULL,
	[DemandForecast_CapacityObligation] [decimal](25, 13) NULL,
	[CapacityObligationCompliance] [decimal](38, 13) NULL,
	[luCOComplianceStatus_Id] [int] NULL,
	[StatementProcessId] [decimal](18, 0) NULL,
	[COCMPWise_IsLeagacy_CO] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[COCMPWise_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.COCMPWise ADD  DEFAULT ((0)) FOR [COCMPWise_IsLeagacy_CO]
ALTER TABLE dbo.COCMPWise  WITH CHECK ADD FOREIGN KEY([luCOComplianceStatus_Id])
REFERENCES [dbo].[luCOComplianceStatus] ([luCOComplianceStatus_Id])
ALTER TABLE dbo.COCMPWise  WITH CHECK ADD FOREIGN KEY([MtPartyRegisteration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.COCMPWise  WITH CHECK ADD FOREIGN KEY([StatementProcessId])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
