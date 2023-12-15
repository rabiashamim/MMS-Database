/****** Object:  Table [dbo].[MtCapacityObligationsSettings]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtCapacityObligationsSettings(
	[MtCapacityObligationsSettings_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtCapacityObligationsSettings_year] [int] NOT NULL,
	[SrCategory_Code] [varchar](4) NOT NULL,
	[MtCapacityObligationsSettings_Percentage] [decimal](18, 5) NOT NULL,
	[MtCapacityObligationsSettings_EffectiveFrom] [datetime] NOT NULL,
	[MtCapacityObligationsSettings_EffectiveTo] [datetime] NULL,
	[MtCapacityObligationsSettings_IsDisabled] [bit] NOT NULL,
	[MtCapacityObligationsSettings_CreatedDate] [datetime] NOT NULL,
	[MtCapacityObligationsSettings_UpdatedDate] [datetime] NULL,
	[MtCapacityObligationsSettings_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtCapacityObligationsSettings_ModifiedBy] [decimal](18, 0) NULL,
	[MtCapacityObligationsSettings_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtCapacityObligationsSettings_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtCapacityObligationsSettings ADD  DEFAULT ((0)) FOR [MtCapacityObligationsSettings_IsDisabled]
ALTER TABLE dbo.MtCapacityObligationsSettings ADD  DEFAULT (getutcdate()) FOR [MtCapacityObligationsSettings_CreatedDate]
ALTER TABLE dbo.MtCapacityObligationsSettings ADD  DEFAULT ((0)) FOR [MtCapacityObligationsSettings_IsDeleted]
ALTER TABLE dbo.MtCapacityObligationsSettings  WITH CHECK ADD FOREIGN KEY([SrCategory_Code])
REFERENCES [dbo].[SrCategory] ([SrCategory_Code])
ALTER TABLE dbo.MtCapacityObligationsSettings  WITH CHECK ADD FOREIGN KEY([SrCategory_Code])
REFERENCES [dbo].[SrCategory] ([SrCategory_Code])
