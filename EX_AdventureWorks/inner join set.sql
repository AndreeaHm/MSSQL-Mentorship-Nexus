--x1. Returnați produsele și subcategoria din care face parte fiecare.
SELECT p.ProductID, p.Name, s.Name 
FROM Production.Product p
JOIN Production.ProductSubcategory s ON s.ProductSubcategoryID = p.ProductSubcategoryID

--x2. Returnați ID-ul comenzii, data la care s-a făcut și teritoriul pe care a fost plasată fiecare comanda.
SELECT h.SalesOrderID, h.OrderDate, t.Name 
FROM Sales.SalesOrderHeader h  
JOIN Sales.SalesTerritory t ON t.TerritoryID = h.TerritoryID

--x3. Returnați toate categoriile de produse și subcategoriile acestora.
SELECT c.Name, s.Name
FROM Production.ProductCategory c
JOIN Production.ProductSubcategory s ON s.ProductCategoryID = c.ProductCategoryID

--x4. Returnați toate persoanele și numărul lor de telefon.
SELECT p.LastName + p.FirstName AS Name, ph.PhoneNumber
FROM Person.Person p
JOIN Person.PersonPhone ph ON ph.BusinessEntityID = p.BusinessEntityID

--x5. Returnați din ce provincie face parte fiecare persoană.
SELECT p.LastName + p.FirstName AS Name, sp.Name
FROM Person.Person p
JOIN Person.BusinessEntityAddress ea ON ea.BusinessEntityID = p.BusinessEntityID
JOIN Person.Address a ON a.AddressID = ea.AddressID
JOIN Person.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID

--x6. Returnați toate persoanele, adresele lor și ce tip de adresă este fiecare.
SELECT p.LastName + p.FirstName AS Name, a.AddressLine1 + ISNULL(a.AddressLine2, '') AS Adresa, aty.Name
FROM Person.Person p
JOIN Person.BusinessEntityAddress ea ON ea.BusinessEntityID = p.BusinessEntityID
JOIN Person.Address a ON a.AddressID = ea.AddressID
JOIN Person.AddressType aty ON aty.AddressTypeID = ea.AddressTypeID

--x7. Returnați fiecare salesperson cu numele și prenumele lui și ce sales quota are.
SELECT sp.BusinessEntityID, p.FirstName, p.LastName, sp.SalesQuota
FROM Sales.SalesPerson AS sp
JOIN Person.Person AS p ON p.BusinessEntityID = sp.BusinessEntityID

--x8. Returnați numele și prenumele fiecărui client și regiunea unde locuiește.
SELECT p.LastName + p.FirstName AS Name, cr.Name
FROM Sales.Customer c 
JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
JOIN Person.BusinessEntityAddress ea ON ea.BusinessEntityID = p.BusinessEntityID
JOIN Person.Address a ON a.AddressID = ea.AddressID
JOIN Person.StateProvince sp ON sp.StateProvinceID = a.StateProvinceID
JOIN Person.CountryRegion cr ON cr.CountryRegionCode = sp.CountryRegionCode

--x9. Returnați adresele tuturor furnizorilor.
SELECT e.BusinessEntityID, a.AddressLine1 + ISNULL(a.AddressLine2, '')
FROM Purchasing.Vendor v
JOIN Person.BusinessEntityAddress e ON e.BusinessEntityID = v.BusinessEntityID
JOIN Person.Address a ON a.AddressID = e.AddressID

--x10. Care este metoda preferată de livrare a fiecărui client?
SELECT h.CustomerID, s.Name
FROM Sales.SalesOrderHeader h
JOIN Purchasing.ShipMethod s ON s.ShipMethodID = h.ShipMethodID
GROUP BY h.CustomerID, h.ShipMethodID, s.Name
HAVING h.ShipMethodID = (SELECT TOP(1) COUNT(ShipMethodID)
                         FROM Sales.SalesOrderHeader
                         WHERE CustomerID = h.CustomerID)