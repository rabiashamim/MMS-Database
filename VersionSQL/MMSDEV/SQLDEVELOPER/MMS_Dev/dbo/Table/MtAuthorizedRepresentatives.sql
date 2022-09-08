/****** Object:  Table [dbo].[MtAuthorizedRepresentatives]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtAuthorizedRepresentatives](
	[MtAuthorizedRepresentatives_Id] [decimal](18, 0) NOT NULL,
	[MtPartyCategory_Id] [decimal](18, 0) NOT NULL,
	[MtAuthorizedRepresentatives_Saluation] [varchar](4) NULL,
	[MtAuthorizedRepresentatives_Name] [varchar](50) NULL,
	[MtAuthorizedRepresentatives_Designation] [varchar](50) NULL,
	[MtAuthorizedRepresentatives_AddressLine] [varchar](200) NULL,
	[MtAuthorizedRepresentatives_AddressLine2] [varchar](200) NULL,
	[MtAuthorizedRepresentatives_AddressLine3] [varchar](200) NULL,
	[MtAuthorizedRepresentatives_AddressLine4] [varchar](200) NULL,
	[MtAuthorizedRepresentatives_Country] [varchar](50) NULL,
	[MtAuthorizedRepresentatives_Provience] [varchar](50) NULL,
	[MtAuthorizedRepresentatives_City] [varchar](50) NULL,
	[MtAuthorizedRepresentatives_PhoneAreaCode] [varchar](5) NULL,
	[MtAuthorizedRepresentatives_PhoneNumber] [varchar](15) NULL,
	[MtAuthorizedRepresentatives_FaxAreaCode] [varchar](5) NULL,
	[MtAuthorizedRepresentatives_FaxNumber] [varchar](15) NULL,
	[MtAuthorizedRepresentatives_PhoneAreaCode2] [varchar](5) NULL,
	[MtAuthorizedRepresentatives_PhoneNumber2] [varchar](15) NULL,
	[MtAuthorizedRepresentatives_EmailAddress] [varchar](50) NULL,
	[MtAuthorizedRepresentatives_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtAuthorizedRepresentatives_CreatedOn] [datetime] NOT NULL,
	[MtAuthorizedRepresentatives_ModifiedBy] [decimal](18, 0) NULL,
	[MtAuthorizedRepresentatives_ModifiedOn] [datetime] NULL,
	[MtAuthorizedRepresentatives_IsPrimary] [bit] NULL,
	[isDeleted] [bit] NULL,
	[MtAuthorizedRepresentatives_CountryCode] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtAuthorizedRepresentatives_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MtAuthorizedRepresentatives] ADD  DEFAULT ('false') FOR [isDeleted]
ALTER TABLE [dbo].[MtAuthorizedRepresentatives]  WITH CHECK ADD FOREIGN KEY([MtPartyCategory_Id])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
