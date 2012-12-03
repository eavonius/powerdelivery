SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Releases](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[IsCapacityTested] [bit] NULL,
	[TeamProject] [nvarchar](150) NOT NULL,
	[DropLocation] [nvarchar](500) NOT NULL,
	[Environment] [nvarchar](50) NOT NULL,
	[IsUserAccepted] [bit] NULL,
	[ChangeSet] [varchar](10) NOT NULL,
	[RequestedBy] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[AppName] [nvarchar](200) NULL,
	[AppVersion] [varchar](15) NULL,
 CONSTRAINT [PK_Releases] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Releases] ADD  CONSTRAINT [DF_Releases_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO