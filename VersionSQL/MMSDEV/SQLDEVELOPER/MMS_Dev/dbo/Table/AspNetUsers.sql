/****** Object:  Table [dbo].[AspNetUsers]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.AspNetUsers(
	[Id] [nvarchar](128) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEndDateUtc] [datetime] NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
	[UserId] [int] NOT NULL,
	[Lu_Designation_Id] [decimal](18, 0) NULL,
	[Lu_Department_Id] [decimal](18, 0) NULL,
	[Lu_ReportTo] [decimal](18, 0) NULL,
	[is_enabled] [bit] NULL,
	[EmployeeID] [int] NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON dbo.AspNetUsers
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER TABLE dbo.AspNetUsers ADD  DEFAULT ((0)) FOR [UserId]
ALTER TABLE dbo.AspNetUsers ADD  DEFAULT ((0)) FOR [EmployeeID]

CREATE TRIGGER [dbo].[audittrg_AspNetUsers] ON dbo.AspNetUsers
AFTER UPDATE
AS
BEGIN

SET NOCOUNT ON;

INSERT INTO [dbo].[AspNetUsers_audit]
           ([Id]
           ,[FirstName]
           ,[LastName]
           ,[Email]
           ,[EmailConfirmed]
           ,[PasswordHash]
           ,[SecurityStamp]
           ,[PhoneNumber]
           ,[PhoneNumberConfirmed]
           ,[TwoFactorEnabled]
           ,[LockoutEndDateUtc]
           ,[LockoutEnabled]
           ,[AccessFailedCount]
           ,[UserName]
           ,[UserId]
           ,[Lu_Designation_Id]
           ,[Lu_Department_Id]
           ,[Lu_ReportTo]
           ,[is_enabled]
           ,[EmployeeID]
           ,[updated_at]
           ,[operation])
      SELECT
            [Id]
           ,[FirstName]
           ,[LastName]
           ,[Email]
           ,[EmailConfirmed]
           ,[PasswordHash]
           ,[SecurityStamp]
           ,[PhoneNumber]
           ,[PhoneNumberConfirmed]
           ,[TwoFactorEnabled]
           ,[LockoutEndDateUtc]
           ,[LockoutEnabled]
           ,[AccessFailedCount]
           ,[UserName]
           ,[UserId]
           ,[Lu_Designation_Id]
           ,[Lu_Department_Id]
           ,[Lu_ReportTo]
           ,[is_enabled]
           ,[EmployeeID]
           
        ,GETDATE()
        ,'ALT'
    FROM
        inserted i
   
END
   

ALTER TABLE dbo.AspNetUsers ENABLE TRIGGER [audittrg_AspNetUsers]
