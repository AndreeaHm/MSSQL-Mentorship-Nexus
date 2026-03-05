--Functii String

--X1. Returnați primele 3 caractere din orice propoziție.
SELECT LEFT(Name, 3) FROM Production.Product
--X2. Returnați poziția pe care se află a doua aparitie a literei 'a' din orice propoziție.
SELECT CHARINDEX('a', Name, CHARINDEX('a', Name) + 1) FROM Production.Product
--X3. Returnați primul și ultimul caracter din orice propoziție.
SELECT LEFT(Name, 1) + RIGHT(Name, 1) FROM Production.Product
--X4. Returnați primul cuvânt din orice propoziție.
SELECT LEFT(Name, CHARINDEX(' ', Name + ' ') - 1) FROM Production.Product
--X5. Returnați lungimea primului cuvânt din orice propoziție.
SELECT LEN(LEFT(Name, CHARINDEX(' ', Name + ' ') - 1)) FROM Production.Product
--X6. Returnați al doilea cuvânt din orice propoziție.
SELECT CASE
        WHEN CHARINDEX(' ', Name) = 0 THEN NULL
        ELSE
                 SUBSTRING(Name,
                 CHARINDEX(' ', Name + ' ') + 1,
                 CHARINDEX(' ', Name + ' ', CHARINDEX(' ', Name + ' ') + 1)
                 - CHARINDEX(' ', Name + ' ') - 1)
        END
FROM Production.Product
--Optional:
--7. Returnați primele 3 litere din orice propoziție.


-- Functii Date

--X1. Returnați în ce dată vom fi peste 300 de zile.
SELECT DATEADD(DAY, 300, GETDATE())
--X2. Returnați câte secunde au trecut de la @d la data curentă
	DECLARE @d datetime 
	SET @d = '2023-01-23 10:00:10'
SELECT DATEDIFF(SECOND, @d, GETDATE())
--X3. Returnați prima zi a lunii curente.
SELECT DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
--X4. Returnați câte zile mai sunt din luna curentă.
SELECT DATEDIFF(DAY, --cate zile
                GETDATE(), --ziua curenta
                DATEADD( --ultima luna din an
                    DAY,
                    -1, -- -1 pentru a afla ultima zi din luna curenta
                    DATEADD(
                        MONTH,
                        1,
                        DATEFROMPARTS(
                                    YEAR(GETDATE()),
                                    MONTH(GETDATE()),
                                    1))))

--X5. Returnați ultima zi a lunii curente.
SELECT DATEADD(
                DAY,
                -1, -- -1 pentru a afla ultima zi din luna curenta
                DATEADD(
                        MONTH,
                        1,
                        DATEFROMPARTS(
                                    YEAR(GETDATE()),
                                    MONTH(GETDATE()),
                                    1)))
--X6. Returnați 1 dacă anul curent este bisect sau 0 dacă nu este an bisect.
SELECT IIF((YEAR(GETDATE()) % 400 = 0) 
            OR (YEAR(GETDATE()) % 4 = 0 
            AND YEAR(GETDATE()) % 100 != 0),
            1, 0)


DECLARE @d datetime 
	SET @d = '2023-12-23 10:00:10'
SELECT DATEADD(
                DAY,
                -1, -- -1 pentru a afla ultima zi din luna curenta
                DATEADD(
                        MONTH,
                        1,
                        DATEFROMPARTS(
                                    YEAR(@d),
                                    MONTH(@d),
                                    1)))