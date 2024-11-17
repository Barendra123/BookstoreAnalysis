Create database BookstoreAnalysis;

USE BookstoreAnalysis;

CREATE TABLE Authors (
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Country NVARCHAR(50)
);

CREATE TABLE Books (
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL,
    Genre NVARCHAR(50),
    Price DECIMAL(10, 2),
    AuthorID INT,
    CONSTRAINT FK_Books_Authors FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(15)
);

CREATE TABLE Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT FOREIGN KEY REFERENCES Books(BookID),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    SaleDate DATE DEFAULT GETDATE(),
    Quantity INT,
    Price DECIMAL(10, 2),
    TotalAmount AS (Quantity * Price) PERSISTED
);

-- Authors
INSERT INTO Authors (Name, Country)
VALUES 
('J.K. Rowling', 'UK'),
('George R.R. Martin', 'USA'),
('Chinua Achebe', 'Nigeria');

-- Books
INSERT INTO Books (Title, Genre, Price, AuthorID)
VALUES 
('Harry Potter and the Philosopher''s Stone', 'Fantasy', 19.99, 1),
('A Game of Thrones', 'Fantasy', 24.99, 2),
('Things Fall Apart', 'Fiction', 14.99, 3);

-- Customers
INSERT INTO Customers (Name, Email, Phone)
VALUES 
('John Doe', 'john.doe@example.com', '123-456-7890'),
('Jane Smith', 'jane.smith@example.com', '987-654-3210');

-- Sales (Ensure Price is included for accurate calculation)
INSERT INTO Sales (BookID, CustomerID, Quantity, Price)
VALUES 
(1, 1, 2, 19.99),
(2, 2, 1, 24.99);

--Total Sold and Revenue per Book
SELECT 
b.Title, 
COALESCE(SUM(s.Quantity), 0) AS TotalSold, 
COALESCE(SUM(s.TotalAmount), 0) AS TotalRevenue
FROM Books b
LEFT JOIN Sales s ON b.BookID = s.BookID
GROUP BY b.Title;

--Total Revenue per Author (Including Authors with No Sales)

SELECT 
a.Name AS Author, 
COALESCE(SUM(s.TotalAmount), 0) AS TotalRevenue
FROM Authors a
LEFT JOIN Books b ON a.AuthorID = b.AuthorID
LEFT JOIN Sales s ON b.BookID = s.BookID
GROUP BY a.Name
ORDER BY TotalRevenue DESC;


--Total Revenue per Author (Only Authors with Sales)
SELECT 
a.Name AS Author, 
SUM(s.TotalAmount) AS TotalRevenue
FROM Sales s
JOIN Books b ON s.BookID = b.BookID
JOIN Authors a ON b.AuthorID = a.AuthorID
GROUP BY a.Name
ORDER BY TotalRevenue DESC;


select * from Authors;