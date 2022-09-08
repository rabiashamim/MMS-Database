/****** Object:  Table [dbo].[MtSecurityCover]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtSecurityCover](
	[MtSecurityCover_Id] [decimal](18, 0) NOT NULL,
	[MtPartyCategory_Id] [decimal](18, 0) NOT NULL,
	[LuStatus_Code] [varchar](4) NULL,
	[MtSecurityCover_Remarks] [varchar](max) NULL,
	[MtSecurityCover_DeterminedAmount] [decimal](18, 4) NULL,
	[MtSecurityCover_PaidAmount] [decimal](18, 4) NULL,
	[MtSecurityCover_DepositDate] [datetime] NULL,
	[MtSecurityCover_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtSecurityCover_CreatedOn] [datetime] NOT NULL,
	[MtSecurityCover_ModifiedBy] [decimal](18, 0) NULL,
	[MtSecurityCover_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtSecurityCover_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MtSecurityCover]  WITH CHECK ADD FOREIGN KEY([LuStatus_Code])
REFERENCES [dbo].[LuStatus] ([LuStatus_Code])
ALTER TABLE [dbo].[MtSecurityCover]  WITH CHECK ADD FOREIGN KEY([MtPartyCategory_Id])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
