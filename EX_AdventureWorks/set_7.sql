--X1. La ce adrese s-au livrat comenzile 57122, 57066 și 45273?
SELECT s.SalesOrderID ,p.AddressLine1 + ISNULL(p.AddressLine2, '') AS Adresa
FROM Sales.SalesOrderHeader s
JOIN Person.Address p ON p.AddressID = s.ShipToAddressID
WHERE s.SalesOrderID IN (57122, 57066, 45273)

--X2. Câte comenzi au fost făcute în Montreal?
SELECT COUNT(s.SalesOrderID)
FROM Person.Address a
JOIN Sales.SalesOrderHeader s ON s.BillToAddressID = a.AddressID
WHERE a.City = 'Montreal'

--X3. Câte comenzi au făcut clienții 11185 și 11176 în 2014?
SELECT CustomerID, COUNT(*)
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (11185, 11176)
AND YEAR(OrderDate) = 2014
GROUP BY CustomerID

--X4. Ce produse a vândut fiecare SalesPerson (SalesPersonFullName, ProductName)?
SELECT DISTINCT sp.BusinessEntityID ,p.LastName + p.FirstName AS Name, pr.Name
FROM Sales.SalesPerson sp
JOIN Person.Person p ON p.BusinessEntityID = sp.BusinessEntityID
JOIN Sales.SalesOrderHeader sh ON sh.SalesPersonID = sp.BusinessEntityID
JOIN Sales.SalesOrderDetail sd ON sd.SalesOrderID = sh.SalesOrderID
JOIN Production.Product pr ON pr.ProductID = sd.ProductID

--X5. Returnați SalesPersonFullName, câți bani a adus în firmă, și cu câți bani l-am plătit de la prima lui vânzare până la ultima, luand în considerare doar hourly rate, fără bonus, având în vedere că lucrează 8h/zi.
SELECT sp.BusinessEntityID, p.FirstName + p.LastName AS Name, SUM(s.TotalDue) AS BaniAdusi,
       (DATEDIFF(DAY, MIN(s.OrderDate), MAX(s.OrderDate)))*8*ep.Rate AS BaniPlatit
FROM Sales.SalesPerson sp
JOIN HumanResources.Employee e ON e.BusinessEntityID = sp.BusinessEntityID
JOIN HumanResources.EmployeePayHistory ep ON ep.BusinessEntityID = sp.BusinessEntityID
JOIN Person.Person p ON p.BusinessEntityID = sp.BusinessEntityID
JOIN Sales.SalesOrderHeader s ON s.SalesPersonID = sp.BusinessEntityID
GROUP BY sp.BusinessEntityID, p.FirstName, p.LastName, ep.Rate

--X6. (Scripts: Credit, Insurance) Folosind cele două tabele returnați două coloane: prima coloană să conțină toate id-urile de clienți din cele două tabele și a doua coloană să conțină id-ul poliței de asigurare, dacă are, sau, dacă nu are asigurare, să conțină id-ul creditului. 
--   Adică dacă un client are și asigurare și credit, în cea de-a doua coloană va apărea doar id-ul asigurării. Doar dacă nu are, va trebui să apară id-ul creditului. (Nu aveți voie cu UNION)
SELECT COALESCE(c.ClientID, i.ClientID), COALESCE(i.PolicyID, c.CreditID)
FROM Credit c
FULL JOIN Insurance i ON i.ClientID = c.ClientID

--X7. Numele/denumirea clienților care n-au făcut încă nicio comandă (două variante: cu subquery și cu join)
SELECT COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS Nume
FROM Sales.Customer c
LEFT JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
LEFT JOIN Sales.Store s ON s.BusinessEntityID = c.StoreID
WHERE c.CustomerID NOT IN ( SELECT DISTINCT CustomerID
                            FROM Sales.SalesOrderHeader)

SELECT  COALESCE((SELECT p.FirstName + ' ' + p.LastName
                  FROM Person.Person p
                  WHERE p.BusinessEntityID = c.PersonID),

                 (SELECT s.Name
                  FROM Sales.Store s
                  WHERE s.BusinessEntityID = c.StoreID)
                ) AS Nume
FROM Sales.Customer c
WHERE c.CustomerID NOT IN (SELECT CustomerID
                           FROM Sales.SalesOrderHeader)


SELECT COALESCE(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader sh ON sh.CustomerID = c.CustomerID
LEFT JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
LEFT JOIN Sales.Store s ON s.BusinessEntityID = c.StoreID
WHERE sh.CustomerID IS NULL

--X8. În ce orașe a vândut fiecare SalesPerson?
SELECT DISTINCT p.FirstName + ' ' + p.LastName AS Nume, a.City
FROM Sales.SalesPerson sp
JOIN Person.Person p ON p.BusinessEntityID = sp.BusinessEntityID
JOIN Sales.SalesOrderHeader sh ON sh.SalesPersonID = sp.BusinessEntityID
JOIN Person.Address a ON a.AddressID = sh.ShipToAddressID

--X9. Toți clienții și care sunt produsele pe care le-au cumpărat.
SELECT DISTINCT c.CustomerID, p.Name
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader sh ON sh.CustomerID = c.CustomerID
JOIN Sales.SalesOrderDetail sd ON sd.SalesOrderID = sh.SalesOrderID
JOIN Production.Product p ON p.ProductID = sd.ProductID

--X10. Perioadele în care s-a vândut fiecare produs (ex: Bike XL, 2012-05-03 - 2015-01-14) (fara sa ne folosim de coloanele SellStartDate si SellEndDate)
SELECT p.Name, CONCAT(MIN(sh.OrderDate), MAX(sh.OrderDate))
FROM Production.Product p
JOIN Sales.SalesOrderDetail sd ON sd.ProductID = p.ProductID
JOIN Sales.SalesOrderHeader sh ON sh.SalesOrderID = sd.SalesOrderID
GROUP BY p.Name

--X11. (Scripts: Employees)Subordonații direcți ai lui James R Hamilton
SELECT e2.*
FROM Employees e1
JOIN Employees e2  ON e2.ManagerID = e1.BusinessEntityID
WHERE e1.FirstName = 'James'
  AND e1.LastName = 'Hamilton'

--X12. Toate personale care nu sunt employees.
SELECT *
FROM Person.Person p
LEFT JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.BusinessEntityID IS NULL

--X13. (Scripts: Books, Languages) Returnați toate combinațiile dintre books și languages. 
SELECT Name, Alias
FROM Books
CROSS JOIN Languages

--X14. (Scripts: YearlySales) Returnați trei coloane: anul, suma tuturor comenzilor pe anul curent, suma tuturor comenzilor pe anul precedent
SELECT y1.Year, y1.TotalSales, y2.TotalSales
FROM YearlySales y1
LEFT JOIN YearlySales y2 ON y2.Year = y1.Year - 1

--X15. (Scripts: Employees) Ce ID de angajat are CEO-ul?
SELECT e1.BusinessEntityID
FROM Employees e1
LEFT JOIN Employees e2 ON e2.BusinessEntityID = e1.ManagerID
WHERE e2.BusinessEntityID IS NULL


--X16. Ce SalesPersons au făcut mai puține comenzi în perioada ianuarie-iunie 2014 comparativ cu aceeași perioadă din anul precedent?
SELECT p.FirstName + ' ' + p.LastName AS Nume
FROM Sales.SalesOrderHeader sh
JOIN Sales.SalesPerson sp ON sp.BusinessEntityID = sh.SalesPersonID
JOIN Person.Person p ON p.BusinessEntityID = sp.BusinessEntityID
GROUP BY p.FirstName, p.LastName
HAVING SUM(CASE 
            WHEN sh.OrderDate >= '20140101'
             AND sh.OrderDate <  '20140701' THEN 1 
             ELSE 0
           END) 
        <=
        SUM(CASE 
            WHEN sh.OrderDate >= '20130101'
             AND sh.OrderDate <  '20130701' THEN 1 
             ELSE 0
            END)

--X17. (Scripts: Credit, Insurance) Clienții care au credit și nu au poliță și cei care au poliță și nu au credit.
SELECT COALESCE(c.ClientID, i.ClientID)
FROM Credit c
FULL OUTER JOIN Insurance i ON i.ClientID = c.ClientID
WHERE c.ClientID IS NULL
OR i.ClientID IS NULL

--X18. Employees care sunt la al doilea job în companie.
SELECT BusinessEntityID
FROM HumanResources.EmployeeDepartmentHistory
GROUP BY BusinessEntityID
HAVING COUNT(*) = 2

--X19. Care este primul departament al fiecărui angajat?
SELECT ed.BusinessEntityID, d.Name
FROM HumanResources.EmployeeDepartmentHistory ed
JOIN HumanResources.Department d ON d.DepartmentID = ed.DepartmentID
WHERE ed.StartDate = (SELECT MIN(ed2.StartDate)
                      FROM HumanResources.EmployeeDepartmentHistory ed2
                      WHERE ed2.BusinessEntityID = ed.BusinessEntityID)

SELECT ed.BusinessEntityID, d.Name
FROM HumanResources.EmployeeDepartmentHistory ed
JOIN HumanResources.Department d ON d.DepartmentID = ed.DepartmentID
LEFT JOIN HumanResources.EmployeeDepartmentHistory edmin ON edmin.BusinessEntityID = ed.BusinessEntityID
                                                           AND edmin.StartDate < ed.StartDate
WHERE edmin.BusinessEntityID IS NULL