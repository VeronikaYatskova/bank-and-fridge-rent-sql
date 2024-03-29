USE [FridgeManagement]
GO
/****** Object:  StoredProcedure [dbo].[AddProduct]    Script Date: 30.10.2022 13:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[AddProduct]
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
