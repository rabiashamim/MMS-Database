/****** Object:  Table [dbo].[MtBankDetails]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtBankDetails](
	[MtBankDetail_Id] [decimal](18, 0) NOT NULL,
	[MtPartyCategory_Id] [decimal](18, 0) NOT NULL,
	[MtBankDetails_BankName] [varchar](50) NULL,
	[MtBankDetails_BankNumber] [varchar](50) NULL,
	[MtBankDetails_AccountNumber] [varchar](50) NULL,
	[MtBankDetails_BranchName] [varchar](50) NULL,
	[MtBankDetails_BranchCode] [varchar](10) NULL,
	[MtBankDetails_IBAN] [varchar](10) NULL,
	[MtBankDetails_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtBankDetails_CreatedOn] [datetime] NOT NULL,
	[MtBankDetails_ModifiedBy] [decimal](18, 0) NULL,
	[MtBankDetails_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtBankDetail_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtBankDetails]  WITH CHECK ADD FOREIGN KEY([MtPartyCategory_Id])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
