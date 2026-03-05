--X1. Returnați într-o singură coloană numele întreg al tuturor persoanelor (FirstName, MiddleName, LastName). 
--   Două versiuni: CONCAT și operatorul +.
SELECT FirstName + ' ' + IIF(MiddleName IS NULL, '', MiddleName + ' ') + LastName FROM Person.Person
SELECT CONCAT(FirstName, ' ', MiddleName + ' ', LastName) FROM Person.Person

--X2. Returnați toate produsele într-o coloană și o a doua coloană cu categoria din care fac parte. 
--   Creați trei categorii de produse (low-end, high-end, premium) în funcție de costul fiecărui produs: <1000, 1000-2000, >=2000.
--   Două versiuni: CASE și IIF.
SELECT Name,
	   CASE
	   WHEN StandardCost < 1000 THEN 'low-end'
	   WHEN StandardCost BETWEEN 1000 AND 2000 THEN 'high-end' 
	   ELSE 'premium'
	   END
FROM Production.Product
SELECT Name, IIF(StandardCost < 1000, 'low-end', 
									  IIF(StandardCost BETWEEN 1000 AND 2000, 'high-end', 'premium'))
FROM Production.Product
--X3. Returnati toate numele de produse intr-o coloana, o a doua coloana cu culoarea. 
--   In cazul in care culoarea produsului este NULL să apară 'No Color'.
--   Și o a treia coloană în care să afișați Weight, dar dacă este NULL să afișați Size și dacă și acesta este NULL să afișați Class.
--   Două versiuni: ISNULL și COALESCE
SELECT Name,
	   ISNULL(Color, 'No Color'),
	   ISNULL(CONVERT(VARCHAR, Weight),
				ISNULL(CONVERT(VARCHAR, Size),
				Class))
FROM Production.Product
SELECT Name,
	   COALESCE(Color, 'No Color'),
	   COALESCE(CONVERT(VARCHAR, Weight),
				CONVERT(VARCHAR, Size),
				Class)
FROM Production.Product

--X4. Returnati toate denumirile de produse, dar scoateți cratimele din acestea.
SELECT REPLACE(Name, '-', '') FROM Production.Product

--X5. Returnati câte secunde s-au scurs de la începutul anului curent.
SELECT DATEDIFF(SECOND,
				DATEFROMPARTS(YEAR(GETDATE()),1,1),
				GETDATE())

--X6. Afișați comenzile si data acestora în format american (mm/dd/yyyy).
--   Două versiuni: CONVERT și FORMAT
SELECT SalesOrderID, CONVERT(VARCHAR, OrderDate, 101) FROM Sales.SalesOrderHeader
SELECT SalesOrderID, FORMAT(OrderDate, 'MM/dd/yyyy') FROM Sales.SalesOrderHeader

--X7. Returnați toate persoanele și creați-le fiecăruia un cod unic compus din prima literă uppercase a numelui de familie, prima literă uppercase a prenumelui și cinci cifre care să conțină ID-ul fiecăruia 
--   (ex: Andrei Neagu cu ID-ul 1 se transformă în AN00001, Bogdan Ștefănescu cu ID-ul 12 se transformă în BS00012).
SELECT CONCAT(FirstName, ' ', MiddleName + ' ', LastName),
		UPPER(LEFT(FirstName, 1)) + UPPER(LEFT(LastName, 1)) +
		RIGHT('0000' + CAST(BusinessEntityID AS VARCHAR(5)), 5)
FROM Person.Person

--X8. Returnați al doilea cuvânt din numele produselor.
SELECT CASE
        WHEN CHARINDEX(' ', Name) = 0 THEN NULL
        ELSE
                 SUBSTRING(Name,
                 CHARINDEX(' ', Name + ' ') + 1,
                 CHARINDEX(' ', Name + ' ', CHARINDEX(' ', Name + ' ') + 1)
                 - CHARINDEX(' ', Name + ' ') - 1)
        END
FROM Production.Product

--X9. Returnați o singură valoare/celulă cu toate prenumele persoanelor despărțite de virgulă 'Ken, Terri, Roberto, Rob'
SELECT STRING_AGG(CAST(FirstName AS VARCHAR(MAX)), ', ') FROM Person.Person

--X10. Folosind UPDATE modificați câteva comenzi altfel încât să existe în tabel comenzi cu toate statusurile de la 1 la 5. 
--    Apoi faceți un select care să returneze toate comenzile și statusurile acestora, înlocuind numărul statusului cu 
--descrierea lui: 1=registered, 2=paid, 3=processed, 4=sent, 5=delivered.
UPDATE Sales.SalesOrderHeader SET Status = 1 WHERE SalesOrderID = 43659
UPDATE Sales.SalesOrderHeader SET Status = 2 WHERE SalesOrderID = 43660
UPDATE Sales.SalesOrderHeader SET Status = 3 WHERE SalesOrderID = 43661
UPDATE Sales.SalesOrderHeader SET Status = 4 WHERE SalesOrderID = 43662

SELECT SalesOrderID,
	   CASE Status
		WHEN 1 THEN 'registered'
		WHEN 2 THEN 'paid'
		WHEN 3 THEN 'processed'
		WHEN 4 THEN 'sent'
		WHEN 5 THEN 'delivered'
		END
FROM Sales.SalesOrderHeader

--X11. Afișați trei coloane. Prima să fie OrderID. 
--    În a doua coloană calculați data de peste 7 zile de la data înregistrării comenzii. 
--    În a treia coloană afișați cuvântul 'Alert' dacă ShipDate este mai mare decât valoarea din a doua coloană.
SELECT SalesOrderID AS OrderID,
		DATEADD(DAY, 7, OrderDate),
		IIF(ShipDate > DATEADD(DAY, 7, OrderDate), 'Alert', '')
FROM Sales.SalesOrderHeader
--WHERE SalesOrderID = 65089