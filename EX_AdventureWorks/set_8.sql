--x1. Returnați id-ul comenzilor, numele produselor din fiecare comandă și cantitatea vândută.
SELECT sd.SalesOrderID, p.Name, sd.OrderQty
FROM Sales.SalesOrderDetail sd
JOIN Production.Product p ON p.ProductID = sd.ProductID
ORDER BY sd.SalesOrderID

--x2. Returnați numele produselor, numele subcategoriilor și numele categoriilor.
SELECT p.Name AS ProductName, ps.Name as SubcategoryName, pc.Name AS CategoryName
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON pc.ProductCategoryID = ps.ProductCategoryID

--x3. Câți angajați sunt în departamentul Engineering?
SELECT COUNT(*)
FROM HumanResources.EmployeeDepartmentHistory e
JOIN HumanResources.Department d ON d.DepartmentID = e.DepartmentID
WHERE d.Name = 'Engineering'
AND e.EndDate IS NULL

--x4. Suma tuturor comenzilor care contin produse rosii.
WITH CPR AS
(SELECT sh.SalesOrderID, sh.TotalDue
FROM Sales.SalesOrderHeader sh
JOIN Sales.SalesOrderDetail sd ON sh.SalesOrderID = sd.SalesOrderID
JOIN Production.Product p ON sd.ProductID = p.ProductID
WHERE p.Color = 'Red'
GROUP BY sh.SalesOrderID, sh.TotalDue)

SELECT SUM(TotalDue) AS SumaTotalaComenzi
FROM CPR

--x5. Clientul care a făcut cea mai mare comandă.
SELECT TOP(1) WITH TIES CustomerID, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC

--x6. Cine este angajatul cu cel mai mare salariu?
SELECT TOP 1 WITH TIES e.FirstName + ' ' + e.LastName AS Nume, ep.BusinessEntityID, ep.Rate, ep.PayFrequency
FROM HumanResources.EmployeePayHistory ep
LEFT JOIN HumanResources.EmployeePayHistory ep2 ON ep2.BusinessEntityID = ep.BusinessEntityID
												AND ep2.RateChangeDate > ep.RateChangeDate
JOIN Person.Person e ON e.BusinessEntityID = ep.BusinessEntityID
WHERE ep2.BusinessEntityID IS NULL
ORDER BY ep.Rate*ep.PayFrequency DESC

--x7. Fiecare salesperson (Nume, prenume) in ce tari face el vanzari?
WITH TariAngajati AS
(SELECT DISTINCT sp.BusinessEntityID, p.FirstName + ' ' + p.LastName AS Nume, c.Name AS Tara
FROM Sales.SalesPerson sp
JOIN Person.Person p ON p.BusinessEntityID = sp.BusinessEntityID
JOIN Sales.SalesOrderHeader sh ON sh.SalesPersonID = sp.BusinessEntityID
JOIN Person.Address a ON a.AddressID = sh.BillToAddressID
JOIN Person.StateProvince st ON st.StateProvinceID = a.StateProvinceID
JOIN Person.CountryRegion c ON c.CountryRegionCode = st.CountryRegionCode
)
SELECT BusinessEntityID, Nume, STRING_AGG(Tara, '  ')
FROM TariAngajati
GROUP BY BusinessEntityID, Nume
ORDER BY BusinessEntityID

--x8. Creați două tabele t1 și t2, fiecare cu o singură coloană. 
--   În t1 introduceți valorile: 1, 2, 3, 4, 5. 
--   În t2 introduceți valorile 3, 4, 5, 6, 7. 
--   Returnați toate cifrele care se află în t1 și nu se află în t2.
CREATE TABLE t1(c1 int)
CREATE TABLE t2(c1 int)
INSERT INTO t1 VALUES (1), (2), (3), (4), (5)
INSERT INTO t2 VALUES (3), (4), (5), (6), (7)

SELECT t1.c1
FROM t1 
LEFT JOIN t2 ON t1.c1 = t2.c1
WHERE t2.c1 IS NULL

--x9. Returnați toate cifrele din t1 și t2 care se regăsesc doar într-una dintre ele. 
--   Adică nu trebuie să apară în rezultat cifrele: 3, 4, 5.
SELECT COALESCE(t1.c1, t2.c1)
FROM t1 
FULL JOIN t2 ON t1.c1 = t2.c1
WHERE t2.c1 IS NULL OR t1.c1 IS NULL

--x10. Returneaza clientii care n au facut niciodata comenzi.
SELECT c.CustomerID
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader sh ON sh.CustomerID = c.CustomerID
WHERE sh.SalesOrderID IS NULL

--x11. Numele de produse și numele subcategoriilor lor. Dacă nu au subcategorie să apară 'Not Available'.
SELECT p.Name, ISNULL(ps.Name, 'Not Available')
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID

--x12. Returnați tabelul Person.Person și adăugați o coloană IsCustomer care să conțină valoarea 1 dacă persoana este client și valoarea 0 dacă nu este client.
SELECT p.*, CASE
				WHEN c.PersonID IS NOT NULL THEN 1
				ELSE 0
			END AS IsCustomer
FROM Person.Person p
LEFT JOIN Sales.Customer c ON c.PersonID = p.BusinessEntityID

--x13. Unul dintre clienții voștri s-a angajat ca SalesPerson la voi. 
--    Alegeți un client la întâmplare și creați-i o înregistrare în tabelul Sales.SalesPerson. 
--    Apoi faceți un query cu toate persoanele care sunt ori customer, ori salesperson, dar nu sunt amândouă în același timp. 
--    Adică nu trebuie să apară clientul pe care l-ați angajat.
INSERT INTO HumanResources.Employee
(BusinessEntityID, NationalIDNumber, LoginID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate)
VALUES
(3878, '999999999', 'adventure-works\custangj', 'Sales Representative', '1995-01-01', 'S', 'M', GETDATE())

INSERT INTO Sales.SalesPerson
(BusinessEntityID)
VALUES
(3878)

SELECT c.PersonID, c.StoreID, sp.BusinessEntityID
FROM Sales.Customer c
FULL JOIN Sales.SalesPerson sp ON sp.BusinessEntityID = c.PersonID
WHERE (c.PersonID IS NULL AND sp.BusinessEntityID IS NOT NULL)
OR (c.PersonID IS NOT NULL AND sp.BusinessEntityID IS NULL)


--Pentru experți:
--x14. Clientii care nu au facut comenzi in 2012(sau alt an).
;WITH ClientiFaraComenzi AS 
(SELECT c.CustomerID
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader sh ON sh.CustomerID = c.CustomerID
WHERE sh.SalesOrderID IS NULL)

SELECT c.CustomerID
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader sh ON sh.CustomerID = c.CustomerID
									AND YEAR(sh.OrderDate) = 2012
WHERE sh.SalesOrderID IS NULL
AND c.CustomerID NOT IN (SELECT CustomerID FROM ClientiFaraComenzi)

--x15. Toți clienții care au făcut comenzi doar în 2012(sau alt an).
SELECT CustomerID
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING MIN(YEAR(OrderDate)) = 2012
AND MAX(YEAR(OrderDate)) = 2012

--x16. Ce tabele din schema HumanResources sunt referențiate în ce proceduri?
SELECT p.name AS Procedura, s.name + '.' + o.name AS TabelReferentiat
FROM sys.procedures p
JOIN sys.sql_expression_dependencies d ON p.object_id = d.referencing_id
JOIN sys.objects o ON o.object_id = d.referenced_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.name = 'HumanResources'