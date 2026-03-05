--x26. O funcție care să primească ca parametru un SalesOrderID și să returneze toate produsele din comanda respectivă, cantitatea și prețul de vânzare.
CREATE FUNCTION DetaliiComanda (@SalesOrderID INT)
RETURNS TABLE AS
RETURN 
(SELECT p.Name AS NumeProdus, sd.OrderQty AS Cantitate, sd.UnitPrice AS PretVanzare
FROM Sales.SalesOrderDetail sd
JOIN Production.Product p ON p.ProductID = sd.ProductID
WHERE SalesOrderID = @SalesOrderID)

SELECT * FROM DetaliiComanda(43659)

--x27. Folosind doar funcția de mai sus și tabelul SalesOrderHeader, returnați printr-un SELECT toate produsele comenzilor 43668, 43665 și 43675 (folosiți APPLY)
SELECT SalesOrderID, NumeProdus, Cantitate, PretVanzare
FROM Sales.SalesOrderHeader
CROSS APPLY DetaliiComanda(SalesOrderID)
WHERE SalesOrderID IN (43668, 43665 ,43675)

--x28. O funcție care să primească ca parametru un CustomerID și să returneze suma tuturor comenzilor acestuia.
CREATE FUNCTION SumaComenzi (@CustomerID INT)
RETURNS MONEY AS
BEGIN
	DECLARE @suma MONEY

	SELECT @suma = SUM(TotalDue)
	FROM Sales.SalesOrderHeader
	WHERE CustomerID = @CustomerID

	RETURN @suma
END 

--x29. Folosind funcția de la punctul anterior, faceți un SELECT care să returneze toți clienții și suma tuturor vânzărilor lor.
SELECT CustomerID, dbo.SumaComenzi(CustomerID)
FROM Sales.Customer

--x30. O funcție care să primească ca parametru un Produs și să returneze numele clientului care l-a cumpărat cel mai des.
CREATE FUNCTION ProdusFav (@ProductID INT)
RETURNS TABLE AS
RETURN
(SELECT TOP 1 WITH TIES sh.CustomerID, COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS Customer
	FROM Sales.SalesOrderDetail sd
	JOIN Sales.SalesOrderHeader sh ON sh.SalesOrderID = sd.SalesOrderID
	JOIN Sales.Customer c ON c.CustomerID = sh.CustomerID
	JOIN Sales.Store s ON s.BusinessEntityID = c.StoreID
	JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
	WHERE sd.ProductID = @ProductID
	GROUP BY sh.CustomerID, p.FirstName, p.LastName, s.Name
	ORDER BY COUNT(*) DESC)

SELECT * FROM dbo.ProdusFav(707)

--x31. O funcție care să primească ca parametru un an și să returneze diferența între vânzările din anul respectiv și anul anterior.
CREATE FUNCTION DifVanzari (@an INT)
RETURNS MONEY AS
BEGIN
    DECLARE @baniancurent MONEY;
    DECLARE @baniantrecut MONEY;

    SELECT @baniancurent = SUM(TotalDue)
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = @an

    SELECT @baniantrecut = SUM(TotalDue)
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = @an - 1

    RETURN @baniancurent - @baniantrecut
END

SELECT [dbo].[DifVanzari](2013)

--x32. Un view care să returneze SalesOrderID și țara în care s-a făcut fiecare comandă.
CREATE VIEW TaraComanda AS
SELECT sh.SalesOrderID, c.Name
FROM Sales.SalesOrderHeader sh
JOIN Person.Address a ON a.AddressID = sh.BillToAddressID
JOIN Person.StateProvince st ON st.StateProvinceID = a.StateProvinceID
JOIN Person.CountryRegion c ON c.CountryRegionCode = st.CountryRegionCode

SELECT * FROM [dbo].[TaraComanda]

--x33. O procedură care primește ca parametru un table name și returnează ca output scriptul de creare al tabelului. Scriptul trebuie să conțină doar coloanele și tipul de dată. Nu trebuie să creați script pentru constrângeri.
CREATE PROCEDURE CreareTabel @TableName VARCHAR(50), @Script NVARCHAR(MAX) OUTPUT AS
BEGIN
	SET @Script = @TableName

	SELECT @Script = @Script + CHAR(13) + CHAR(10) + c.name + ' ' + t.name
	FROM sys.objects o
	JOIN sys.columns c ON c.object_id = o.object_id
	JOIN sys.types t ON t.user_type_id = c.user_type_id
	WHERE o.name = @TableName
	AND o.type = 'U'
END

DECLARE @S NVARCHAR(MAX)
EXEC [dbo].[CreareTabel] 'Person', @S OUTPUT
PRINT(@S)

--x34. O funcție care să returneze primul caracter nerepetat dintr-un string. De exemplu, primul caracter nerepetat din stringul 'abcdab' este 'c'.
CREATE FUNCTION PrimulCaracterUnic (@string VARCHAR(100))
RETURNS CHAR(1) AS
BEGIN
	DECLARE @i INT = 1
	DECLARE @len INT = LEN(@string)
	DECLARE @char CHAR(1)
	DECLARE @copy VARCHAR(100) = @string

	WHILE @i <= @len
	BEGIN
		SET @char = SUBSTRING(@copy, @i, 1)

		IF LEN(@copy) - 1 = LEN(REPLACE(@copy, @char, ''))
			RETURN @char

		SET @i = @i + 1
	END

	RETURN NULL
END

SELECT  LEN('abcc'), LEN(REPLACE('abcc', 'c', ''))

--x35. O procedură care să determine dacă un string are toate caracterele distincte.
CREATE PROCEDURE StringUnic @string VARCHAR(100), @rez VARCHAR(6) OUTPUT AS
BEGIN
	DECLARE @copy VARCHAR(100) = @string
    DECLARE @char CHAR(1)

    WHILE LEN(@copy) > 0
    BEGIN
        SET @char = dbo.PrimulCaracterUnic(@copy)

        IF @char IS NULL
        BEGIN
            SET @rez = 'FALSE'
            RETURN
        END

        SET @copy = REPLACE(@copy, @char, '')
    END

    SET @rez = 'TRUE'
END