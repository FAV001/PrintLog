USE [PrintLog]
GO
/****** Object:  Table [dbo].[Filials]    Script Date: 29.03.2017 10:22:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Filials](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[cod] [nchar](10) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[ou] [nvarchar](255) NULL,
 CONSTRAINT [PK_Filials] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
