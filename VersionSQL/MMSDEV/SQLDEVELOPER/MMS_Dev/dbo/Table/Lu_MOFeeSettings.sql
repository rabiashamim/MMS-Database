/****** Object:  Table [dbo].[Lu_MOFeeSettings]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lu_MOFeeSettings](
	[Lu_MOFeeSettings_ID] [int] NOT NULL,
	[Lu_MtMOFeeSettings_FeeRate] [decimal](18, 4) NOT NULL,
	[Lu_MtMOFeeSettings_EffectiveFrom] [datetime] NOT NULL,
	[Lu_MOFeeSettings_EffectiveTo] [datetime] NULL,
	[Lu_MOFeeSettings_CreatedBy] [decimal](18, 0) NOT NULL,
	[Lu_MOFeeSettings_CreatedOn] [datetime] NOT NULL,
	[Lu_MOFeeSettings_ModifiedBy] [decimal](18, 0) NULL,
	[Lu_MOFeeSettings_ModifiedOn] [datetime] NULL,
	[Lu_MOFeeSettings_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Lu_MOFeeSettings_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Lu_MOFeeSettings] ADD  CONSTRAINT [DF_Lu_MOFeeSettings_Lu_MOFeeSettings_CreatedBy]  DEFAULT ((1)) FOR [Lu_MOFeeSettings_CreatedBy]
ALTER TABLE [dbo].[Lu_MOFeeSettings] ADD  CONSTRAINT [DF_Lu_MOFeeSettings_Lu_MOFeeSettings_ModifiedBy]  DEFAULT ((1)) FOR [Lu_MOFeeSettings_ModifiedBy]
ALTER TABLE [dbo].[Lu_MOFeeSettings] ADD  CONSTRAINT [DF_Lu_MOFeeSettings_Lu_MOFeeSettings_IsDeleted]  DEFAULT ('false') FOR [Lu_MOFeeSettings_IsDeleted]
