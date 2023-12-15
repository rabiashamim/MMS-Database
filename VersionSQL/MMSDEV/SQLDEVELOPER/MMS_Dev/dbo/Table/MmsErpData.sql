/****** Object:  Table [dbo].[MmsErpData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MmsErpData(
	[MmsErpData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MmsErpData_StatementProcessId] [decimal](18, 0) NOT NULL,
	[MmsErpData_StatementType] [varchar](5) NOT NULL,
	[MmsErpData_Month] [varchar](20) NOT NULL,
	[MmsErpData_MpId] [decimal](18, 0) NOT NULL,
	[MmsErpData_MpType] [nvarchar](500) NOT NULL,
	[MmsErpData_SettlementType] [varchar](10) NOT NULL,
	[MmsErpData_PssAmount] [decimal](32, 16) NULL,
	[MmsErpData_FssAmount] [decimal](32, 16) NULL,
	[MmsErpData_DeltaAmount] [decimal](32, 16) NULL,
	[MmsErpData_TotalPssAmount] [decimal](32, 16) NULL,
	[MmsErpData_TotalFssAmount] [decimal](32, 16) NULL,
	[MmsErpData_TotalDeltaAmount] [decimal](32, 16) NULL,
	[MmsErpData_TransferedToERP] [bit] NULL,
	[MmsErpData_ReadFromMms] [bit] NULL,
	[MmsErpData_CreatedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MmsErpData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MmsErpData ADD  DEFAULT ((0)) FOR [MmsErpData_PssAmount]
ALTER TABLE dbo.MmsErpData ADD  DEFAULT ((0)) FOR [MmsErpData_FssAmount]
ALTER TABLE dbo.MmsErpData ADD  DEFAULT ((0)) FOR [MmsErpData_DeltaAmount]
ALTER TABLE dbo.MmsErpData ADD  DEFAULT ((0)) FOR [MmsErpData_TotalPssAmount]
ALTER TABLE dbo.MmsErpData ADD  DEFAULT ((0)) FOR [MmsErpData_TotalFssAmount]
ALTER TABLE dbo.MmsErpData ADD  DEFAULT ((0)) FOR [MmsErpData_TotalDeltaAmount]
ALTER TABLE dbo.MmsErpData ADD  DEFAULT ((0)) FOR [MmsErpData_TransferedToERP]
ALTER TABLE dbo.MmsErpData ADD  DEFAULT ((0)) FOR [MmsErpData_ReadFromMms]
