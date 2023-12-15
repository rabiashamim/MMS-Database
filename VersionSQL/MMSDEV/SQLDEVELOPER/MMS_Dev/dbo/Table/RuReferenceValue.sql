/****** Object:  Table [dbo].[RuReferenceValue]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuReferenceValue(
	[RuReferenceValue_Id] [int] IDENTITY(1,1) NOT NULL,
	[SrReferenceType_Id] [int] NOT NULL,
	[RuReferenceValue_Value] [decimal](24, 8) NULL,
	[RuReferenceValue_EffectiveFrom] [datetime] NOT NULL,
	[RuReferenceValue_EffectiveTo] [datetime] NOT NULL,
	[RuReferenceValue_CreatedOn] [datetime] NOT NULL,
	[RuReferenceValue_CreatedBy] [decimal](18, 0) NOT NULL,
	[RuReferenceValue_ModifiedOn] [datetime] NULL,
	[RuReferenceValue_ModifiedBy] [decimal](18, 0) NULL,
	[RuReferenceValue_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[RuReferenceValue_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.RuReferenceValue ADD  DEFAULT ((0)) FOR [RuReferenceValue_IsDeleted]
ALTER TABLE dbo.RuReferenceValue  WITH CHECK ADD  CONSTRAINT [FK__RuReferen__SrRef__0F8311E0] FOREIGN KEY([SrReferenceType_Id])
REFERENCES [dbo].[SrReferenceType] ([SrReferenceType_Id])
ALTER TABLE dbo.RuReferenceValue CHECK CONSTRAINT [FK__RuReferen__SrRef__0F8311E0]
ALTER TABLE dbo.RuReferenceValue  WITH CHECK ADD  CONSTRAINT [FK__RuReferen__SrRef__116B5A52] FOREIGN KEY([SrReferenceType_Id])
REFERENCES [dbo].[SrReferenceType] ([SrReferenceType_Id])
ALTER TABLE dbo.RuReferenceValue CHECK CONSTRAINT [FK__RuReferen__SrRef__116B5A52]
ALTER TABLE dbo.RuReferenceValue  WITH CHECK ADD  CONSTRAINT [FK__RuReferen__SrRef__1353A2C4] FOREIGN KEY([SrReferenceType_Id])
REFERENCES [dbo].[SrReferenceType] ([SrReferenceType_Id])
ALTER TABLE dbo.RuReferenceValue CHECK CONSTRAINT [FK__RuReferen__SrRef__1353A2C4]
CREATE TRIGGER [dbo].[audittrg_RuReferenceValue]
ON dbo.RuReferenceValue
AFTER UPDATE
AS
BEGIN
	INSERT INTO RuReferenceValue_audit (RuReferenceValue_Id, SrReferenceType_Id, RuReferenceValue_Value, RuReferenceValue_EffectiveFrom, RuReferenceValue_EffectiveTo, RuReferenceValue_CreatedOn, RuReferenceValue_CreatedBy, RuReferenceValue_ModifiedOn, RuReferenceValue_ModifiedBy, RuReferenceValue_IsDeleted, updated_at, operation)

		SELECT
			RuReferenceValue_Id
		   ,SrReferenceType_Id
		   ,RuReferenceValue_Value
		   ,RuReferenceValue_EffectiveFrom
		   ,RuReferenceValue_EffectiveTo
		   ,RuReferenceValue_CreatedOn
		   ,RuReferenceValue_CreatedBy
		   ,RuReferenceValue_ModifiedOn
		   ,RuReferenceValue_ModifiedBy
		   ,RuReferenceValue_IsDeleted
		   ,GETDATE()
		   ,'ALT'
		FROM DELETED d;
END
ALTER TABLE dbo.RuReferenceValue ENABLE TRIGGER [audittrg_RuReferenceValue]
