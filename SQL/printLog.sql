USE [master]
GO
/****** Object:  Database [PrintLog]    Script Date: 15.04.2017 20:39:40 ******/
CREATE DATABASE [PrintLog]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PrintLog', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\PrintLog.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'PrintLog_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\PrintLog_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [PrintLog] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PrintLog].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PrintLog] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PrintLog] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PrintLog] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PrintLog] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PrintLog] SET ARITHABORT OFF 
GO
ALTER DATABASE [PrintLog] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PrintLog] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PrintLog] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PrintLog] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PrintLog] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PrintLog] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PrintLog] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PrintLog] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PrintLog] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PrintLog] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PrintLog] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PrintLog] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PrintLog] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PrintLog] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PrintLog] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PrintLog] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PrintLog] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PrintLog] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [PrintLog] SET  MULTI_USER 
GO
ALTER DATABASE [PrintLog] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PrintLog] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PrintLog] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PrintLog] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [PrintLog] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [PrintLog] SET QUERY_STORE = OFF
GO
USE [PrintLog]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [PrintLog]
GO
/****** Object:  User [MoskvichevED]    Script Date: 15.04.2017 20:39:40 ******/
CREATE USER [MoskvichevED] FOR LOGIN [DV\RRS-MoskvichevED] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [login_pel]    Script Date: 15.04.2017 20:39:40 ******/
CREATE USER [login_pel] FOR LOGIN [login_pel] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Table [dbo].[Computers]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Computers](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nchar](15) NOT NULL,
	[cn] [nvarchar](15) NULL,
	[bias] [int] NOT NULL,
	[filial_id] [int] NULL,
	[department_id] [int] NULL,
	[last_connect] [datetime2](7) NOT NULL,
	[last_update_event] [datetime2](7) NOT NULL,
	[distinguishedName_id] [int] NULL,
	[createdate] [datetime2](7) NULL,
 CONSTRAINT [PK_Computers] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Filials]    Script Date: 15.04.2017 20:39:41 ******/
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
/****** Object:  Table [dbo].[Events]    Script Date: 15.04.2017 20:39:41 ******/
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
	[date_time_print] [datetime2](7) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[distinguishedName]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[distinguishedName](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_distinguishedName] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Departments]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Departments](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[ou] [nvarchar](255) NULL,
 CONSTRAINT [PK_Departments] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[extensionAttribute2]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[extensionAttribute2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
 CONSTRAINT [PK_extensionAttribute2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[login] [nvarchar](20) NOT NULL,
	[cn] [nvarchar](255) NULL,
	[distinguishedName] [int] NULL,
	[extensionAttribute1] [nvarchar](50) NULL,
	[extensionAttribute2_id] [int] NULL,
	[company_id] [int] NULL,
	[filial_id] [int] NULL,
	[department_id] [int] NULL,
	[createdate] [datetime2](7) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[View_1]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_1]
AS
SELECT        dbo.Events.pages_count AS [Количество страниц], dbo.Events.document_name AS [Имя документа], dbo.Events.size AS Размер, dbo.Events.printer_name AS [Имя принтера], 
                         dbo.Events.date_time_print AS [Дата/время печати], dbo.Computers.name AS [Имя компьютера], dbo.Computers.bias AS [Часовой пояс], dbo.Computers.last_connect AS [Последнее обращение компьютера], 
                         dbo.Users.cn AS ФИО, dbo.Users.login AS Логин, dbo.Users.extensionAttribute1, dbo.distinguishedName.name AS OU, dbo.extensionAttribute2.Name AS [Подразделение R12], 
                         dbo.Departments.name AS Отдел, dbo.Filials.cod AS [Код филиала]
FROM            dbo.distinguishedName INNER JOIN
                         dbo.Users ON dbo.distinguishedName.id = dbo.Users.distinguishedName INNER JOIN
                         dbo.extensionAttribute2 ON dbo.Users.extensionAttribute2_id = dbo.extensionAttribute2.id INNER JOIN
                         dbo.Departments ON dbo.Users.department_id = dbo.Departments.id INNER JOIN
                         dbo.Filials ON dbo.Users.filial_id = dbo.Filials.id RIGHT OUTER JOIN
                         dbo.Events ON dbo.Users.id = dbo.Events.user_id LEFT OUTER JOIN
                         dbo.Computers ON dbo.Events.computer_id = dbo.Computers.id

GO
/****** Object:  Table [dbo].[Company]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Company](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NULL,
 CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Computers] ADD  CONSTRAINT [DF_Computers1_bias]  DEFAULT ((560)) FOR [bias]
GO
ALTER TABLE [dbo].[Computers] ADD  CONSTRAINT [DF_Computers_last_connect]  DEFAULT ('1990-01-01 00:00:01') FOR [last_connect]
GO
ALTER TABLE [dbo].[Computers] ADD  CONSTRAINT [DF_Computers_last_update_event]  DEFAULT ('1990-01-01 00:00:01') FOR [last_update_event]
GO
ALTER TABLE [dbo].[Events] ADD  CONSTRAINT [DF_Events_pages_count]  DEFAULT ((1)) FOR [pages_count]
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD  CONSTRAINT [FK_Events_Computers] FOREIGN KEY([computer_id])
REFERENCES [dbo].[Computers] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Events] CHECK CONSTRAINT [FK_Events_Computers]
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD  CONSTRAINT [FK_Events_Users] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([id])
GO
ALTER TABLE [dbo].[Events] CHECK CONSTRAINT [FK_Events_Users]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Company] FOREIGN KEY([company_id])
REFERENCES [dbo].[Company] ([id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Company]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Departments] FOREIGN KEY([department_id])
REFERENCES [dbo].[Departments] ([id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Departments]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_distinguishedName] FOREIGN KEY([distinguishedName])
REFERENCES [dbo].[distinguishedName] ([id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_distinguishedName]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_extensionAttribute2] FOREIGN KEY([extensionAttribute2_id])
REFERENCES [dbo].[extensionAttribute2] ([id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_extensionAttribute2]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Filials] FOREIGN KEY([filial_id])
REFERENCES [dbo].[Filials] ([id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Filials]
GO
/****** Object:  StoredProcedure [dbo].[add_computer]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 29.03.2017
-- Description:	Добавление нового ПК
-- =============================================
CREATE PROCEDURE [dbo].[add_computer] 
	-- Add the parameters for the stored procedure here
	@name nchar(15), 
	@bias int = 560/*,
	@ou nvarchar(100),
	@distinguishedName nvarchar(255)*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*	IF NOT EXISTS(select 1 from PrintLog.dbo.distinguishedName where name = @distinguishedName)
	BEGIN
		INSERT INTO PrintLog.dbo.distinguishedName (name) values (@distinguishedName)
	END*/

    -- Insert statements for procedure here
	INSERT INTO PrintLog.dbo.Computers (name,bias,last_connect,last_update_event,createdate) values (
	upper(@name),
	@bias,
	'1990-01-01 00:00:01',
	'1990-01-01 00:00:01',/*
	(select top 1 id from PrintLog.dbo.Filials where ou = @ou),
	(select top 1 id from PrintLog.dbo.distinguishedName where name = @distinguishedName),*/
	GetDate()
	)
END

GO
/****** Object:  StoredProcedure [dbo].[add_event]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 2017.04.04
-- Description:	Добавляем событие печати
-- =============================================
CREATE PROCEDURE [dbo].[add_event] 
	-- Add the parameters for the stored procedure here
	@sID nvarchar(50),
	@computer_id int, 
	@user_id int,
	@pages_count int,
	@document_name nvarchar(255),
	@size int,
	@printer_name nvarchar(50),
	@datetimeprint nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF NOT EXISTS(select 1 from PrintLog.dbo.Events where id = @sID)
	BEGIN
		INSERT INTO PrintLog.dbo.Events (id,computer_id,user_id,pages_count,document_name,size,printer_name,date_time_print) values (
	--convert(nvarchar,@computer_id) + '-'+convert(nvarchar(19),convert(datetime2,@datetimeprint)),
			@sID,
			@computer_id, 
			@user_id,
			@pages_count,
			@document_name,
			@size,
			@printer_name,
			convert(datetime2,@datetimeprint)
		);
	END;

END

GO
/****** Object:  StoredProcedure [dbo].[check_computer_reg]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 2017-03-29
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[check_computer_reg] 
	-- Add the parameters for the stored procedure here
	@name varchar(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from [dbo].Computers with(nolock) where name = @name
END

GO
/****** Object:  StoredProcedure [dbo].[Get_Company_Id]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 10.04.2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Get_Company_Id] 
	-- Add the parameters for the stored procedure here
	@Company nvarchar(255) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 	IF NOT EXISTS(select 1 from PrintLog.dbo.Company where name = @Company)
	BEGIN
		INSERT INTO PrintLog.dbo.Company (name) values (@Company)
	END
	SELECT id from PrintLog.dbo.Company where name = @Company
END

GO
/****** Object:  StoredProcedure [dbo].[Get_Computer_Id]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 2017.03.04
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Get_Computer_Id] 
	-- Add the parameters for the stored procedure here
	@ComputerName nvarchar(15), 
	@bias int = 540
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF NOT EXISTS(select 1 from PrintLog.dbo.Computers where name = UPPER(@ComputerName))
	BEGIN
		INSERT INTO PrintLog.dbo.Computers (name,bias,last_connect,last_update_event,createdate) values (
			upper(@ComputerName),
			@bias,
			'1990-01-01 00:00:01',
			'1990-01-01 00:00:01',
			GETDATE()
		)
	END
	SELECT id from PrintLog.dbo.Computers where name = upper(@ComputerName)
END

GO
/****** Object:  StoredProcedure [dbo].[Get_Department_Id]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 10.04.2017
-- Description:	Возвращает по имени подразделения его ID
-- =============================================
CREATE PROCEDURE [dbo].[Get_Department_Id] 
	-- Add the parameters for the stored procedure here
	@Department nvarchar(255) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 	IF NOT EXISTS(select 1 from PrintLog.dbo.Departments where name = @Department)
	BEGIN
		INSERT INTO PrintLog.dbo.Departments (name) values (@Department)
	END
	SELECT id from PrintLog.dbo.Departments where name = @Department
END

GO
/****** Object:  StoredProcedure [dbo].[Get_distinguishedName_Id]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 30.03.2017
-- Description:	Проверяем есть ли в базе OU
-- =============================================
CREATE PROCEDURE [dbo].[Get_distinguishedName_Id] 
	-- Add the parameters for the stored procedure here
	@distinguishedName nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF NOT EXISTS(select 1 from PrintLog.dbo.distinguishedName where name = UPPER(@distinguishedName))
	BEGIN
		INSERT INTO PrintLog.dbo.distinguishedName (name) values (UPPER(@distinguishedName))
	END
	SELECT id from PrintLog.dbo.distinguishedName where name = upper(@distinguishedName)
END

GO
/****** Object:  StoredProcedure [dbo].[Get_extensionAttribute2_Id]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 10.04.2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Get_extensionAttribute2_Id] 
	-- Add the parameters for the stored procedure here
	@ex2 nvarchar(255) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 	IF NOT EXISTS(select 1 from PrintLog.dbo.extensionAttribute2 where name = @ex2)
	BEGIN
		INSERT INTO PrintLog.dbo.extensionAttribute2 (name) values (@ex2)
	END
	SELECT id from PrintLog.dbo.extensionAttribute2 where name = @ex2
END

GO
/****** Object:  StoredProcedure [dbo].[get_last_connect]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 31.03.2017
-- Description:	Возвращает датувремя последнего соединения с сервером
-- =============================================
CREATE PROCEDURE [dbo].[get_last_connect] 
	-- Add the parameters for the stored procedure here
	@name nvarchar (15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @result varchar (19)

    -- Insert statements for procedure here
	set @result=(select top 1 isnull(cast([last_connect] as datetime2(0)),GETDATE()) as last_connect 
  from dbo.Computers  with(nolock) where
   name = UPPER(@name) and id>=0 order by [last_connect] desc)
  select cast(isnull(cast(@result as datetime2(0)),'2014-01-01 00:00:01') as nvarchar(19))

END

GO
/****** Object:  StoredProcedure [dbo].[get_last_event_update]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 31.03.2017
-- Description:	Возвращает датувремя последнего обновления событий
-- =============================================
CREATE PROCEDURE [dbo].[get_last_event_update] 
	-- Add the parameters for the stored procedure here
	@name nvarchar (15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @result varchar (19)

    -- Insert statements for procedure here
	set @result=(select top 1 isnull(cast([last_update_event] as datetime2(0)),GETDATE()) as last_update_event 
  from dbo.Computers  with(nolock) where
   name = UPPER(@name) and id>=0 order by [last_update_event] desc)
  select cast(isnull(cast(@result as datetime2(0)),'2014-01-01 00:00:01') as nvarchar(19))

END

GO
/****** Object:  StoredProcedure [dbo].[Get_User_Id]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A,V.
-- Create date: 2017-04-04
-- Description:	Вовращает ID пользователя. Если пользователя нет в базе - добавляет
-- =============================================
CREATE PROCEDURE [dbo].[Get_User_Id] 
	-- Add the parameters for the stored procedure here
	@User nvarchar(20) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	IF NOT EXISTS(select 1 from PrintLog.dbo.Users where login = UPPER(@User))
	BEGIN
		INSERT INTO PrintLog.dbo.Users (login,createdate) values (upper(@User),GETDATE())
	END
	SELECT id from PrintLog.dbo.Users where login = upper(@User)
END

GO
/****** Object:  StoredProcedure [dbo].[update_pc_last_connect]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 29.03.2017
-- Description:	Обновляем дату последнего соединения с базой
-- =============================================
CREATE PROCEDURE [dbo].[update_pc_last_connect] 
	-- Add the parameters for the stored procedure here
	@name nchar(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE PrintLog.dbo.Computers Set last_connect = convert(datetime2,GETDATE()) Where name = UPPER(@name)
END

GO
/****** Object:  StoredProcedure [dbo].[update_pc_last_event]    Script Date: 15.04.2017 20:39:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Filatov A.V.
-- Create date: 29.03.2017
-- Description:	Обновление последнего обновления событий
-- =============================================
CREATE PROCEDURE [dbo].[update_pc_last_event] 
	-- Add the parameters for the stored procedure here
	@name nchar(15),
	@date nvarchar(19)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE PrintLog.dbo.Computers Set last_update_event = convert(datetime2,@date) Where name = @name
	--convert(datetime2,GETDATE(),104) Where name = @name
END

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Events"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 251
               Right = 323
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "Computers"
            Begin Extent = 
               Top = 13
               Left = 641
               Bottom = 143
               Right = 848
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "Users"
            Begin Extent = 
               Top = 161
               Left = 454
               Bottom = 291
               Right = 661
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "distinguishedName"
            Begin Extent = 
               Top = 173
               Left = 818
               Bottom = 269
               Right = 992
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "extensionAttribute2"
            Begin Extent = 
               Top = 234
               Left = 721
               Bottom = 330
               Right = 895
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Departments"
            Begin Extent = 
               Top = 205
               Left = 266
               Bottom = 318
               Right = 440
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Filials"
            Begin Extent = 
               Top = 25
               Left = 915
               Bottom = 155
               Right = 1089
            End
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'         DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 15
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 3600
         Width = 3165
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 8610
         Width = 4110
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2160
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_1'
GO
USE [master]
GO
ALTER DATABASE [PrintLog] SET  READ_WRITE 
GO
