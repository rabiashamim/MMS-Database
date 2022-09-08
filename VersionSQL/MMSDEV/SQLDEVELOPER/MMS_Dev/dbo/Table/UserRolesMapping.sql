/****** Object:  Table [dbo].[UserRolesMapping]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[UserRolesMapping](
	[ID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[RoleID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[UserRolesMapping]  WITH CHECK ADD FOREIGN KEY([RoleID])
REFERENCES [dbo].[RoleMaster] ([ID])
ALTER TABLE [dbo].[UserRolesMapping]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([Users_Id])
