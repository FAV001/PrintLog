USE [PrintLog]
GO
/****** Object:  Table [dbo].[Events]    Script Date: 29.03.2017 10:22:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Events](
	[id] [nvarchar](50) NOT NULL,
	[computer_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[pages_count] [int] NOT NULL,
	[document_name] [nvarchar](255) NOT NULL,
	[size] [int] NOT NULL,
	[printer_name] [nvarchar](50) NOT NULL,
	[date_time_print] [datetime] NOT NULL
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Events_pages_count]  DEFAULT ((1)) FOR [pages_count]
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD  CONSTRAINT [FK_Events_Computers] FOREIGN KEY([computer_id])
REFERENCES [dbo].[Computers] ([id])
GO
ALTER TABLE [dbo].[Events] CHECK CONSTRAINT [FK_Events_Computers]
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD  CONSTRAINT [FK_Events_Users] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([id])
GO
ALTER TABLE [dbo].[Events] CHECK CONSTRAINT [FK_Events_Users]
GO
