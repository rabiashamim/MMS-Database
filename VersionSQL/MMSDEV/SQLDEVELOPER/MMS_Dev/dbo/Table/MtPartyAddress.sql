/****** Object:  Table [dbo].[MtPartyAddress]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtPartyAddress](
	[MtPartyAddress_Id] [decimal](18, 0) NOT NULL,
	[MtPartyCategory_Id] [decimal](18, 0) NOT NULL,
	[MtPartyAddress_AddressLine] [varchar](250) NULL,
	[MtPartyAddress_AddressLine2] [varchar](250) NULL,
	[MtPartyAddress_AddressLine3] [varchar](250) NULL,
	[MtPartyAddress_AddressLine4] [varchar](250) NULL,
	[MtPartyAddress_Country] [varchar](50) NULL,
	[MtPartyAddress_City] [varchar](50) NULL,
	[MtPartyAddress_PhoneAreaCode] [varchar](5) NULL,
	[MtPartyAddress_PhoneNumber] [varchar](15) NULL,
	[MtPartyAddress_FaxAreaCode] [varchar](5) NULL,
	[MtPartyAddress_FaxNumber] [varchar](15) NULL,
	[MtPartyAddress_PhoneAreaCode2] [varchar](5) NULL,
	[MtPartyAddress_PhoneNumber2] [varchar](15) NULL,
	[MtPartyAddress_EmailAddress] [varchar](50) NULL,
	[MtPartyAddress_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtPartyAddress_CreatedOn] [datetime] NOT NULL,
	[MtPartyAddress_ModifiedBy] [decimal](18, 0) NULL,
	[MtPartyAddress_ModifiedOn] [datetime] NULL,
	[MtPartyAddress_province] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtPartyAddress_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtPartyAddress]  WITH CHECK ADD FOREIGN KEY([MtPartyCategory_Id])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
