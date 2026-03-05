DROP TABLE IF EXISTS OrderedItems
DROP TABLE IF EXISTS Orders
DROP TABLE IF EXISTS Products
DROP TABLE IF EXISTS CustomerAddresses
DROP TABLE IF EXISTS Customers
DROP TABLE IF EXISTS SalesPersons
DROP TABLE IF EXISTS Persons


CREATE TABLE Persons (PersonID INT IDENTITY(1,1) NOT NULL,
                     PersonTitle CHAR(4) NULL,
                     PersonFirstName VARCHAR(50) NOT NULL,
                     PersonLastName VARCHAR(50) NOT NULL)

CREATE TABLE Customers (CustomerAccNr CHAR(10) NOT NULL,
                       PersonID INT NOT NULL)

CREATE TABLE CustomerAddresses (CustomerAccNr CHAR(10) NOT NULL,
                                CustAddress   VARCHAR(100) NOT NULL)


CREATE TABLE SalesPersons (PersonID INT NOT NULL,
                          SPHrRate DECIMAL(6,4) NOT NULL,
                          SPBonus SMALLINT NOT NULL)

CREATE TABLE Products (ProductName VARCHAR(100) NOT NULL,
                      ProductColor VARCHAR(20) NULL,
                      ProductSize VARCHAR(5) NULL,
                      ProductClass CHAR(1) NULL,
                      ProductStandardCost DECIMAL(8,4) NOT NULL)

CREATE TABLE Orders (SalesOrderID INT NOT NULL,
                               OrderDate DATETIME NOT NULL,
                               ShipDate DATETIME NOT NULL,
                               OrderStatus CHAR(1) NOT NULL,
                               SalesPersonID INT NOT NULL,
                               CustomerAccNr CHAR(10) NOT NULL)

CREATE TABLE OrderedItems (SalesOrderID INT NOT NULL,
                         ProductName VARCHAR(100) NOT NULL,
                         OrderQuantity TINYINT NOT NULL,
                         ProductUnitPrice DECIMAL(8,4) NOT NULL)

ALTER TABLE Persons 
ADD CONSTRAINT PKPerson PRIMARY KEY (PersonID)

ALTER TABLE Customers 
ADD CONSTRAINT PKCustomer PRIMARY KEY (CustomerAccNr)
ALTER TABLE Customers
ADD CONSTRAINT FKCustPersonID FOREIGN KEY (PersonID) REFERENCES Persons(PersonID)
ALTER TABLE Customers
ADD CONSTRAINT UQCustomer UNIQUE (PersonID)

ALTER TABLE CustomerAddresses
ADD CONSTRAINT PKCustomerAddresses
PRIMARY KEY (CustomerAccNr, CustAddress)
ALTER TABLE CustomerAddresses
ADD CONSTRAINT FKCustAccNr FOREIGN KEY (CustomerAccNr) REFERENCES Customers(CustomerAccNr)

ALTER TABLE SalesPersons
ADD CONSTRAINT PKSalesPerson PRIMARY KEY (PersonID)
ALTER TABLE SalesPersons
ADD CONSTRAINT FKSalesPerson FOREIGN KEY (PersonID) REFERENCES Persons(PersonID)
ALTER TABLE SalesPersons
ADD CONSTRAINT DFBonus DEFAULT (0) FOR SPBonus
ALTER TABLE SalesPersons
ADD CONSTRAINT CKHrRate CHECK (SPHrRate > 0)

ALTER TABLE Products 
ADD CONSTRAINT PKProduct PRIMARY KEY (ProductName)
ALTER TABLE Products
ADD CONSTRAINT CKStandardCost CHECK (ProductStandardCost > 0)


ALTER TABLE Orders
ADD CONSTRAINT PKSalesOrder PRIMARY KEY (SalesOrderID)
ALTER TABLE Orders
ADD CONSTRAINT FKSPID FOREIGN KEY (SalesPersonID) REFERENCES SalesPersons(PersonID)
ALTER TABLE Orders
ADD CONSTRAINT FKCustomer FOREIGN KEY (CustomerAccNr) REFERENCES Customers(CustomerAccNr)
ALTER TABLE Orders
ADD CONSTRAINT CKDate CHECK (ShipDate >= OrderDate)

ALTER TABLE OrderedItems
ADD CONSTRAINT FKSalesID FOREIGN KEY (SalesOrderID) REFERENCES Orders(SalesOrderID)
ALTER TABLE OrderedItems
ADD CONSTRAINT FKProduct FOREIGN KEY (ProductName) REFERENCES Products(ProductName)
ALTER TABLE OrderedItems
ADD CONSTRAINT PKFinalOrder PRIMARY KEY (SalesOrderID ,ProductName)
ALTER TABLE OrderedItems
ADD CONSTRAINT CKQuantity CHECK (OrderQuantity > 0)
ALTER TABLE OrderedItems
ADD CONSTRAINT CKUnitPrice CHECK (ProductUnitPrice > 0)