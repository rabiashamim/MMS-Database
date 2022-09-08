/****** Object:  Table [dbo].[changelog]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[changelog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[type] [tinyint] NULL,
	[version] [varchar](50) NULL,
	[description] [varchar](200) NOT NULL,
	[name] [varchar](300) NOT NULL,
	[checksum] [varchar](32) NULL,
	[installed_by] [varchar](100) NOT NULL,
	[installed_on] [datetime] NOT NULL,
	[success] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[changelog] ADD  DEFAULT (getdate()) FOR [installed_on]
