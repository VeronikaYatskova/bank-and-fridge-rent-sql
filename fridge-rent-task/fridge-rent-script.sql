USE [master]
GO
/****** Object:  Database [FridgeManagement]    Script Date: 13.11.2022 23:54:22 ******/
CREATE DATABASE [FridgeManagement]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'FridgeManagement', FILENAME = N'C:\Users\veron\FridgeManagement.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'FridgeManagement_log', FILENAME = N'C:\Users\veron\FridgeManagement_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [FridgeManagement] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [FridgeManagement].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [FridgeManagement] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [FridgeManagement] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [FridgeManagement] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [FridgeManagement] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [FridgeManagement] SET ARITHABORT OFF 
GO
ALTER DATABASE [FridgeManagement] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [FridgeManagement] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [FridgeManagement] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [FridgeManagement] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [FridgeManagement] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [FridgeManagement] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [FridgeManagement] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [FridgeManagement] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [FridgeManagement] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [FridgeManagement] SET  ENABLE_BROKER 
GO
ALTER DATABASE [FridgeManagement] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [FridgeManagement] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [FridgeManagement] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [FridgeManagement] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [FridgeManagement] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [FridgeManagement] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [FridgeManagement] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [FridgeManagement] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [FridgeManagement] SET  MULTI_USER 
GO
ALTER DATABASE [FridgeManagement] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [FridgeManagement] SET DB_CHAINING OFF 
GO
ALTER DATABASE [FridgeManagement] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [FridgeManagement] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [FridgeManagement] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [FridgeManagement] SET QUERY_STORE = OFF
GO
USE [FridgeManagement]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
USE [FridgeManagement]
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 13.11.2022 23:54:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FridgeProducts]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FridgeProducts](
	[Id] [uniqueidentifier] NOT NULL,
	[Count] [int] NOT NULL,
	[FridgeId] [uniqueidentifier] NOT NULL,
	[ProductId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_FridgeProducts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Fridges]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fridges](
	[FridgeId] [uniqueidentifier] NOT NULL,
	[IsRented] [bit] NOT NULL,
	[Capacity] [int] NOT NULL,
	[ModelId] [uniqueidentifier] NOT NULL,
	[OwnerId] [uniqueidentifier] NOT NULL,
	[ProducerId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Fridges] PRIMARY KEY CLUSTERED 
(
	[FridgeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Models]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Models](
	[Id] [uniqueidentifier] NOT NULL,
	[ModelName] [nvarchar](60) NOT NULL,
 CONSTRAINT [PK_Models] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Owners]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Owners](
	[OwnerId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](60) NOT NULL,
	[Email] [nvarchar](max) NOT NULL,
	[PasswordHash] [varbinary](max) NULL,
	[PasswordSalt] [varbinary](max) NULL,
	[Phone] [nvarchar](60) NOT NULL,
	[Token] [nvarchar](max) NOT NULL,
	[Created] [datetime2](7) NOT NULL,
	[Expires] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Owners] PRIMARY KEY CLUSTERED 
(
	[OwnerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Producer]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Producer](
	[ProducerId] [uniqueidentifier] NOT NULL,
	[ProducerName] [nvarchar](60) NOT NULL,
	[ProducerCountry] [nvarchar](60) NOT NULL,
 CONSTRAINT [PK_Producer] PRIMARY KEY CLUSTERED 
(
	[ProducerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductPictures]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductPictures](
	[Id] [uniqueidentifier] NOT NULL,
	[ProductId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[ImageName] [nvarchar](max) NOT NULL,
	[ImagePath] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_ProductPictures] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductId] [uniqueidentifier] NOT NULL,
	[ProductName] [nvarchar](60) NOT NULL,
	[DefaultQuantity] [int] NOT NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RentDocuments]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RentDocuments](
	[Id] [uniqueidentifier] NOT NULL,
	[FridgeId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[MonthCost] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_RentDocuments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserFridges]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserFridges](
	[Id] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[FridgeId] [uniqueidentifier] NOT NULL,
	[RentDocumentId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_UserFridges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [uniqueidentifier] NOT NULL,
	[Email] [nvarchar](max) NOT NULL,
	[PasswordHash] [varbinary](max) NOT NULL,
	[PasswordSalt] [varbinary](max) NOT NULL,
	[Role] [nvarchar](max) NOT NULL,
	[Token] [nvarchar](max) NOT NULL,
	[Created] [datetime2](7) NOT NULL,
	[Expires] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_UserFridges_RentDocumentId]    Script Date: 13.11.2022 23:54:23 ******/
CREATE NONCLUSTERED INDEX [IX_UserFridges_RentDocumentId] ON [dbo].[UserFridges]
(
	[RentDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserFridges]  WITH CHECK ADD  CONSTRAINT [FK_UserFridges_RentDocuments_RentDocumentId] FOREIGN KEY([RentDocumentId])
REFERENCES [dbo].[RentDocuments] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserFridges] CHECK CONSTRAINT [FK_UserFridges_RentDocuments_RentDocumentId]
GO
/****** Object:  StoredProcedure [dbo].[AddProduct]    Script Date: 13.11.2022 23:54:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddProduct]
	@userId UNIQUEIDENTIFIER,
	@productId UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @fridgeToAddProductTo TABLE (fridgeId UNIQUEIDENTIFIER NOT NULL);
	
	INSERT INTO @fridgeToAddProductTo
	SELECT uf.FridgeId FROM UserFridges AS uf
	WHERE uf.UserId = @userId AND (
	SELECT COUNT(*) FROM FridgeProducts 
	WHERE FridgeId = uf.FridgeId AND ProductId = @productId) = 0

	INSERT INTO FridgeProducts (Id, FridgeId, ProductId, Count)
	SELECT NEWID(), fridgeId, @productId, Products.DefaultQuantity FROM @fridgeToAddProductTo as Fridge
	JOIN Products on Products.ProductId = @productId
END
GO
USE [master]
GO
ALTER DATABASE [FridgeManagement] SET  READ_WRITE 
GO
