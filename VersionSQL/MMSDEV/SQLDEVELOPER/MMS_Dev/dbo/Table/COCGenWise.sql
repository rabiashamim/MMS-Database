/****** Object:  Table [dbo].[COCGenWise]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.COCGenWise(
	[COCGenWise_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[YearName] [varchar](9) NOT NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NULL,
	[MtGenerator_Id] [decimal](18, 0) NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NULL,
	[AssociatedCapacity] [decimal](38, 13) NULL,
	[IsEffectiveCONTRACT] [bit] NULL,
	[IsEffectiveGenerator] [bit] NULL,
	[MtGenerator_EffectiveFrom] [datetime] NULL,
	[MtGenerator_EffectiveTo] [datetime] NULL,
	[MtContractRegistration_EffectiveFrom] [datetime] NULL,
	[MtContractRegistration_EffectiveTo] [datetime] NULL,
	[StatementProcessId] [decimal](18, 0) NOT NULL,
	[COCGenWise_IsLeagacy_CO] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[COCGenWise_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.COCGenWise ADD  DEFAULT ((0)) FOR [COCGenWise_IsLeagacy_CO]
ALTER TABLE dbo.COCGenWise  WITH CHECK ADD FOREIGN KEY([MtContractRegistration_Id])
REFERENCES [dbo].[MtContractRegistration] ([MtContractRegistration_Id])
ALTER TABLE dbo.COCGenWise  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.COCGenWise  WITH CHECK ADD FOREIGN KEY([MtPartyRegisteration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.COCGenWise  WITH CHECK ADD FOREIGN KEY([StatementProcessId])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
