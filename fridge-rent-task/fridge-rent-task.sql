-- 1.

-- Сделать выборку продуктов по холодильникам, модель кот начинается на А

SELECT FridgeId, ModelName FROM Fridges
JOIN Models on Fridges.ModelId = Models.Id
WHERE Models.ModelName LIKE 'A%'

-- ������� ������� �������������, � ������� ���� �������� � ����������, ������� ��� ���������� ��-���������

SELECT FridgeId as 'Fridge Id', ProductName as 'Product Name', DefaultQuantity as 'Default Quantity', FridgeProducts.Count as 'Count In Fridge' from FridgeProducts
JOIN Products on FridgeProducts.ProductId = Products.ProductId
GROUP BY FridgeId, ProductName, DefaultQuantity, FridgeProducts.Count
HAVING FridgeProducts.Count < Products.DefaultQuantity


-- ��� �� �������������� ����� ����������� � ���������� ����������������

SELECT Fridges.FridgeId, Producer.ProducerName, Fridges.Capacity FROM Fridges
JOIN Producer on Producer.ProducerId = Fridges.ProducerId
GROUP BY Fridges.FridgeId, Producer.ProducerName, Fridges.Capacity
HAVING Fridges.Capacity = (SELECT MAX(Fridges.Capacity) FROM Fridges)

-- ������� ��� �������� � ��� ��������� �� ������������, � ������� ������ ����� ������������ ���������. ������ ������������, �� ����������

SELECT FridgeProducts.FridgeId, Products.ProductName, RentDocuments.UserId FROM FridgeProducts
	JOIN Products ON Products.ProductId = FridgeProducts.ProductId
	JOIN RentDocuments ON RentDocuments.FridgeId = FridgeProducts.FridgeId
WHERE FridgeProducts.FridgeId = 
	(SELECT FridgeId FROM FridgeProducts
	JOIN Products on Products.ProductId = FridgeProducts.ProductId
	GROUP BY FridgeId
	HAVING COUNT(FridgeProducts.ProductId) = 
		(SELECT MAX(ProductCount) 
		 FROM (SELECT FridgeId, COUNT(ProductId) AS ProductCount FROM FridgeProducts  
			   GROUP BY FridgeId) AS ProductsCount))


-- 2.

-- ������� ��� �������� � ������������ � guid ������ 6C6D2650-6CF8-4E45-B9DA-7727082DFCCE

SELECT Products.ProductName FROM FridgeProducts
	JOIN Products ON Products.ProductId = FridgeProducts.ProductId
WHERE FridgeProducts.FridgeId = '6C6D2650-6CF8-4E45-B9DA-7727082DFCCE'

-- ������� ��� �������� ��� ���� �������������

SELECT FridgeProducts.FridgeId, Products.ProductName FROM FridgeProducts
	JOIN Products ON Products.ProductId = FridgeProducts.ProductId
ORDER BY FridgeProducts.FridgeId, Products.ProductName

-- ������� ������ ������������� � ����� ���� ��������� ��� ������� �� ���

SELECT DISTINCT FridgeId, 
	(SELECT SUM(fr.Count) FROM FridgeProducts AS fr
	WHERE fr.FridgeId = FridgeProducts.FridgeId) AS 'Total Count of Products' 
FROM FridgeProducts

-- ������� ��� ������������, �������� ������ � ���������� ��������� � ���� �������������

SELECT DISTINCT FridgeProducts.FridgeId, Models.ModelName, 
	(SELECT SUM(fr.Count) FROM FridgeProducts AS fr
	WHERE fr.FridgeId = FridgeProducts.FridgeId) AS 'Total Count of Products' 
FROM FridgeProducts
	JOIN Fridges ON Fridges.FridgeId = FridgeProducts.FridgeId
	JOIN Models ON Models.Id = Fridges.ModelId

-- ������� ������� �������������, � ������� ���� �������� � ����������, ������� ��� ���������� ��-���������

SELECT FridgeId as 'Fridge Id', ProductName as 'Product Name', DefaultQuantity as 'Default Quantity', FridgeProducts.Count as 'Count In Fridge' from FridgeProducts
JOIN Products on FridgeProducts.ProductId = Products.ProductId
GROUP BY FridgeId, ProductName, DefaultQuantity, FridgeProducts.Count
HAVING FridgeProducts.Count > Products.DefaultQuantity

-- ������� ������ ������������� � ��� ������� ������������ ���-�� ������������, ���������� ������� ������,
-- ��� ���-�� ��-���������

SELECT FridgeProducts.FridgeId, Products.ProductName, RentDocuments.UserId FROM FridgeProducts
	JOIN Products ON Products.ProductId = FridgeProducts.ProductId
	JOIN RentDocuments ON RentDocuments.FridgeId = FridgeProducts.FridgeId
WHERE FridgeProducts.Count > Products.DefaultQuantity AND FridgeProducts.FridgeId = 
	(SELECT FridgeId FROM FridgeProducts
	JOIN Products on Products.ProductId = FridgeProducts.ProductId
	GROUP BY FridgeId
	HAVING COUNT(FridgeProducts.ProductId) = 
		(SELECT MAX(ProductCount) 
		 FROM (SELECT FridgeId, COUNT(FridgeProducts.ProductId) AS ProductCount FROM FridgeProducts  
			   GROUP BY FridgeId) AS ProductsCount))
