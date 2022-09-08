/****** Object:  Table [dbo].[Users]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Users](
	[Users_Id] [int] NOT NULL,
	[Users_FirstName] [varchar](100) NOT NULL,
	[Users_LastName] [varchar](100) NOT NULL,
	[Users_UserName] [varchar](100) NULL,
	[Users_Email] [varchar](100) NOT NULL,
	[Users_Phone] [varchar](20) NULL,
	[Users_Password] [varchar](100) NOT NULL,
	[Users_Type] [varchar](100) NOT NULL,
	[Users_CreatedBy] [decimal](18, 0) NOT NULL,
	[Users_CreatedOn] [datetime] NOT NULL,
	[Users_ModifiedBy] [decimal](18, 0) NULL,
	[Users_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Users_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
