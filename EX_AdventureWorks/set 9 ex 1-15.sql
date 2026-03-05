--x1. FirstName, LastName, AccountNumber, OrderCount, LastOrderDate, LastOrderID.
SELECT p.FirstName, p.LastName, c.AccountNumber, COUNT(sh.SalesOrderID), MAX(sh.OrderDate), MAX(sh.SalesOrderID)
FROM Person.Person p
JOIN Sales.Customer c ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader sh ON sh.CustomerID = c.CustomerID
GROUP BY p.BusinessEntityID, p.FirstName, p.LastName, c.AccountNumber

--x2. Care este valoarea medie e unei comenzi pentru fiecare client în anul 2014?
SELECT CustomerID, AVG(TotalDue)
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2014
GROUP BY CustomerID

--x3. Care sunt clienții care au făcut mai mult de 20 comenzi?
SELECT CustomerID
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(*) > 20

--x4. Returnați suma totală vândută în fiecare an și, ca un ultim rând, totatul pe toți anii (încercați cu UNION și GROUPING SETS)
SELECT SUM(TotalDue), YEAR(OrderDate)
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
UNION
SELECT SUM(TotalDue), NULL
FROM Sales.SalesOrderHeader

SELECT SUM(TotalDue), YEAR(OrderDate)
FROM Sales.SalesOrderHeader
GROUP BY GROUPING SETS( YEAR(OrderDate), ())

--x5. Toți SalesPersonID care să fi vândut mai puțin de 100 de produse diferite.
SELECT SalesPersonID
FROM Sales.SalesOrderHeader sh
JOIN Sales.SalesOrderDetail sd ON sd.SalesOrderID = sh.SalesOrderID
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID
HAVING COUNT(DISTINCT sd.ProductID) < 100

--x6. Toți SalesPersonID care au mai mult de 2 ani între prima și ultima lor comandă.
SELECT SalesPersonID
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID
HAVING DATEDIFF(YEAR, MIN(OrderDate), MAX(OrderDate)) > 2

--x7. Numarul de clienti activi din fiecare an.
SELECT YEAR(OrderDate), COUNT(DISTINCT CustomerID)
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)

--x8. Care sunt clientii loiali? (au facut cel putin o comanda in fiecare an)
SELECT CustomerID
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(DISTINCT YEAR(OrderDate)) IN (SELECT COUNT(DISTINCT YEAR(OrderDate)) FROM Sales.SalesOrderHeader)

--x9. Cea mai valoroasă comandă, durata cea mai mare de livrare a unei comenzi, data ultimei comenzi, și toate pe un singur rând
SELECT MAX(TotalDue) AS ComandaValoroasa, MAX(DATEDIFF(DAY, OrderDate, ShipDate)) AS DurataMaxLivrare, MAX(OrderDate) AS UltimaComanda
FROM Sales.SalesOrderHeader

--x10. A treia cea mai bănoasă comandă (încercați cu și fără OFFSET) fac si subquery
SELECT SalesOrderID, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC
OFFSET 2 ROWS
FETCH NEXT 1 ROWS ONLY

;WITH ComandaRand AS
(SELECT SalesOrderID, TotalDue, ROW_NUMBER() OVER (ORDER BY TotalDue DESC) AS rn
FROM Sales.SalesOrderHeader)

SELECT SalesOrderID, TotalDue
FROM ComandaRand
WHERE rn = 3

SELECT TOP 1 SalesOrderID, TotalDue
FROM (SELECT TOP 3 SalesOrderID, TotalDue
      FROM Sales.SalesOrderHeader
      ORDER BY TotalDue DESC) AS Top3
ORDER BY TotalDue


--x11. Măriți bonusul lui Linda C Mitchell cu 10%.
UPDATE sp
SET Bonus = Bonus + Bonus*0.1
FROM Sales.SalesPerson sp
JOIN Person.Person p ON p.BusinessEntityID = sp.BusinessEntityID
WHERE p.FirstName = 'Linda' AND p.LastName = 'Mitchell'

--x12. Toate comenzile care au mai mult de 5 produse diferite.
SELECT SalesOrderID, COUNT(DISTINCT ProductID)
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(DISTINCT ProductID) > 5

--x13. Toate produsele ultimei comenzi
;WITH UltimaComanda AS 
(SELECT TOP 1 SalesOrderID
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID DESC)

SELECT p.ProductID, p.Name
FROM Sales.SalesOrderDetail sd
JOIN Production.Product p ON p.ProductID = sd.ProductID
JOIN UltimaComanda uc ON uc.SalesOrderID = sd.SalesOrderID

--x14. SalesPersons care au avut vanzari in 2012 - cu JOIN, self-contained subquery si correlated subquery 
--    (verificați care este mai performant folosind butonul display estimated execution plan) 
SELECT DISTINCT sp.BusinessEntityID
FROM Sales.SalesOrderHeader sh
JOIN Sales.SalesPerson sp ON sp.BusinessEntityID = sh.SalesPersonID
WHERE YEAR(sh.OrderDate) = 2012

SELECT BusinessEntityID
FROM Sales.SalesPerson
WHERE BusinessEntityID IN (SELECT SalesPersonID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2012)

SELECT BusinessEntityID
FROM Sales.SalesPerson sp
WHERE (SELECT COUNT(*) 
	   FROM Sales.SalesOrderHeader sh 
	   WHERE sh.SalesPersonID = sp.BusinessEntityID 
	   AND YEAR(OrderDate) = 2012) > 0

--x15. Cum se rescrie query-ul ăsta folosind subquery în loc de JOIN?
	SELECT SalesOrderID, soh.CustomerID 
	FROM Sales.SalesOrderHeader AS soh
	INNER JOIN Sales.SalesPerson AS sp
		ON soh.SalesPersonID = sp.BusinessEntityID
    WHERE sp.Bonus >= 5000

SELECT SalesOrderID, CustomerID
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IN (SELECT BusinessEntityID FROM Sales.SalesPerson WHERE Bonus >= 5000)