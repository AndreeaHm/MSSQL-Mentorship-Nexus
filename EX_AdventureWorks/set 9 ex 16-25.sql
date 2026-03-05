--x16. Putem folosi acest query ca si subquery ?
	SELECT * FROM HumanResources.Employee

SELECT BusinessEntityID, JobTitle
FROM ( SELECT * FROM HumanResources.Employee) AS e

--x17. Fiecare SalesOrderID, OrderDate și numărul de zile de la prima comandă.
SELECT SalesOrderID, OrderDate, DATEDIFF(DAY, MIN(OrderDate) OVER (), OrderDate)
FROM Sales.SalesOrderHeader

--x18. Numele intreg al persoanei cu cea mai mare comanda.
SELECT TOP 1 WITH TIES p.FirstName, p.LastName
FROM Sales.SalesOrderHeader sh
JOIN Sales.Customer c ON c.CustomerID = sh.CustomerID
JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
ORDER BY sh.TotalDue

--x19. Ultima comandă a fiecărui client, data la care s-a făcut și TotalDue.
;WITH LastID AS
(SELECT CustomerID, MAX(SalesOrderID) AS LID
FROM Sales.SalesOrderHeader
GROUP BY CustomerID)

SELECT sh.CustomerID ,SalesOrderID, OrderDate, TotalDue
FROM Sales.SalesOrderHeader sh
JOIN LastID l ON l.CustomerID = sh.CustomerID AND l.LID = sh.SalesOrderID

--x20. Returnați într-o singură coloană toate combinațiile meciurilor de ping-pong între toți salespersons folosind doar FirstName (ex: 'Marius - Andrei') 
--    și doar tur, fără retur (adică să nu aveți și 'Andrei - Marius').
SELECT p.FirstName, p2.FirstName
FROM Sales.SalesPerson sp
JOIN Person.Person p ON p.BusinessEntityID = sp.BusinessEntityID
JOIN Sales.SalesPerson sp2 ON sp2.BusinessEntityID > sp.BusinessEntityID
JOIN Person.Person p2 ON p2.BusinessEntityID = sp2.BusinessEntityID

--x21. Folosind două CTE returnați suma TotalDue pentru yearly sales și cea mai mare diferență între vânzările dintre doi ani consecutivi.
;WITH VanzariAni AS
(SELECT YEAR(OrderDate) AS An, SUM(TotalDue) AS TotalVanzari
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)),
DifIntreAni AS
(SELECT y1.An AS AnCurent, y1.TotalVanzari AS TotalAnCurent,
		y2.An AS AnPrecedent, y2.TotalVanzari AS TotalAnPrec, 
		y1.TotalVanzari - y2.TotalVanzari AS Diferenta 
FROM VanzariAni y1
JOIN VanzariAni y2 ON y2.An = y1.An - 1)

SELECT MAX(ABS(Diferenta))
FROM DifIntreAni

--x22. ID-urile de comenzi care se află între MIN(TotalDue) și AVG(TotalDue)
SELECT SalesOrderID
FROM Sales.SalesOrderHeader
WHERE TotalDue > (SELECT MIN(TotalDue) FROM Sales.SalesOrderHeader)
AND TotalDue < (SELECT AVG(TotalDue) FROM Sales.SalesOrderHeader)

--x23. O procedură care primește ca parametru un an (2014) și retunează ca parametru de output SalesOrderID pentru cea mai mare comandă din anul respectiv.
CREATE PROCEDURE ComMaxAn @An INT, @IDreturnat INT OUTPUT AS
SELECT TOP 1 @IDreturnat = SalesOrderID
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = @An
ORDER BY TotalDue DESC

DECLARE @rez INT
EXEC [dbo].[ComMaxAn] @An = 2014, @IDreturnat = @rez OUTPUT
SELECT @rez

--x24. Creați o procedură stocată care să primească ca parametri ID, FirstName și LastName și să insereze în tabel rândul dacă ID-ul nu exită, sau să actualizeze FirstName și LastName dacă ID-ul există (folosiți MERGE).
	create table dbo.Person(ID int, FirstName varchar(100), LastName varchar(100))
	insert into dbo.Person values
	(1, 'Ion', 'Ionescu'),
	(2, 'Pop', 'Popescu'),
	(3, 'George', 'Georgescu')

CREATE PROCEDURE InserareTabel @ID INT, @FirstName VARCHAR(100), @LastName VARCHAR(100) AS
MERGE [dbo].[Person] AS TARGET
USING (SELECT @ID AS ID, @FirstName AS FN, @LastName AS LN) AS SOURCE
ON TARGET.ID = SOURCE.ID
WHEN MATCHED THEN 
UPDATE SET TARGET.FirstName = SOURCE.FN, TARGET.LastName = SOURCE.LN
WHEN NOT MATCHED THEN
INSERT (ID, FirstName, LastName)
VALUES (SOURCE.ID, SOURCE.FN, SOURCE.LN);

SELECT * FROM Person
EXEC [dbo].[InserareTabel] @ID = 4, @FirstName = 'Stela', @LastName = 'Popescu'

--x25. Creați un tabel de audit în care introduceți acțiunea executată la punctul anterior (INSERT sau UPDATE), valorile inițiale și valorile noi.
CREATE TABLE audit_person 
(
	id_audit INT IDENTITY (1,1) PRIMARY KEY,
	actiune VARCHAR(10),
	old_id INT,
	old_fn VARCHAR(100),
	old_ln VARCHAR(100),
	new_id INT,
	new_fn VARCHAR(100),
	new_ln VARCHAR(100)
)

CREATE PROCEDURE InserareTabelAudit @ID INT, @FirstName VARCHAR(100), @LastName VARCHAR(100) AS
MERGE [dbo].[Person] AS TARGET
USING (SELECT @ID AS ID, @FirstName AS FN, @LastName AS LN) AS SOURCE
ON TARGET.ID = SOURCE.ID
WHEN MATCHED THEN 
UPDATE SET TARGET.FirstName = SOURCE.FN, TARGET.LastName = SOURCE.LN
WHEN NOT MATCHED THEN
INSERT (ID, FirstName, LastName)
VALUES (SOURCE.ID, SOURCE.FN, SOURCE.LN)
OUTPUT
$action AS actiune,
deleted.ID,
deleted.FirstName,
deleted.LastName,
inserted.ID,
inserted.FirstName,
inserted.LastName
INTO [dbo].[audit_person];

SELECT * FROM audit_person
EXEC [dbo].[InserareTabelAudit] @ID = 5, @FirstName = 'Ana', @LastName = 'Mere'