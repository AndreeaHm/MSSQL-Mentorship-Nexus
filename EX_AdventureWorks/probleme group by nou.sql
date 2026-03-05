--x1. Valoarea totala a comenzilor fiecarui AccountNumber
SELECT AccountNumber ,SUM(TotalDue) AS TotalComenzi 
FROM Sales.SalesOrderHeader
GROUP BY AccountNumber

--x2. Care este vânzătorul cu cele mai multe comenzi?
SELECT SalesPersonID, COUNT(*) AS NrComenzi
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID
HAVING COUNT(*) = (SELECT MAX(c)
				   FROM (SELECT COUNT(*) AS c
						 FROM Sales.SalesOrderHeader
						 WHERE SalesPersonID IS NOT NULL 
						 GROUP BY SalesPersonID) x)

--x3. Câte comenzi și valoarea lor totala pentru fiecare teritoriu.
SELECT TerritoryID, COUNT(*) AS NrComenzi, SUM(TotalDue) AS TotalComenzi
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
ORDER BY TerritoryID

--x4. Ultima comandă și valoarea maximă a unei comenzi pentru fiecare client.
SELECT CustomerID, MAX(OrderDate) AS UltimaComanda, MAX(TotalDue) AS ComandaMaxima
FROM Sales.SalesOrderHeader
GROUP BY CustomerID

--x5. Anul în care s-a vândut cel mai mult.
SELECT YEAR(OrderDate)
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
HAVING SUM(TotalDue) = (SELECT MAX(c)
						FROM (SELECT SUM(TotalDue) as c
							  FROM Sales.SalesOrderHeader
							  GROUP BY YEAR(OrderDate)) x)

--x6. Cât a durat de la prima la ultima comandă pentru fiecare client?
SELECT CustomerID, DATEDIFF(DAY, MIN(OrderDate), MAX(OrderDate))
FROM Sales.SalesOrderHeader
GROUP BY CustomerID

--x7. În ce lună din anul 2013 au fost cele mai mari vânzări?
SELECT MONTH(OrderDate)
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY MONTH(OrderDate)
HAVING SUM(TotalDue) = ( SELECT MAX(t)
						 FROM ( SELECT SUM(TotalDue) AS t
								FROM Sales.SalesOrderHeader
								WHERE YEAR(OrderDate) = 2013
								GROUP BY MONTH(OrderDate)) x)

--x8. Câți oameni sunt în fiecare departament?
SELECT DepartmentID ,COUNT(BusinessEntityID) AS NrAngajati
FROM HumanResources.EmployeeDepartmentHistory
WHERE EndDate IS NULL
GROUP BY DepartmentID

--x9. Care este comanda cu cele mai multe produse diferite și câte produse sunt în ea?
SELECT TOP (1) WITH TIES SalesOrderID, COUNT(DISTINCT ProductID) AS NrProduse, SUM(OrderQty) AS TotalNrProd
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY NrProduse DESC

--x10. Premiati 3 sales persons pentru munca facuta in ultimul an. Presupunem data actuala ca fiind: 
declare @data datetime2 = '20140630'
SELECT TOP (3) WITH TIES SalesPersonID AS Premiati, SUM(TotalDue) AS TotalVanzari
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
AND OrderDate >= DATEADD(YEAR, -1, @data)
AND OrderDate <= @data
GROUP BY SalesPersonID
ORDER BY TotalVanzari DESC

--x11. Pentru fiecare sales person returnati perioada dintre prima si ultima lor comanda.
SELECT SalesPersonID, DATEDIFF(DAY, MIN(OrderDate), MAX(OrderDate))
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID

--x12. Cat timp a trecut pentru fiecare sales person de cand s-au angajat si pana au efectuat prima comanda.
SELECT e.BusinessEntityID, DATEDIFF(DAY, e.HireDate, MIN(s.OrderDate)) AS ZileTrecute
FROM HumanResources.Employee AS e
JOIN Sales.SalesOrderHeader AS s ON s.SalesPersonID = e.BusinessEntityID
GROUP BY e.BusinessEntityID, e.HireDate

--x13. Produsele care s-au vândut cele mai puțin
SELECT ProductID, SUM(OrderQty) AS CantitateTotala
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY CantitateTotala

--x14. Avand tabela cu raspunsuri la sondaje, returnati rata de raspuns pentru fiecare sondaj si rata de raspuns pentru fiecare respondent.
	declare @sondaj table (id int, respondent int, numar_intrebari int, raspunsuri int)
	insert into @sondaj values (1,100,25,7),(2,220,25,25),(3,300,25,14),(4,220,17,15),(5,300,17,null),(6,154,23,0)
	select * from @sondaj

	SELECT id, ROUND(CAST(SUM(raspunsuri) as float)/SUM(numar_intrebari), 2) as Rata
	FROM @sondaj
	GROUP BY id 

	SELECT respondent, ROUND(CAST(SUM(raspunsuri) as float)/SUM(numar_intrebari), 2) as Rata
	FROM @sondaj
	GROUP BY respondent

--x15. Care este teritoriul pe care subcategoria de produse 'Mountain Bikes' s-a vandut cel mai bine?
SELECT TOP (1) WITH TIES sh.TerritoryID, SUM(sd.LineTotal) AS VanzariTotale
FROM Sales.SalesOrderHeader sh
JOIN Sales.SalesOrderDetail sd ON sd.SalesOrderID = sh.SalesOrderID
JOIN Production.Product p ON p.ProductID = sd.ProductID
JOIN Production.ProductSubcategory ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID
WHERE ps.Name = 'Mountain Bikes'
GROUP BY sh.TerritoryID
ORDER BY VanzariTotale DESC