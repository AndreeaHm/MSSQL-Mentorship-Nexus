
--1. Valoarea totala a comenzilor fiecarui AccountNumber.
SELECT AccountNumber ,SUM(TotalDue) AS TotalComenzi 
FROM Sales.SalesOrderHeader
GROUP BY AccountNumber

--2. Care este vânzătorul cu cele mai multe comenzi?
SELECT SalesPersonID, COUNT(*) AS NrComenzi
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID
HAVING COUNT(*) = (SELECT MAX(c)
				   FROM (SELECT COUNT(*) AS c
						 FROM Sales.SalesOrderHeader
						 WHERE SalesPersonID IS NOT NULL 
						 GROUP BY SalesPersonID) x)

--3. Câte comenzi și valoarea lor totala pentru fiecare teritoriu.
SELECT TerritoryID, COUNT(*) AS NrComenzi, SUM(TotalDue) AS TotalComenzi
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID

--4. Ultima comandă și valoarea maximă a unei comenzi pentru fiecare client.
SELECT CustomerID, MAX(OrderDate) AS UltimaComanda, MAX(TotalDue) AS ComandaMaxima
FROM Sales.SalesOrderHeader
GROUP BY CustomerID

--5. Anul în care s-a vândut cel mai mult.
SELECT YEAR(OrderDate)
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
HAVING SUM(TotalDue) = (SELECT MAX(c)
						FROM (SELECT SUM(TotalDue) as c
							  FROM Sales.SalesOrderHeader
							  GROUP BY YEAR(OrderDate)) x)

--6. Cât a durat de la prima la ultima comandă pentru fiecare client?

--7. În ce lună din anul 2013 au fost cele mai mari vânzări?
SELECT MONTH(OrderDate)
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY MONTH(OrderDate)
HAVING SUM(TotalDue) = ( SELECT MAX(t)
						 FROM ( SELECT SUM(TotalDue) AS t
								FROM Sales.SalesOrderHeader
								WHERE YEAR(OrderDate) = 2013
								GROUP BY MONTH(OrderDate)) x)

--8. Câți oameni sunt în fiecare departament?
SELECT DepartmentID ,COUNT(BusinessEntityID) AS NrAngajati
FROM HumanResources.EmployeeDepartmentHistory
GROUP BY DepartmentID

--9. Care este comanda cu cele mai multe produse diferite și câte produse sunt în ea?
SELECT TOP (1) SalesOrderID, COUNT(DISTINCT ProductID) AS NrProduse
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY NrProduse DESC

--11. Premiati 3 sales persons pentru munca facuta in ultimul an
SELECT TOP(3) SalesPersonID, COUNT(*) AS NrComenzi
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
AND YEAR(OrderDate) = YEAR((SELECT MAX(OrderDate)
							FROM Sales.SalesOrderHeader))
GROUP BY SalesPersonID
ORDER BY NrComenzi DESC

--12. Pentru fiecare sales person returnati perioada dintre prima si ultima lor comanda.
SELECT SalesPersonID, DATEDIFF(DAY, MIN(OrderDate), MAX(OrderDate))
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID


--13. Cat timp a trecut pentru fiecare sales person de cand s-au angajat si pana au efectuat prima comanda.
SELECT e.BusinessEntityID, DATEDIFF(DAY, e.HireDate, MIN(s.OrderDate)) AS ZileTrecute
FROM HumanResources.Employee AS e
JOIN Sales.SalesOrderHeader AS s ON s.SalesPersonID = e.BusinessEntityID
GROUP BY e.BusinessEntityID, e.HireDate  

--14. Produsele care s-au vândut cele mai puțin
SELECT ProductID, SUM(OrderQty) AS CantitateTotala
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY CantitateTotala DESC


--15. Avand tabela cu raspunsuri la sondaje, returnati rata de raspuns pentru fiecare sondaj si rata de raspuns pentru fiecare respondent.
	declare @sondaj table (id int, respondent int, numar_intrebari int, raspunsuri int)
	insert into @sondaj values (1,100,25,7),(2,220,25,25),(3,300,25,14),(4,220,17,15),(5,300,17,null),(6,154,23,0)
	select * from @sondaj


--16. Care este teritoriul pe care Mountain Bike s-a vandut cel mai bine?
SELECT TOP (1) sh.TerritoryID, SUM(sh.TotalDue) AS VanzariTotale
FROM Sales.SalesOrderHeader AS sh
JOIN Sales.SalesOrderDetail AS sd ON sd.SalesOrderID = sh.SalesOrderID
JOIN Production.Product AS p ON p.ProductID = sd.ProductID
JOIN Production.ProductSubcategory AS ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID
WHERE ps.Name = 'Mountain Bikes'
GROUP BY sh.TerritoryID
ORDER BY VanzariTotale DESC

